import multer from "multer";

// Store files in memory.
// Later we'll upload the buffer to AWS S3.
const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10 MB
  },
});

export default upload;