import express from "express";
import pool from "../../db.js";
import { adminAuthMiddleware } from "../../middleware/adminside/adminAuthMiddleware.js";

const router = express.Router();

// ============================================================
// GET JOB CATEGORIES + SUBCATEGORIES
// ============================================================

router.get("/meta", adminAuthMiddleware, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        jc.id AS category_id,
        jc.name AS category_name,
        jc.skill_type,
        jc.is_active AS category_active,

        js.id AS subcategory_id,
        js.name AS subcategory_name,
        js.is_active AS subcategory_active

      FROM job_category jc

      LEFT JOIN job_subcategory js
        ON js.job_category_id = jc.id

      WHERE jc.is_active = true

      ORDER BY
        jc.name,
        js.name
    `);

    const categories = {};

    for (const row of result.rows) {
      if (!categories[row.category_id]) {
        categories[row.category_id] = {
          id: row.category_id,
          name: row.category_name,
          skill_type: row.skill_type,
          subcategories: [],
        };
      }

      if (row.subcategory_id !== null && row.subcategory_active) {
        categories[row.category_id].subcategories.push({
          id: row.subcategory_id,
          name: row.subcategory_name,
        });
      }
    }

    return res.status(200).json({
      success: true,
      categories: Object.values(categories),
    });
  } catch (error) {
    console.error("Admin job metadata error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch job categories",
    });
  }
});

// ============================================================
// CREATE JOB
// ============================================================

router.post("/", adminAuthMiddleware, async (req, res) => {
  try {
    const {
      name,
      company,
      description,
      salary_min,
      salary_max,
      job_type,
      category_id,
      subcategory_id,
      no_of_openings,
      work_location,
    } = req.body;

    // --------------------------------------------------------
    // Required fields
    // --------------------------------------------------------

    if (
      !name ||
      !company ||
      !description ||
      !job_type ||
      !category_id ||
      !subcategory_id ||
      !no_of_openings ||
      !work_location
    ) {
      return res.status(400).json({
        success: false,
        message: "All required job fields must be provided",
      });
    }

    // --------------------------------------------------------
    // Validate job type
    // --------------------------------------------------------

    const allowedJobTypes = ["full_time", "part_time", "contract"];

    if (!allowedJobTypes.includes(job_type)) {
      return res.status(400).json({
        success: false,
        message: "Invalid job type",
      });
    }

    // --------------------------------------------------------
    // Validate openings
    // --------------------------------------------------------

    const openings = Number(no_of_openings);

    if (!Number.isInteger(openings) || openings <= 0) {
      return res.status(400).json({
        success: false,
        message: "Number of openings must be greater than 0",
      });
    }

    // --------------------------------------------------------
    // Validate salary
    // --------------------------------------------------------

    let salaryMin = null;
    let salaryMax = null;

    if (salary_min !== "" && salary_min !== null && salary_min !== undefined) {
      salaryMin = Number(salary_min);

      if (!Number.isFinite(salaryMin) || salaryMin < 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid minimum salary",
        });
      }
    }

    if (salary_max !== "" && salary_max !== null && salary_max !== undefined) {
      salaryMax = Number(salary_max);

      if (!Number.isFinite(salaryMax) || salaryMax < 0) {
        return res.status(400).json({
          success: false,
          message: "Invalid maximum salary",
        });
      }
    }

    if (salaryMin !== null && salaryMax !== null && salaryMin > salaryMax) {
      return res.status(400).json({
        success: false,
        message: "Minimum salary cannot be greater than maximum salary",
      });
    }

    // --------------------------------------------------------
    // Validate category + subcategory relationship
    // --------------------------------------------------------

    const categoryCheck = await pool.query(
      `
      SELECT
        js.id
      FROM job_subcategory js
      WHERE js.id = $1
        AND js.job_category_id = $2
        AND js.is_active = true
      LIMIT 1
      `,
      [subcategory_id, category_id],
    );

    if (categoryCheck.rows.length === 0) {
      return res.status(400).json({
        success: false,
        message: "Invalid category or subcategory",
      });
    }

    // --------------------------------------------------------
    // Create job
    // --------------------------------------------------------

    const result = await pool.query(
      `
      INSERT INTO jobs (
        name,
        company,
        description,
        salary_min,
        salary_max,
        job_type,
        category_id,
        subcategory_id,
        no_of_openings,
        work_location
      )
      VALUES (
        $1,
        $2,
        $3,
        $4,
        $5,
        $6,
        $7,
        $8,
        $9,
        $10
      )
      RETURNING
        id,
        name,
        company,
        description,
        salary_min,
        salary_max,
        job_type,
        category_id,
        subcategory_id,
        no_of_openings,
        work_location,
        created_at,
        updated_at
      `,
      [
        name.trim(),
        company.trim(),
        description.trim(),
        salaryMin,
        salaryMax,
        job_type,
        category_id,
        subcategory_id,
        openings,
        work_location.trim(),
      ],
    );

    return res.status(201).json({
      success: true,
      message: "Job created successfully",
      job: result.rows[0],
    });
  } catch (error) {
    console.error("Admin create job error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to create job",
    });
  }
});

// ============================================================
// GET ALL JOBS
// ============================================================

router.get("/", adminAuthMiddleware, async (req, res) => {
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
        j.subcategory_id,
        j.no_of_openings,
        j.work_location,
        j.created_at,
        j.updated_at,

        jc.name AS category_name,
        jc.skill_type,

        js.name AS subcategory_name

      FROM jobs j

      LEFT JOIN job_category jc
        ON jc.id = j.category_id

      LEFT JOIN job_subcategory js
        ON js.id = j.subcategory_id

      ORDER BY j.created_at DESC
    `);

    return res.status(200).json({
      success: true,
      jobs: result.rows,
    });
  } catch (error) {
    console.error("Admin fetch jobs error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch jobs",
    });
  }
});

export default router;
