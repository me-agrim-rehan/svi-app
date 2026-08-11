// Backend/controllers/recommendedJobController.js

import pool from "../db.js";

export const getRecommendedJobs = async (req, res) => {
  try {
    const { user_id } = req.query;

    if (!user_id) {
      return res.status(400).json({
        success: false,
        message: "user_id is required",
      });
    }

    const query = `
      WITH user_info AS (
        SELECT
          LOWER(TRIM(occupation)) AS occupation
        FROM public.user_details
        WHERE user_id = $1
        LIMIT 1
      )

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
        jc.skill_type,

        j.subcategory_id,
        js.name AS subcategory,

        j.no_of_openings,
        j.work_location,
        j.created_at,
        j.updated_at,

        CASE
          -- ============================================================
          -- PRIORITY 1: USER'S PREFERRED JOBS
          -- ============================================================
          WHEN EXISTS (
            SELECT 1
            FROM public.user_preferred_jobs upj
            WHERE upj.user_id = $1
              AND upj.job_subcategory_id = j.subcategory_id
          ) THEN 1

          -- ============================================================
          -- PRIORITY 2: USER'S OCCUPATION
          -- ============================================================
          WHEN LOWER(TRIM(jc.name)) = ui.occupation THEN 2

          -- ============================================================
          -- PRIORITY 3: UNSKILLED JOBS
          -- ============================================================
          WHEN LOWER(TRIM(jc.skill_type)) = 'unskilled' THEN 3

          ELSE 4
        END AS recommendation_priority

      FROM public.jobs j

      INNER JOIN public.job_category jc
        ON jc.id = j.category_id

      INNER JOIN public.job_subcategory js
        ON js.id = j.subcategory_id

      CROSS JOIN user_info ui

      WHERE
        (
          -- Preferred jobs
          EXISTS (
            SELECT 1
            FROM public.user_preferred_jobs upj
            WHERE upj.user_id = $1
              AND upj.job_subcategory_id = j.subcategory_id
          )

          OR

          -- Occupation jobs
          LOWER(TRIM(jc.name)) = ui.occupation

          OR

          -- Unskilled jobs
          LOWER(TRIM(jc.skill_type)) = 'unskilled'
        )

        -- ==============================================================
        -- NEVER SHOW A JOB THE USER HAS ALREADY APPLIED FOR
        -- ==============================================================

        AND NOT EXISTS (
          SELECT 1
          FROM public.user_applied_jobs uaj
          WHERE uaj.user_id = $1
            AND uaj.job_id = j.id
        )

      ORDER BY
        recommendation_priority ASC,
        j.created_at DESC;

    `;

    const result = await pool.query(query, [user_id]);

    res.status(200).json({
      success: true,
      count: result.rows.length,
      jobs: result.rows,
    });

  } catch (error) {
    console.error("Error fetching recommended jobs:", error);

    res.status(500).json({
      success: false,
      message: "Failed to fetch recommended jobs",
    });
  }
};