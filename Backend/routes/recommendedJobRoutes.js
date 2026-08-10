// Backend/routes/recommendedJobRoutes.js

import express from "express";
import { getRecommendedJobs } from "../controllers/recommendedJobController.js";

const router = express.Router();

router.get("/", getRecommendedJobs);

export default router;