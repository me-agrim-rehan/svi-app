import express from "express";
import pool from "../../db.js";
import { adminAuthMiddleware } from "../../middleware/adminside/adminAuthMiddleware.js";

const router = express.Router();

// ============================================================
// GET ALL JOB APPLICATIONS
// ============================================================

router.get("/", adminAuthMiddleware, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        j.id AS job_id,
        j.name AS job_name,
        j.company,
        j.description,
        j.salary_min,
        j.salary_max,
        j.job_type,
        j.no_of_openings,
        j.work_location,
        j.created_at,

        jc.id AS category_id,
        jc.name AS category_name,

        js.id AS subcategory_id,
        js.name AS occupation,

        COUNT(uaj.id)::integer AS application_count

      FROM jobs j

      LEFT JOIN job_category jc
        ON jc.id = j.category_id

      LEFT JOIN job_subcategory js
        ON js.id = j.subcategory_id

      LEFT JOIN user_applied_jobs uaj
        ON uaj.job_id = j.id

      GROUP BY
        j.id,
        jc.id,
        jc.name,
        js.id,
        js.name

      ORDER BY
        js.name ASC,
        j.created_at DESC
    `);

    return res.status(200).json({
      success: true,
      count: result.rows.length,
      jobs: result.rows,
    });
  } catch (error) {
    console.error("Admin fetch application jobs error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch application jobs",
    });
  }
});

// ============================================================
// GET APPLICATIONS FOR ONE JOB
// ============================================================

router.get("/job/:jobId", adminAuthMiddleware, async (req, res) => {
  try {
    const { jobId } = req.params;

    const result = await pool.query(
      `
      SELECT

        -- ====================================================
        -- JOB
        -- ====================================================

        j.id AS job_id,
        j.name AS job_name,
        j.company,
        j.description,
        j.salary_min,
        j.salary_max,
        j.job_type,
        j.no_of_openings,
        j.work_location,
        j.created_at AS job_created_at,

        jc.id AS category_id,
        jc.name AS category_name,
        jc.skill_type,

        js.id AS subcategory_id,
        js.name AS occupation,

        -- ====================================================
        -- APPLICATION
        -- ====================================================

        uaj.id AS application_id,
        uaj.status,
        uaj.created_at AS applied_at,
        uaj.updated_at,

        -- ====================================================
        -- USER
        -- ====================================================

        u.id AS user_id,
        u.name AS applicant_name,
        u.mobile AS applicant_mobile,
        u.is_mobile_verified,

        -- ====================================================
        -- USER DETAILS
        -- ====================================================

        ud.occupation AS applicant_occupation,
        ud.years_of_experience,
        ud.address,
        ud.city,
        ud.state

      FROM jobs j

      LEFT JOIN job_category jc
        ON jc.id = j.category_id

      LEFT JOIN job_subcategory js
        ON js.id = j.subcategory_id

      LEFT JOIN user_applied_jobs uaj
        ON uaj.job_id = j.id

      LEFT JOIN users u
        ON u.id = uaj.user_id

      LEFT JOIN user_details ud
        ON ud.user_id = u.id

      WHERE j.id = $1

      ORDER BY
        uaj.created_at DESC
      `,
      [jobId],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "Job not found",
      });
    }

    const firstRow = result.rows[0];

    const job = {
      id: firstRow.job_id,
      name: firstRow.job_name,
      company: firstRow.company,
      description: firstRow.description,
      salary_min: firstRow.salary_min,
      salary_max: firstRow.salary_max,
      job_type: firstRow.job_type,
      no_of_openings: firstRow.no_of_openings,
      work_location: firstRow.work_location,
      created_at: firstRow.job_created_at,

      category_id: firstRow.category_id,
      category_name: firstRow.category_name,
      skill_type: firstRow.skill_type,

      subcategory_id: firstRow.subcategory_id,
      occupation: firstRow.occupation,
    };

    const applicants = result.rows
      .filter((row) => row.application_id !== null)
      .map((row) => ({
        application_id: row.application_id,
        status: row.status,
        applied_at: row.applied_at,
        updated_at: row.updated_at,

        user_id: row.user_id,
        applicant_name: row.applicant_name,
        applicant_mobile: row.applicant_mobile,
        is_mobile_verified: row.is_mobile_verified,

        applicant_occupation: row.applicant_occupation,
        years_of_experience: row.years_of_experience,
        address: row.address,
        city: row.city,
        state: row.state,
      }));

    return res.status(200).json({
      success: true,
      job,
      application_count: applicants.length,
      applicants,
    });
  } catch (error) {
    console.error("Admin fetch job applications error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch job applications",
    });
  }
});

export default router;
