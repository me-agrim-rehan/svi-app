import express from "express";
import pool from "../db.js";

const router = express.Router();

function normalizePhone(phone) {
  let cleanPhone = phone?.replace(/\D/g, "");

  if (cleanPhone?.length === 12 && cleanPhone.startsWith("91")) {
    cleanPhone = cleanPhone.substring(2);
  }

  return cleanPhone;
}

// GET /users/profile?phone=+919149501021
router.get("/profile", async (req, res) => {
  try {
    const { phone } = req.query;

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: "Phone number is required",
      });
    }

    const cleanPhone = normalizePhone(phone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    const result = await pool.query(
      `
        SELECT
          u.id AS user_id,
          ud.occupation
        FROM public.users u
        INNER JOIN public.user_details ud
          ON ud.user_id = u.id
        WHERE u.mobile = $1
        LIMIT 1
      `,
      [cleanPhone],
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "User profile not found",
      });
    }

    const user = result.rows[0];

    console.log("[PROFILE] User ID:", user.user_id);
    console.log("[PROFILE] Occupation:", user.occupation);

    // Get user's preferred job subcategory IDs
    const preferredJobsResult = await pool.query(
      `
        SELECT job_subcategory_id
        FROM public.user_preferred_jobs
        WHERE user_id = $1
        ORDER BY created_at
      `,
      [user.user_id],
    );

    const preferredJobs = preferredJobsResult.rows.map(
      (row) => String(row.job_subcategory_id),
    );

    console.log("[PROFILE] Preferred jobs:", preferredJobs);

    return res.status(200).json({
      success: true,
      user_id: user.user_id,
      occupation_category: user.occupation ?? "",
      preferred_jobs: preferredJobs,
    });
  } catch (error) {
    console.error("[PROFILE] Error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch user profile",
    });
  }
});

// PATCH /users/profile
router.patch("/profile", async (req, res) => {
  const client = await pool.connect();

  try {
    const { phone, preferred_jobs } = req.body;

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: "Phone number is required",
      });
    }

    const cleanPhone = normalizePhone(phone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    if (!Array.isArray(preferred_jobs)) {
      return res.status(400).json({
        success: false,
        message: "preferred_jobs must be an array",
      });
    }

    // Convert IDs to numbers
    const parsedPreferredJobs = preferred_jobs.map((jobId) =>
      Number(jobId),
    );

    // Make sure every ID is a valid integer
    const invalidJobIds = parsedPreferredJobs.some(
      (jobId) => !Number.isInteger(jobId),
    );

    if (invalidJobIds) {
      return res.status(400).json({
        success: false,
        message: "Preferred job IDs must be integers",
      });
    }

    // Remove duplicate IDs
    const uniquePreferredJobs = [...new Set(parsedPreferredJobs)];

    // Optional safety limit
    if (uniquePreferredJobs.length > 10) {
      return res.status(400).json({
        success: false,
        message: "You can select up to 10 preferred jobs",
      });
    }

    // Verify user exists
    const userResult = await client.query(
      `
        SELECT id
        FROM public.users
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

    await client.query("BEGIN");

    // Remove existing preferred jobs
    await client.query(
      `
        DELETE FROM public.user_preferred_jobs
        WHERE user_id = $1
      `,
      [userId],
    );

    // Insert new preferred jobs
    for (const jobSubcategoryId of uniquePreferredJobs) {
      await client.query(
        `
          INSERT INTO public.user_preferred_jobs
          (
            user_id,
            job_subcategory_id
          )
          VALUES
          ($1, $2)
        `,
        [userId, jobSubcategoryId],
      );
    }

    await client.query("COMMIT");

    console.log(
      "[PROFILE] Updated preferred jobs:",
      uniquePreferredJobs,
    );

    return res.status(200).json({
      success: true,
      message: "Preferred jobs updated successfully",
      preferred_jobs: uniquePreferredJobs.map(String),
    });
  } catch (error) {
    await client.query("ROLLBACK");

    console.error("[PROFILE] Update error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update preferred jobs",
    });
  } finally {
    client.release();
  }
});

export default router;