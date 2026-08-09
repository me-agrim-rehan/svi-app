import express from "express";
import twilioClient from "./twilio.js";
import pool from "../db.js";

const router = express.Router();


// ========================================
// Normalize Indian phone number
// ========================================

function normalizePhone(phone) {
  let cleanPhone = phone?.replace(/\D/g, "");

  if (cleanPhone?.length === 12 && cleanPhone.startsWith("91")) {
    cleanPhone = cleanPhone.substring(2);
  }

  return cleanPhone;
}


// ========================================
// Convert to Twilio format
// ========================================

function toTwilioPhone(phone) {
  return `+91${phone}`;
}


// ========================================
// LOGIN - SEND OTP
// ========================================

router.post("/send-otp", async (req, res) => {
  console.log("\n========================================");
  console.log("LOGIN SEND OTP REQUEST");
  console.log("========================================");

  try {
    const { phone } = req.body;

    console.log("[LOGIN] Raw phone:", phone);

    if (!phone) {
      console.log("[LOGIN] ❌ Phone number missing");

      return res.status(400).json({
        success: false,
        message: "Phone number is required",
      });
    }

    // Normalize
    const cleanPhone = normalizePhone(phone);

    console.log("[LOGIN] Clean phone:", cleanPhone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      console.log("[LOGIN] ❌ Invalid phone format");

      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    // ========================================
    // DATABASE LOOKUP
    // ========================================

    console.log(
      "[LOGIN] 🔎 Checking database for mobile:",
      cleanPhone
    );

    const result = await pool.query(
      `
        SELECT id, mobile
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone],
    );

    console.log(
      "[LOGIN] Database rows found:",
      result.rowCount
    );

    if (result.rowCount === 0) {
      console.log(
        "[LOGIN] ❌ USER NOT FOUND:",
        cleanPhone
      );

      return res.status(404).json({
        success: false,
        message: "No account found with this phone number",
      });
    }

    const user = result.rows[0];

    console.log("[LOGIN] ✅ USER FOUND");
    console.log("[LOGIN] User ID:", user.id);
    console.log("[LOGIN] DB mobile:", user.mobile);

    // ========================================
    // SEND TWILIO OTP
    // ========================================

    const twilioPhone = toTwilioPhone(cleanPhone);

    console.log(
      "[LOGIN] 📱 Sending OTP through Twilio to:",
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
      "[LOGIN] ✅ Twilio OTP sent"
    );

    console.log(
      "[LOGIN] Twilio verification status:",
      verification.status
    );

    return res.json({
      success: true,
      message: "OTP sent",
    });

  } catch (err) {
    console.error("\n[LOGIN] ❌ SEND OTP ERROR");
    console.error(err);

    return res.status(500).json({
      success: false,
      message: "Failed to send OTP",
    });
  }
});


// ========================================
// LOGIN - VERIFY OTP
// ========================================

router.post("/verify-otp", async (req, res) => {
  console.log("\n========================================");
  console.log("LOGIN VERIFY OTP REQUEST");
  console.log("========================================");

  try {
    const { phone, otp } = req.body;

    console.log("[LOGIN] Raw phone:", phone);
    console.log("[LOGIN] OTP received:", otp ? "YES" : "NO");

    if (!phone || !otp) {
      console.log("[LOGIN] ❌ Phone or OTP missing");

      return res.status(400).json({
        success: false,
        message: "Phone and OTP are required",
      });
    }

    // Normalize phone
    const cleanPhone = normalizePhone(phone);

    console.log("[LOGIN] Clean phone:", cleanPhone);

    if (!cleanPhone || cleanPhone.length !== 10) {
      console.log("[LOGIN] ❌ Invalid phone format");

      return res.status(400).json({
        success: false,
        message: "Phone number must contain exactly 10 digits",
      });
    }

    // ========================================
    // DATABASE LOOKUP
    // ========================================

    console.log(
      "[LOGIN] 🔎 Checking database for mobile:",
      cleanPhone
    );

    const result = await pool.query(
      `
        SELECT id, mobile
        FROM users
        WHERE mobile = $1
        LIMIT 1
      `,
      [cleanPhone],
    );

    console.log(
      "[LOGIN] Database rows found:",
      result.rowCount
    );

    if (result.rowCount === 0) {
      console.log(
        "[LOGIN] ❌ USER NOT FOUND:",
        cleanPhone
      );

      return res.status(404).json({
        success: false,
        message: "No account found with this phone number",
      });
    }

    const user = result.rows[0];

    console.log("[LOGIN] ✅ USER FOUND");
    console.log("[LOGIN] User ID:", user.id);
    console.log("[LOGIN] DB mobile:", user.mobile);

    // ========================================
    // VERIFY TWILIO OTP
    // ========================================

    const twilioPhone = toTwilioPhone(cleanPhone);

    console.log(
      "[LOGIN] 🔐 Verifying OTP with Twilio for:",
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
      "[LOGIN] Twilio verification status:",
      verification.status
    );

    if (verification.status !== "approved") {
      console.log(
        "[LOGIN] ❌ INVALID OTP for:",
        cleanPhone
      );

      return res.status(400).json({
        success: false,
        message: "Invalid OTP",
      });
    }

    // ========================================
    // LOGIN SUCCESS
    // ========================================

    console.log("\n========================================");
    console.log("✅ LOGIN SUCCESS");
    console.log("User ID:", user.id);
    console.log("Mobile:", user.mobile);
    console.log("========================================\n");

    return res.json({
      success: true,
      message: "Login successful",
      userId: user.id,
    });

  } catch (err) {
    console.error("\n[LOGIN] ❌ VERIFY OTP ERROR");
    console.error(err);

    return res.status(500).json({
      success: false,
      message: "Login failed",
    });
  }
});


export default router;