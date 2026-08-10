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
          WHEN LOWER(TRIM(jc.name)) = ui.occupation THEN 1
          WHEN LOWER(TRIM(jc.skill_type)) = 'unskilled' THEN 2
          ELSE 3
        END AS recommendation_priority

      FROM public.jobs j

      INNER JOIN public.job_category jc
        ON jc.id = j.category_id

      INNER JOIN public.job_subcategory js
        ON js.id = j.subcategory_id

      CROSS JOIN user_info ui

      WHERE
        LOWER(TRIM(jc.name)) = ui.occupation
        OR LOWER(TRIM(jc.skill_type)) = 'unskilled'

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