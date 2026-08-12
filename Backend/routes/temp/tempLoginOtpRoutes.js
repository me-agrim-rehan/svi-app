// backend/routes/temp/tempLoginOtpRoutes.js
import express from "express";
import pool from "../../db.js";
import { generateOtp, checkOtp } from "../../utils/tempOtp.js";

const router = express.Router();

function normalizePhone(phone) {
  let cleanPhone = phone?.replace(/\D/g, "");

  if (cleanPhone?.length === 12 && cleanPhone.startsWith("91")) {
    cleanPhone = cleanPhone.substring(2);
  }

  return cleanPhone;
}

// ========================================
// LOGIN - SEND TEMP OTP
// ========================================

router.post("/send-otp", async (req, res) => {
  try {
    const { phone } = req.body;

    console.log("\n========================================");
    console.log("TEMP LOGIN SEND OTP");
    console.log("========================================");

    const cleanPhone = normalizePhone(phone);

    console.log("[TEMP LOGIN] Phone:", cleanPhone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    // Check user exists
    const result = await pool.query(
      `
        SELECT id, mobile
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone]
    );

    console.log(
      "[TEMP LOGIN] Database rows found:",
      result.rowCount
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "No account found with this phone number",
      });
    }

    const user = result.rows[0];

    console.log("[TEMP LOGIN] ✅ USER FOUND");
    console.log("[TEMP LOGIN] User ID:", user.id);

    // Generate OTP and print it in terminal
    generateOtp(cleanPhone);

    return res.json({
      success: true,
      message: "OTP sent",
    });

  } catch (err) {
    console.error("[TEMP LOGIN] ❌ ERROR:", err);

    return res.status(500).json({
      success: false,
      message: "Failed to send OTP",
    });
  }
});

// ========================================
// LOGIN - VERIFY TEMP OTP
// ========================================

router.post("/verify-otp", async (req, res) => {
  try {
    const { phone, otp } = req.body;

    console.log("\n========================================");
    console.log("TEMP LOGIN VERIFY OTP");
    console.log("========================================");

    const cleanPhone = normalizePhone(phone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    // Make sure user still exists
    const result = await pool.query(
      `
        SELECT id, mobile
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "No account found with this phone number",
      });
    }

    const user = result.rows[0];

    // Verify temporary OTP
    const verification = checkOtp(cleanPhone, otp);

    if (!verification.success) {
      console.log(
        "[TEMP LOGIN] ❌",
        verification.message
      );

      return res.status(400).json({
        success: false,
        message: verification.message,
      });
    }

    console.log("\n========================================");
    console.log("✅ TEMP LOGIN SUCCESS");
    console.log("User ID:", user.id);
    console.log("Mobile:", user.mobile);
    console.log("========================================\n");

    return res.json({
      success: true,
      message: "Login successful",
      userId: user.id,
    });

  } catch (err) {
    console.error("[TEMP LOGIN] ❌ VERIFY ERROR:", err);

    return res.status(500).json({
      success: false,
      message: "Login failed",
    });
  }
});

export default router;