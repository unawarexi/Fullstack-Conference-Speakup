import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Use case for managing AI workflows.
class WorkflowUseCase {
  final Ref _ref;
  WorkflowUseCase(this._ref);

  Future<List<WorkflowStatus>> getActive() {
    return _ref.read(aiRepositoryProvider).getActiveWorkflows();
  }

  Future<WorkflowStatus> getStatus(String workflowId) {
    return _ref.read(aiRepositoryProvider).getWorkflowStatus(workflowId);
  }

  Future<WorkflowStatus> runPostMeeting(String meetingId, {Map<String, dynamic>? config}) {
    return _ref.read(aiRepositoryProvider).runPostMeetingWorkflow(meetingId, config);
  }

  Future<WorkflowStatus> runPreMeeting(String meetingId) {
    return _ref.read(aiRepositoryProvider).runPreMeetingWorkflow(meetingId);
  }
}

final workflowUseCaseProvider = Provider<WorkflowUseCase>((ref) {
  return WorkflowUseCase(ref);
});
