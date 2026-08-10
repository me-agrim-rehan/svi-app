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

    return res.status(200).json({
      success: true,
      user_id: user.user_id,
      occupation_category: user.occupation ?? "",
      preferred_jobs: [],
    });
  } catch (error) {
    console.error("[PROFILE] Error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to fetch user profile",
    });
  }
});

export default router;