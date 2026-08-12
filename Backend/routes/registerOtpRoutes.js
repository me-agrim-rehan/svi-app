// Backend/routes/otpRoutes.js

import express from "express";
import twilioClient from "./twilio.js";
import pool from "../db.js";

const router = express.Router();


// ========================================
// Normalize Indian phone number
// ========================================

function normalizePhone(phone) {
  let cleanPhone = phone?.replace(/\D/g, "");

  // 919876543210 -> 9876543210
  if (cleanPhone?.length === 12 && cleanPhone.startsWith("91")) {
    cleanPhone = cleanPhone.substring(2);
  }

  return cleanPhone;
}


// Convert DB format to Twilio format
function toTwilioPhone(phone) {
  return `+91${phone}`;
}


// ========================================
// REGISTRATION - SEND OTP
// ========================================

router.post("/send-otp", async (req, res) => {
  try {
    const { phone } = req.body;

    console.log("\n========================================");
    console.log("REGISTRATION SEND OTP");
    console.log("========================================");

    console.log("[REGISTER] Raw phone:", phone);

    if (!phone) {
      return res.status(400).json({
        success: false,
        message: "Phone number is required",
      });
    }

    const cleanPhone = normalizePhone(phone);

    console.log("[REGISTER] Clean phone:", cleanPhone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }


    // ========================================
    // CHECK IF PHONE ALREADY EXISTS
    // ========================================

    console.log(
      "[REGISTER] Checking database for mobile:",
      cleanPhone
    );

    const result = await pool.query(
      `
        SELECT id
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone],
    );

    console.log(
      "[REGISTER] Database rows found:",
      result.rowCount
    );


    // ========================================
    // PHONE ALREADY REGISTERED
    // ========================================

    if (result.rowCount > 0) {
      console.log(
        "[REGISTER] ❌ Phone already registered:",
        cleanPhone
      );

      return res.status(409).json({
        success: false,
        message: "An account already exists with this phone number",
      });
    }


    // ========================================
    // PHONE NOT REGISTERED
    // → SEND OTP
    // ========================================

    console.log(
      "[REGISTER] ✅ Phone available for registration"
    );

    const twilioPhone = toTwilioPhone(cleanPhone);

    console.log(
      "[REGISTER] 📱 Sending OTP to:",
      twilioPhone
    );

    const verification =
      await twilioClient.verify.v2
        .services(process.env.TWILIO_VERIFY_SERVICE_SID)
        .verifications.create({
          to: twilioPhone,
          channel: "sms",
        });

    console.log(
      "[REGISTER] ✅ OTP sent"
    );

    console.log(
      "[REGISTER] Twilio status:",
      verification.status
    );

    return res.json({
      success: true,
      message: "OTP sent",
    });

  } catch (err) {
    console.error("[REGISTER] ❌ Send OTP error:", err);

    return res.status(500).json({
      success: false,
      message: "Failed to send OTP",
    });
  }
});


// ========================================
// REGISTRATION - VERIFY OTP
// ========================================

router.post("/verify-otp", async (req, res) => {
  try {
    const { phone, otp } = req.body;

    console.log("\n========================================");
    console.log("REGISTRATION VERIFY OTP");
    console.log("========================================");

    if (!phone || !otp) {
      return res.status(400).json({
        success: false,
        message: "Phone and OTP are required",
      });
    }

    const cleanPhone = normalizePhone(phone);

    console.log("[REGISTER] Clean phone:", cleanPhone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }


    // ========================================
    // MAKE SURE PHONE IS STILL AVAILABLE
    // ========================================

    const result = await pool.query(
      `
        SELECT id
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone],
    );

    if (result.rowCount > 0) {
      console.log(
        "[REGISTER] ❌ Phone is already registered"
      );

      return res.status(409).json({
        success: false,
        message: "An account already exists with this phone number",
      });
    }


    // ========================================
    // VERIFY TWILIO OTP
    // ========================================

    const twilioPhone = toTwilioPhone(cleanPhone);

    console.log(
      "[REGISTER] 🔐 Verifying OTP for:",
      twilioPhone
    );

    const verification =
      await twilioClient.verify.v2
        .services(process.env.TWILIO_VERIFY_SERVICE_SID)
        .verificationChecks.create({
          to: twilioPhone,
          code: otp,
        });

    console.log(
      "[REGISTER] Twilio verification status:",
      verification.status
    );


    if (verification.status !== "approved") {
      console.log("[REGISTER] ❌ Invalid OTP");

      return res.status(400).json({
        success: false,
        message: "Invalid OTP",
      });
    }


    // ========================================
    // OTP VERIFIED
    // ========================================

    console.log(
      "[REGISTER] ✅ OTP verified successfully"
    );

    return res.json({
      success: true,
      message: "OTP Verified",
    });

  } catch (err) {
    console.error(
      "[REGISTER] ❌ Verify OTP error:",
      err
    );

    return res.status(500).json({
      success: false,
      message: "Verification failed",
    });
  }
});


export default router;