import express from "express";
import upload from "../middleware/upload.js";
import { createAccount } from "../controllers/registrationController.js";

const router = express.Router();

router.post(
  "/create-account",
  upload.fields([
    { name: "aadhaarPhoto", maxCount: 1 },
    { name: "livePhoto", maxCount: 1 },
  ]),
  createAccount
);

export default router;