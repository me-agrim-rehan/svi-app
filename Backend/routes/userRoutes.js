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
      u.mobile AS phone,
      u.name,
      ud.address,
      ud.city,
      ud.state,
      ud.occupation,
      ud.years_of_experience,
      ud.description,
      ud.live_photo_url
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
    console.log("[PROFILE] Name:", user.name);
    console.log("[PROFILE] Occupation:", user.occupation);
    console.log("[PROFILE] Years of experience:", user.years_of_experience);

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

    const preferredJobs = preferredJobsResult.rows.map((row) =>
      String(row.job_subcategory_id),
    );

    console.log("[PROFILE] Preferred jobs:", preferredJobs);

    return res.status(200).json({
      success: true,
      user_id: user.user_id,
      phone: user.phone ?? "",
      name: user.name ?? "",
      address: user.address ?? "",
      city: user.city ?? "",
      state: user.state ?? "",
      occupation_category: user.occupation ?? "",
      years_of_experience: user.years_of_experience ?? "",
      description: user.description ?? "",
      preferred_jobs: preferredJobs,
      profile_photo_url: user.live_photo_url ?? "",
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
// PATCH /users/profile
router.patch("/profile", async (req, res) => {
  const client = await pool.connect();

  try {
    const {
      phone,
      name,
      address,
      city,
      state,
      occupation,
      years_of_experience,
      description,
      preferred_jobs,
    } = req.body;

    // ========================================
    // VALIDATE PHONE
    // ========================================

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

    // ========================================
    // FIND USER
    // ========================================

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

    // ========================================
    // START TRANSACTION
    // ========================================

    await client.query("BEGIN");

    // ========================================
    // UPDATE USER TABLE
    // ========================================
    // Currently only name belongs to users table.

    if (name !== undefined) {
      await client.query(
        `
          UPDATE public.users
          SET name = $1
          WHERE id = $2
        `,
        [name, userId],
      );
    }

    // ========================================
    // UPDATE USER DETAILS
    // ========================================

    const updates = [];
    const values = [];

    if (address !== undefined) {
      updates.push(`address = $${values.length + 1}`);
      values.push(address);
    }

    if (city !== undefined) {
      updates.push(`city = $${values.length + 1}`);
      values.push(city);
    }

    if (state !== undefined) {
      updates.push(`state = $${values.length + 1}`);
      values.push(state);
    }

    if (occupation !== undefined) {
      updates.push(`occupation = $${values.length + 1}`);
      values.push(occupation);
    }

    if (years_of_experience !== undefined) {
      updates.push(`years_of_experience = $${values.length + 1}`);
      values.push(years_of_experience);
    }

    if (description !== undefined) {
      updates.push(`description = $${values.length + 1}`);
      values.push(description);
    }

    if (updates.length > 0) {
      values.push(userId);

      await client.query(
        `
          UPDATE public.user_details
          SET ${updates.join(", ")},
              updated_at = NOW()
          WHERE user_id = $${values.length}
        `,
        values,
      );
    }

    // ========================================
    // UPDATE PREFERRED JOBS
    // ========================================

    if (preferred_jobs !== undefined) {
      if (!Array.isArray(preferred_jobs)) {
        await client.query("ROLLBACK");

        return res.status(400).json({
          success: false,
          message: "preferred_jobs must be an array",
        });
      }

      // Convert IDs to numbers
      const parsedPreferredJobs = preferred_jobs.map((jobId) =>
        Number(jobId),
      );

      // Validate IDs
      const invalidJobIds = parsedPreferredJobs.some(
        (jobId) => !Number.isInteger(jobId),
      );

      if (invalidJobIds) {
        await client.query("ROLLBACK");

        return res.status(400).json({
          success: false,
          message: "Preferred job IDs must be integers",
        });
      }

      // Remove duplicates
      const uniquePreferredJobs = [...new Set(parsedPreferredJobs)];

      // Maximum 10
      if (uniquePreferredJobs.length > 10) {
        await client.query("ROLLBACK");

        return res.status(400).json({
          success: false,
          message: "You can select up to 10 preferred jobs",
        });
      }

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

      console.log(
        "[PROFILE] Updated preferred jobs:",
        uniquePreferredJobs,
      );
    }

    // ========================================
    // COMMIT
    // ========================================

    await client.query("COMMIT");

    console.log("[PROFILE] Profile updated:", {
      userId,
      name,
      address,
      city,
      state,
      occupation,
      years_of_experience,
      description,
      preferred_jobs,
    });

    return res.status(200).json({
      success: true,
      message: "Profile updated successfully",
    });

  } catch (error) {
    await client.query("ROLLBACK");

    console.error("[PROFILE] Update error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update profile",
    });

  } finally {
    client.release();
  }
});

export default router;
