// Backend/routes/temp/tempRegisterOtpRoutes.js
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
// REGISTER - SEND TEMP OTP
// ========================================

router.post("/send-otp", async (req, res) => {
  try {
    const { phone } = req.body;

    console.log("\n========================================");
    console.log("TEMP REGISTER SEND OTP");
    console.log("========================================");

    const cleanPhone = normalizePhone(phone);

    console.log("[TEMP REGISTER] Phone:", cleanPhone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    // Check if already registered
    const result = await pool.query(
      `
        SELECT id
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone]
    );

    if (result.rowCount > 0) {
      console.log(
        "[TEMP REGISTER] ❌ Phone already registered"
      );

      return res.status(409).json({
        success: false,
        message: "An account already exists with this phone number",
      });
    }

    // Generate temporary OTP
    generateOtp(cleanPhone);

    return res.json({
      success: true,
      message: "OTP sent",
    });

  } catch (err) {
    console.error("[TEMP REGISTER] ❌ ERROR:", err);

    return res.status(500).json({
      success: false,
      message: "Failed to send OTP",
    });
  }
});

// ========================================
// REGISTER - VERIFY TEMP OTP
// ========================================

router.post("/verify-otp", async (req, res) => {
  try {
    const { phone, otp } = req.body;

    console.log("\n========================================");
    console.log("TEMP REGISTER VERIFY OTP");
    console.log("========================================");

    const cleanPhone = normalizePhone(phone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    // Make sure phone hasn't been registered meanwhile
    const result = await pool.query(
      `
        SELECT id
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone]
    );

    if (result.rowCount > 0) {
      return res.status(409).json({
        success: false,
        message: "An account already exists with this phone number",
      });
    }

    // Verify OTP
    const verification = checkOtp(cleanPhone, otp);

    if (!verification.success) {
      console.log(
        "[TEMP REGISTER] ❌",
        verification.message
      );

      return res.status(400).json({
        success: false,
        message: verification.message,
      });
    }

    console.log(
      "[TEMP REGISTER] ✅ OTP VERIFIED"
    );

    return res.json({
      success: true,
      message: "OTP Verified",
    });

  } catch (err) {
    console.error(
      "[TEMP REGISTER] ❌ VERIFY ERROR:",
      err
    );

    return res.status(500).json({
      success: false,
      message: "Verification failed",
    });
  }
});

export default router;