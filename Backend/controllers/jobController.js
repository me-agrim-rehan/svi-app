// Backend/controllers/jobController.js
import pool from "../db.js";

export const getJobs = async (req, res) => {
  try {
    const query = `
      SELECT
        jc.id AS category_id,
        jc.name AS category,
        jc.skill_type,

        COALESCE(
          json_agg(
            json_build_object(
              'id', jsc.id,
              'name', jsc.name
            )
            ORDER BY jsc.name
          ) FILTER (WHERE jsc.id IS NOT NULL),
          '[]'::json
        ) AS subcategories

      FROM job_category jc

      LEFT JOIN job_subcategory jsc
        ON jsc.job_category_id = jc.id
        AND jsc.is_active = TRUE

      WHERE jc.is_active = TRUE

      GROUP BY
        jc.id,
        jc.name,
        jc.skill_type

      ORDER BY jc.id;
    `;

    const result = await pool.query(query);

    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching jobs:", error);

    res.status(500).json({
      message: "Failed to fetch jobs",
    });
  }
};