// Backend/utils/tempOtp.js

const otpStore = new Map();

const OTP_EXPIRY_MS = 5 * 60 * 1000; // 5 minutes

// ========================================
// Generate random 6-digit OTP
// ========================================

function createRandomOtp() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// ========================================
// Create / Store OTP
// ========================================

export function generateOtp(phone) {
  const otp = createRandomOtp();

  const expiresAt = Date.now() + OTP_EXPIRY_MS;

  otpStore.set(phone, {
    otp,
    expiresAt,
  });

  console.log("\n========================================");
  console.log("🔐 TEMP OTP GENERATED");
  console.log("========================================");
  console.log("Phone:", phone);
  console.log("OTP:", otp);
  console.log(
    "Expires:",
    new Date(expiresAt).toLocaleString()
  );
  console.log("========================================\n");

  return otp;
}

// ========================================
// Verify OTP
// ========================================

export function checkOtp(phone, otp) {
  const stored = otpStore.get(phone);

  // No OTP exists
  if (!stored) {
    return {
      success: false,
      message: "OTP not found or already used",
    };
  }

  // OTP expired
  if (Date.now() > stored.expiresAt) {
    otpStore.delete(phone);

    return {
      success: false,
      message: "OTP expired",
    };
  }

  // Wrong OTP
  if (stored.otp !== String(otp)) {
    return {
      success: false,
      message: "Invalid OTP",
    };
  }

  // OTP is valid
  // Delete it so it cannot be reused
  otpStore.delete(phone);

  return {
    success: true,
  };
}