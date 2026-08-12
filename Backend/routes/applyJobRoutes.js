import express from "express";
import pool from "../db.js";

const router = express.Router();

// ========================================
// APPLY FOR JOB
// ========================================

router.post("/:jobId/apply", async (req, res) => {
  console.log("\n========================================");
  console.log("APPLY FOR JOB REQUEST");
  console.log("========================================");

  const { jobId } = req.params;
  const { phone } = req.body;

  console.log("[APPLY] Job ID:", jobId);
  console.log("[APPLY] Phone:", phone);

  try {
    // ========================================
    // VALIDATE INPUT
    // ========================================

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: "Phone number is required",
      });
    }

    const numericJobId = Number(jobId);

    if (!Number.isInteger(numericJobId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid job ID",
      });
    }

    // ========================================
    // NORMALIZE PHONE
    // ========================================

    let cleanPhone = phone.replace(/\D/g, "");

    if (cleanPhone.length === 12 && cleanPhone.startsWith("91")) {
      cleanPhone = cleanPhone.substring(2);
    }

    if (cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    console.log("[APPLY] Clean phone:", cleanPhone);

    // ========================================
    // FIND USER
    // ========================================

    const userResult = await pool.query(
      `
        SELECT id
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone],
    );

    if (userResult.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const userId = userResult.rows[0].id;

    console.log("[APPLY] User ID:", userId);

    // ========================================
    // CHECK JOB EXISTS
    // ========================================

    const jobResult = await pool.query(
      `
        SELECT id, no_of_openings
        FROM jobs
        WHERE id = $1
        LIMIT 1
      `,
      [numericJobId],
    );

    if (jobResult.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    console.log("[APPLY] Job exists:", numericJobId);

    // ========================================
    // CHECK IF ALREADY APPLIED
    // ========================================

    const existingApplication = await pool.query(
      `
        SELECT id, status
        FROM user_applied_jobs
        WHERE user_id = $1
          AND job_id = $2
        LIMIT 1
      `,
      [userId, numericJobId],
    );

    if (existingApplication.rowCount > 0) {
      const existing = existingApplication.rows[0];

      return res.status(409).json({
        success: false,
        message: "You have already applied for this job",
        status: existing.status,
      });
    }

    // ========================================
    // CREATE APPLICATION
    // ========================================

    const applicationResult = await pool.query(
      `
        INSERT INTO user_applied_jobs
        (
          user_id,
          job_id,
          status
        )
        VALUES
        ($1, $2, 'processing')
        RETURNING
          id,
          user_id,
          job_id,
          status,
          created_at
      `,
      [userId, numericJobId],
    );

    const application = applicationResult.rows[0];

    console.log("\n========================================");
    console.log("APPLICATION CREATED");
    console.log("User ID:", application.user_id);
    console.log("Job ID:", application.job_id);
    console.log("Status:", application.status);
    console.log("========================================\n");

    return res.status(201).json({
      success: true,
      message: "Job applied successfully",
      application: {
        id: application.id,
        jobId: application.job_id,
        status: application.status,
        createdAt: application.created_at,
      },
    });
  } catch (err) {
    console.error("\n[APPLY] ❌ APPLY JOB ERROR");
    console.error(err);

    return res.status(500).json({
      success: false,
      message: "Failed to apply for job",
    });
  }
});

// ========================================
// GET USER'S APPLIED JOBS
// ========================================

router.get("/applied", async (req, res) => {
  console.log("\n========================================");
  console.log("FETCH APPLIED JOBS REQUEST");
  console.log("========================================");

  const { phone } = req.query;

  console.log("[APPLIED] Phone:", phone);

  try {
    // ========================================
    // VALIDATE PHONE
    // ========================================

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: "Phone number is required",
      });
    }

    // ========================================
    // NORMALIZE PHONE
    // ========================================

    let cleanPhone = phone.replace(/\D/g, "");

    if (cleanPhone.length === 12 && cleanPhone.startsWith("91")) {
      cleanPhone = cleanPhone.substring(2);
    }

    if (cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    console.log("[APPLIED] Clean phone:", cleanPhone);

    // ========================================
    // FIND USER
    // ========================================

    const userResult = await pool.query(
      `
        SELECT id
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone],
    );

    if (userResult.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    const userId = userResult.rows[0].id;

    console.log("[APPLIED] User ID:", userId);

    // ========================================
    // FETCH APPLIED JOBS
    // ========================================

    const result = await pool.query(
      `
    SELECT
      uaj.id AS application_id,
      uaj.job_id,
      uaj.status,
      uaj.created_at AS applied_at,

      j.name,
      j.company,
      j.salary_min,
      j.salary_max,
      j.job_type,
      j.work_location

    FROM user_applied_jobs uaj

    INNER JOIN jobs j
      ON j.id = uaj.job_id

    WHERE uaj.user_id = $1

    ORDER BY uaj.created_at DESC
  `,
      [userId],
    );

    console.log("[APPLIED] Applications found:", result.rowCount);

    return res.status(200).json({
      success: true,
      applications: result.rows,
    });
  } catch (err) {
    console.error("\n[APPLIED] ❌ FETCH APPLIED JOBS ERROR");
    console.error(err);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch applied jobs",
    });
  }
});

export default router;
