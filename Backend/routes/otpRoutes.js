// Backend/routes/otpRoutes.js
import express from "express";
import twilioClient from "./twilio.js";

const router = express.Router();

router.post("/send-otp", async (req, res) => {
  try {
    const { phone } = req.body;

    await twilioClient.verify.v2
      .services(process.env.TWILIO_VERIFY_SERVICE_SID)
      .verifications.create({
        to: phone,
        channel: "sms",
      });

    res.json({
      success: true,
      message: "OTP sent",
    });
  } catch (err) {
    console.error(err);

    res.status(500).json({
      success: false,
      message: "Failed to send OTP",
    });
  }
});
router.post("/verify-otp", async (req, res) => {
  try {
    const { phone, otp } = req.body;

    const verification =
      await twilioClient.verify.v2
        .services(process.env.TWILIO_VERIFY_SERVICE_SID)
        .verificationChecks.create({
          to: phone,
          code: otp,
        });

    if (verification.status !== "approved") {
      return res.status(400).json({
        success: false,
        message: "Invalid OTP",
      });
    }

    res.json({
      success: true,
      message: "OTP Verified",
    });
  } catch (err) {
    console.error(err);

    res.status(500).json({
      success: false,
      message: "Verification failed",
    });
  }
});
export default router;