import { v2 as cloudinary } from "cloudinary";
import * as dotenv from "dotenv";
import multer from "multer";
import { extensionToMimeType, allowedExtensions } from "../core/utils/extentions.js";
import path from "path";

// Load environment variables
dotenv.config();

// Configure cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true,
});

// Configure multer for memory storage (no local files)
const storage = multer.memoryStorage();

// Enhanced file filter for all media types
const fileFilter = (req, file, cb) => {
  const fileExtension = path.extname(file.originalname).toLowerCase();
  const allAllowedExtensions = Object.values(allowedExtensions).flat();
  const allowedMimeTypes = Object.values(extensionToMimeType);

  // Check if extension is valid
  const isExtensionValid = allAllowedExtensions.includes(fileExtension);

  if (!isExtensionValid) {
    cb(
      new Error(
        `Invalid file extension: ${fileExtension}. Please upload a supported file type.`,
      ),
    );
    return;
  }

  // Check MIME type with fallback for application/octet-stream
  const isMimeTypeValid = allowedMimeTypes.includes(file.mimetype);
  const isGenericMimeType = file.mimetype === "application/octet-stream";
  const expectedMimeType = extensionToMimeType[fileExtension];

  if (isMimeTypeValid || (isGenericMimeType && expectedMimeType)) {
    // Correct MIME type if it's generic but valid extension
    if (isGenericMimeType && expectedMimeType) {
      file.mimetype = expectedMimeType;
    }
    cb(null, true);
  } else {
    cb(
      new Error(
        `Invalid file type. Received: ${file.mimetype} (${fileExtension}). Expected: ${expectedMimeType || "valid file MIME type"}.`,
      ),
    );
  }
};

// Initialize multer upload with memory storage
export const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 20 * 1024 * 1024, // 20MB limit
  },
});

// Multer error handler middleware
export function multerErrorHandler(err, req, res, next) {
  if (err instanceof multer.MulterError) {
    if (err.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        status: "error",
        message: "File too large. Maximum size is 20MB.",
      });
    }
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  } else if (err) {
    return res.status(400).json({
      status: "error",
      message: err.message,
    });
  }
  next();
}

const getResourceType = (filename) => {
  const ext = filename.toLowerCase().split(".").pop();

  if (allowedExtensions.images.includes(ext)) return "image";
  if (allowedExtensions.videos.includes(ext)) return "video";
  if (allowedExtensions.audio.includes(ext)) return "audio"; // Cloudinary treats audio as video resource type
  return "raw"; // For documents and other files
};

//Upload file buffer directly to Cloudinary

export const uploadToCloudinary = async (
  fileBuffer,
  originalName,
  folder = "/projects/speakup",
) => {
  try {
    const resourceType = getResourceType(originalName);
    const fileExtension = originalName.split(".").pop();
    const fileName = originalName.split(".").slice(0, -1).join(".");

    console.log("Upload parameters:", {
      originalName,
      folder,
      resourceType,
      fileExtension,
      fileName,
    });

    const uploadOptions = {
      folder: folder, // This should be "projects/workspace"
      resource_type: resourceType,
      public_id: `${fileName}_${Date.now()}`,
      use_filename: true,
      unique_filename: true,
    };

    // Add transformations for images and videos
    if (resourceType === "image") {
      uploadOptions.transformation = [
        { width: 1000, height: 1000, crop: "limit" },
        { quality: "auto" },
        { fetch_format: "auto" },
      ];
    } else if (resourceType === "video") {
      uploadOptions.transformation = [
        { quality: "auto" },
        { fetch_format: "auto" },
      ];
    }

    console.log("Cloudinary upload options:", uploadOptions);

    // Upload buffer directly to Cloudinary
    const result = await new Promise((resolve, reject) => {
      cloudinary.uploader
        .upload_stream(uploadOptions, (error, result) => {
          if (error) {
            console.error("Cloudinary upload error:", error);
            reject(error);
          } else {
            console.log("Cloudinary upload success:", {
              public_id: result.public_id,
              secure_url: result.secure_url,
              folder: result.folder,
            });
            resolve(result);
          }
        })
        .end(fileBuffer);
    });

    // Validate that we got a secure_url
    if (!result.secure_url) {
      throw new Error("Cloudinary upload succeeded but no secure_url returned");
    }

    // Return comprehensive file information
    return {
      url: result.secure_url,
      public_id: result.public_id,
      resource_type: result.resource_type,
      format: result.format,
      bytes: result.bytes,
      width: result.width,
      height: result.height,
      duration: result.duration, // For video/audio files
      original_filename: result.original_filename,
      created_at: result.created_at,
      type: resourceType,
      filename: originalName,
    };
  } catch (error) {
    console.error("Cloudinary upload error:", error);
    throw error;
  }
};

export const deleteFromCloudinary = async (
  publicId,
  resourceType = "image",
) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: resourceType,
    });
    return result;
  } catch (error) {
    console.error("Error deleting from Cloudinary:", error);
    throw error;
  }
};

export const getOptimizedFileUrl = (
  publicId,
  resourceType = "image",
  transformations = [],
) => {
  return cloudinary.url(publicId, {
    resource_type: resourceType,
    ...transformations,
    secure: true,
    quality: "auto",
    fetch_format: "auto",
  });
};

export const getFileMetadata = async (publicId, resourceType = "image") => {
  try {
    const result = await cloudinary.api.resource(publicId, {
      resource_type: resourceType,
    });
    return result;
  } catch (error) {
    console.error("Error getting file metadata:", error);
    throw error;
  }
};

export const uploadBuffer = async (fileBuffer, options = {}) => {
  const { folder = "speakup", transformation = [] } = options;
  const result = await new Promise((resolve, reject) => {
    const uploadOptions = {
      folder,
      resource_type: "image",
      transformation,
    };
    cloudinary.uploader
      .upload_stream(uploadOptions, (error, result) => {
        if (error) reject(error);
        else resolve(result);
      })
      .end(fileBuffer);
  });
  return { url: result.secure_url, public_id: result.public_id };
};