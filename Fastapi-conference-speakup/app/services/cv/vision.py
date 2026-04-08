# SpeakUp AI — Computer Vision Service
# Face analysis, posture estimation, gaze tracking, gesture detection
from __future__ import annotations

import asyncio
import time
from typing import Any

import numpy as np

from app.core.constants import KafkaTopics, RedisKeys
from app.core.logging import get_logger
from app.schemas.ai_schemas import (
    CVAnalysisResult,
    FaceAnalysis,
    PostureAnalysis,
)
from infrastructure.kafka.producer import publish_event
from infrastructure.redis.client import publish

log = get_logger("cv_service")

# ── Model singletons ──
_face_mesh = None
_pose_detector = None
_face_detector = None


async def load_models() -> None:
    """Load MediaPipe models on startup."""
    global _face_mesh, _pose_detector, _face_detector
    loop = asyncio.get_event_loop()

    def _load():
        global _face_mesh, _pose_detector, _face_detector
        import mediapipe as mp

        # Face Mesh for landmarks + gaze
        _face_mesh = mp.solutions.face_mesh.FaceMesh(
            static_image_mode=False,
            max_num_faces=4,
            refine_landmarks=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
        )

        # Pose detector for body posture
        _pose_detector = mp.solutions.pose.Pose(
            static_image_mode=False,
            model_complexity=1,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5,
        )

        # Face detection for bounding boxes
        _face_detector = mp.solutions.face_detection.FaceDetection(
            model_selection=1,
            min_detection_confidence=0.5,
        )

        log.info("MediaPipe models loaded (face_mesh, pose, face_detection)")

    await loop.run_in_executor(None, _load)


def _decode_frame(frame_bytes: bytes, width: int = 640, height: int = 480) -> np.ndarray:
    """Decode raw frame bytes to numpy array."""
    import cv2

    nparr = np.frombuffer(frame_bytes, np.uint8)
    frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    if frame is None:
        # Try raw reshape
        frame = nparr.reshape((height, width, 3))
    return frame


def _estimate_gaze(face_landmarks, image_width: int, image_height: int) -> dict[str, float]:
    """Estimate gaze direction from iris landmarks."""
    # Left iris: 468-472, Right iris: 473-477
    left_iris = face_landmarks.landmark[468]
    right_iris = face_landmarks.landmark[473]
    left_eye_inner = face_landmarks.landmark[133]
    left_eye_outer = face_landmarks.landmark[33]
    right_eye_inner = face_landmarks.landmark[362]
    right_eye_outer = face_landmarks.landmark[263]

    # Horizontal gaze ratio
    left_eye_width = abs(left_eye_outer.x - left_eye_inner.x)
    left_iris_pos = (left_iris.x - left_eye_outer.x) / left_eye_width if left_eye_width > 0 else 0.5

    right_eye_width = abs(right_eye_inner.x - right_eye_outer.x)
    right_iris_pos = (right_iris.x - right_eye_outer.x) / right_eye_width if right_eye_width > 0 else 0.5

    avg_horizontal = (left_iris_pos + right_iris_pos) / 2
    yaw = (avg_horizontal - 0.5) * 60  # degrees approx

    # Vertical estimation
    left_eye_top = face_landmarks.landmark[159]
    left_eye_bottom = face_landmarks.landmark[145]
    left_eye_height = abs(left_eye_top.y - left_eye_bottom.y)
    vertical_ratio = (left_iris.y - left_eye_top.y) / left_eye_height if left_eye_height > 0 else 0.5
    pitch = (vertical_ratio - 0.5) * 40

    return {"yaw": round(yaw, 2), "pitch": round(pitch, 2)}


def _estimate_head_pose(face_landmarks) -> dict[str, float]:
    """Estimate head rotation from face landmark geometry."""
    nose = face_landmarks.landmark[1]
    left_ear = face_landmarks.landmark[234]
    right_ear = face_landmarks.landmark[454]
    forehead = face_landmarks.landmark[10]
    chin = face_landmarks.landmark[152]

    # Yaw: nose position relative to ear midpoint
    ear_midpoint_x = (left_ear.x + right_ear.x) / 2
    yaw = (nose.x - ear_midpoint_x) * 180

    # Pitch: nose vs forehead-chin line
    face_height = abs(forehead.y - chin.y)
    nose_ratio = (nose.y - forehead.y) / face_height if face_height > 0 else 0.5
    pitch = (nose_ratio - 0.4) * 90

    # Roll: ear tilt
    roll = np.degrees(np.arctan2(right_ear.y - left_ear.y, right_ear.x - left_ear.x))

    return {"yaw": round(yaw, 2), "pitch": round(pitch, 2), "roll": round(float(roll), 2)}


def _calculate_smile_score(face_landmarks) -> float:
    """Detect smile from mouth landmarks."""
    left_mouth = face_landmarks.landmark[61]
    right_mouth = face_landmarks.landmark[291]
    upper_lip = face_landmarks.landmark[13]
    lower_lip = face_landmarks.landmark[14]

    mouth_width = abs(right_mouth.x - left_mouth.x)
    mouth_height = abs(lower_lip.y - upper_lip.y)
    ratio = mouth_width / mouth_height if mouth_height > 0 else 0

    # Higher ratio = wider smile
    return min(1.0, max(0.0, (ratio - 2.0) / 4.0))


async def analyze_frame(
    frame_bytes: bytes,
    meeting_id: str,
    participant_id: str,
    width: int = 640,
    height: int = 480,
) -> CVAnalysisResult:
    """Analyze a single video frame for face + posture."""
    loop = asyncio.get_event_loop()
    start_time = time.monotonic()

    def _analyze():
        import cv2

        frame = _decode_frame(frame_bytes, width, height)
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

        face_result = None
        posture_result = None

        # Face analysis
        if _face_mesh is not None:
            face_results = _face_mesh.process(rgb_frame)
            if face_results.multi_face_landmarks:
                landmarks = face_results.multi_face_landmarks[0]
                gaze = _estimate_gaze(landmarks, width, height)
                head_pose = _estimate_head_pose(landmarks)
                smile = _calculate_smile_score(landmarks)

                # Eye contact score: how centered the gaze is
                eye_contact = max(0.0, 1.0 - (abs(gaze["yaw"]) + abs(gaze["pitch"])) / 60)

                face_result = FaceAnalysis(
                    participant_id=participant_id,
                    face_detected=True,
                    gaze_direction=gaze,
                    eye_contact_score=round(eye_contact, 3),
                    smile_score=round(smile, 3),
                    head_pose=head_pose,
                )
            else:
                face_result = FaceAnalysis(participant_id=participant_id, face_detected=False)

        # Posture analysis
        if _pose_detector is not None:
            pose_results = _pose_detector.process(rgb_frame)
            if pose_results.pose_landmarks:
                landmarks = pose_results.pose_landmarks

                # Posture score from shoulder alignment
                left_shoulder = landmarks.landmark[11]
                right_shoulder = landmarks.landmark[12]
                shoulder_diff = abs(left_shoulder.y - right_shoulder.y)
                posture_score = max(0.0, 1.0 - shoulder_diff * 10)

                # Simple fidgeting: visibility variance (placeholder for temporal analysis)
                visible_landmarks = sum(1 for lm in landmarks.landmark if lm.visibility > 0.5)
                total_landmarks = len(landmarks.landmark)

                posture_result = PostureAnalysis(
                    participant_id=participant_id,
                    body_detected=True,
                    posture_score=round(posture_score, 3),
                    presentation_confidence=round(posture_score * 0.7, 3),
                )
            else:
                posture_result = PostureAnalysis(participant_id=participant_id, body_detected=False)

        return face_result, posture_result

    face_result, posture_result = await loop.run_in_executor(None, _analyze)
    elapsed = time.monotonic() - start_time

    result = CVAnalysisResult(
        meeting_id=meeting_id,
        participant_id=participant_id,
        timestamp=time.time(),
        face=face_result,
        posture=posture_result,
    )

    # Publish CV analysis
    await publish_event(
        KafkaTopics.AI_CV_ANALYSIS,
        key=meeting_id,
        value=result.model_dump(),
    )

    # Real-time push to meeting room
    await publish(
        RedisKeys.CHANNEL_AI_INSIGHTS.format(meeting_id=meeting_id),
        {"type": "cv_analysis", "data": result.model_dump()},
    )

    log.debug(
        "Frame analyzed",
        meeting_id=meeting_id,
        participant_id=participant_id,
        face_detected=face_result.face_detected if face_result else False,
        inference_ms=round(elapsed * 1000, 2),
    )

    return result


async def analyze_frame_batch(
    frames: list[dict],
    meeting_id: str,
) -> list[CVAnalysisResult]:
    """Analyze multiple frames concurrently."""
    tasks = [
        analyze_frame(
            frame_bytes=f["data"],
            meeting_id=meeting_id,
            participant_id=f["participant_id"],
            width=f.get("width", 640),
            height=f.get("height", 480),
        )
        for f in frames
    ]
    return await asyncio.gather(*tasks, return_exceptions=True)
