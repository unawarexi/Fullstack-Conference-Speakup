import multer from "multer";

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