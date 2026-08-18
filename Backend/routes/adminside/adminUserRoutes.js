import express from "express";
import pool from "../../db.js";
import { adminAuthMiddleware } from "../../middleware/adminside/adminAuthMiddleware.js";

const router = express.Router();

router.get("/", adminAuthMiddleware, async (req, res) => {
  try {
    const result = await pool.query(`
      WITH preferred_jobs AS (
        SELECT
          upj.user_id,
          jsonb_agg(
            jsonb_build_object(
              'id', js.id,
              'name', js.name,
              'category', jc.name
            )
            ORDER BY js.name
          ) AS jobs
        FROM user_preferred_jobs upj
        JOIN job_subcategory js
          ON js.id = upj.job_subcategory_id
        JOIN job_category jc
          ON jc.id = js.job_category_id
        GROUP BY upj.user_id
      ),

      applied_jobs AS (
        SELECT
          uaj.user_id,
          jsonb_agg(
            jsonb_build_object(
              'application_id', uaj.id,
              'job_id', j.id,
              'job_name', j.name,
              'company', j.company,
              'status', uaj.status,
              'created_at', uaj.created_at
            )
            ORDER BY uaj.created_at DESC
          ) AS jobs
        FROM user_applied_jobs uaj
        JOIN jobs j
          ON j.id = uaj.job_id
        GROUP BY uaj.user_id
      ),

      documents AS (
        SELECT
          ud.user_id,
          jsonb_agg(
            jsonb_build_object(
              'id', ud.id,
              'name', ud.document_name,
              'type', ud.document_type,
              'url', ud.file_url,
              'uploaded_at', ud.uploaded_at
            )
            ORDER BY ud.uploaded_at DESC
          ) AS documents
        FROM user_documents ud
        GROUP BY ud.user_id
      ),

      signed_documents AS (
        SELECT
          u.id AS user_id,
          jsonb_agg(
            jsonb_build_object(
              'id', usd.id,
              'type', usd.document_type,
              'url', usd.file_url,
              'uploaded_at', usd.uploaded_at
            )
            ORDER BY usd.uploaded_at DESC
          ) AS documents
        FROM users u
        JOIN user_signed_documents usd
          ON usd.phone = u.mobile
        GROUP BY u.id
      )

      SELECT
        u.id,
        u.name,
        u.mobile,
        u.is_mobile_verified,
        u.created_at,
        u.updated_at,

        CASE
          WHEN ud.id IS NULL THEN NULL
          ELSE jsonb_build_object(
            'id', ud.id,
            'address', ud.address,
            'city', ud.city,
            'state', ud.state,
            'occupation', ud.occupation,
            'description', ud.description,
            'aadhaar_number', ud.aadhaar_number,
            'aadhaar_photo_url', ud.aadhaar_photo_url,
            'live_photo_url', ud.live_photo_url,
            'years_of_experience', ud.years_of_experience,
            'created_at', ud.created_at,
            'updated_at', ud.updated_at
          )
        END AS details,

        COALESCE(pj.jobs, '[]'::jsonb) AS preferred_jobs,

        COALESCE(aj.jobs, '[]'::jsonb) AS applied_jobs,

        COALESCE(d.documents, '[]'::jsonb) AS documents,

        COALESCE(sd.documents, '[]'::jsonb) AS signed_documents

      FROM users u

      LEFT JOIN user_details ud
        ON ud.user_id = u.id

      LEFT JOIN preferred_jobs pj
        ON pj.user_id = u.id

      LEFT JOIN applied_jobs aj
        ON aj.user_id = u.id

      LEFT JOIN documents d
        ON d.user_id = u.id

      LEFT JOIN signed_documents sd
        ON sd.user_id = u.id

      ORDER BY u.created_at DESC
    `);

    return res.status(200).json({
      success: true,
      users: result.rows,
    });
  } catch (error) {
    console.error("Admin fetch users error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch users",
    });
  }
});

router.get("/:userId", adminAuthMiddleware, async (req, res) => {
  try {
    const { userId } = req.params;

    const result = await pool.query(
      `
      SELECT
        u.id,
        u.name,
        u.mobile,
        u.is_mobile_verified,
        u.created_at,
        u.updated_at,

        CASE
          WHEN ud.id IS NULL THEN NULL
          ELSE jsonb_build_object(
            'id', ud.id,
            'address', ud.address,
            'city', ud.city,
            'state', ud.state,
            'occupation', ud.occupation,
            'description', ud.description,
            'aadhaar_number', ud.aadhaar_number,
            'aadhaar_photo_url', ud.aadhaar_photo_url,
            'live_photo_url', ud.live_photo_url,
            'years_of_experience', ud.years_of_experience,
            'created_at', ud.created_at,
            'updated_at', ud.updated_at
          )
        END AS details,

        COALESCE(
          (
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', js.id,
                'name', js.name,
                'category', jc.name
              )
              ORDER BY js.name
            )
            FROM user_preferred_jobs upj
            JOIN job_subcategory js
              ON js.id = upj.job_subcategory_id
            JOIN job_category jc
              ON jc.id = js.job_category_id
            WHERE upj.user_id = u.id
          ),
          '[]'::jsonb
        ) AS preferred_jobs,

        COALESCE(
          (
            SELECT jsonb_agg(
              jsonb_build_object(
                'application_id', uaj.id,
                'job_id', j.id,
                'job_name', j.name,
                'company', j.company,
                'status', uaj.status,
                'created_at', uaj.created_at
              )
              ORDER BY uaj.created_at DESC
            )
            FROM user_applied_jobs uaj
            JOIN jobs j
              ON j.id = uaj.job_id
            WHERE uaj.user_id = u.id
          ),
          '[]'::jsonb
        ) AS applied_jobs,

        COALESCE(
          (
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', doc.id,
                'name', doc.document_name,
                'type', doc.document_type,
                'url', doc.file_url,
                'uploaded_at', doc.uploaded_at
              )
              ORDER BY doc.uploaded_at DESC
            )
            FROM user_documents doc
            WHERE doc.user_id = u.id
          ),
          '[]'::jsonb
        ) AS documents,

        COALESCE(
          (
            SELECT jsonb_agg(
              jsonb_build_object(
                'id', sd.id,
                'type', sd.document_type,
                'url', sd.file_url,
                'uploaded_at', sd.uploaded_at
              )
              ORDER BY sd.uploaded_at DESC
            )
            FROM user_signed_documents sd
            WHERE sd.phone = u.mobile
          ),
          '[]'::jsonb
        ) AS signed_documents

      FROM users u

      LEFT JOIN user_details ud
        ON ud.user_id = u.id

      WHERE u.id = $1
      LIMIT 1
      `,
      [userId],
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    return res.status(200).json({
      success: true,
      user: result.rows[0],
    });
  } catch (error) {
    console.error("Admin fetch user error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch user",
    });
  }
});

export default router;
