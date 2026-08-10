// Backend/routes/jobRoutes.js

import express from "express";
import pool from "../db.js";

const router = express.Router();

/*
  GET /jobs

  Returns all jobs with:
  - job details
  - category name
  - subcategory name
*/
router.get("/", async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        j.id,
        j.name,
        j.company,
        j.description,
        j.salary_min,
        j.salary_max,
        j.job_type,
        j.category_id,
        jc.name AS category,
        j.subcategory_id,
        js.name AS subcategory,
        j.no_of_openings,
        j.work_location,
        j.created_at,
        j.updated_at
      FROM public.jobs j
      INNER JOIN public.job_category jc
        ON jc.id = j.category_id
      INNER JOIN public.job_subcategory js
        ON js.id = j.subcategory_id
      ORDER BY j.created_at DESC;
    `);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      jobs: result.rows,
    });
  } catch (error) {
    console.error("Error fetching jobs:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch jobs",
    });
  }
});

export default router;