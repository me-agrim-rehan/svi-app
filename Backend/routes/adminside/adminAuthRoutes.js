import express from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import pool from "../../db.js";
import { adminAuthMiddleware } from "../../middleware/adminside/adminAuthMiddleware.js";
const router = express.Router();

function validateEmail(email) {
  const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;

  return emailRegex.test(email) && !/\s/.test(email);
}

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Email and password are required",
      });
    }

    const normalizedEmail = email.trim().toLowerCase();

    if (!validateEmail(normalizedEmail)) {
      return res.status(400).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // ---------------------------------------------------------
    // Find admin
    // ---------------------------------------------------------

    const result = await pool.query(
      `
      SELECT
        id,
        name,
        email,
        password_hash,
        role,
        is_active
      FROM admins
      WHERE email = $1
      LIMIT 1
      `,
      [normalizedEmail],
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    const admin = result.rows[0];

    // ---------------------------------------------------------
    // Check account status
    // ---------------------------------------------------------

    if (!admin.is_active) {
      return res.status(403).json({
        success: false,
        message: "This admin account has been disabled",
      });
    }

    // ---------------------------------------------------------
    // Verify password
    // ---------------------------------------------------------

    const passwordValid = await bcrypt.compare(password, admin.password_hash);

    if (!passwordValid) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // ---------------------------------------------------------
    // Create JWT
    // ---------------------------------------------------------

    console.log("JWT_SECRET exists:", !!process.env.JWT_SECRET);
    const token = jwt.sign(
      {
        adminId: admin.id,
        role: admin.role,
      },
      process.env.JWT_SECRET,
      {
        expiresIn: "7d",
      },
    );

    // ---------------------------------------------------------
    // Set HTTP-only cookie
    // ---------------------------------------------------------

    res.cookie("adminToken", token, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: process.env.NODE_ENV === "production" ? "none" : "lax",
      maxAge: 7 * 24 * 60 * 60 * 1000,
    });

    return res.status(200).json({
      success: true,
      message: "Login successful",
      admin: {
        id: admin.id,
        name: admin.name,
        email: admin.email,
        role: admin.role,
      },
    });
  } catch (error) {
    console.error("Admin login error:", error);

    return res.status(500).json({
      success: false,
      message: "Login failed",
    });
  }
});

router.get("/me", adminAuthMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `
      SELECT
        id,
        name,
        email,
        role,
        is_active
      FROM admins
      WHERE id = $1
      LIMIT 1
      `,
      [req.admin.id],
    );

    if (result.rows.length === 0) {
      return res.status(401).json({
        success: false,
        message: "Admin account not found",
      });
    }

    const admin = result.rows[0];

    if (!admin.is_active) {
      return res.status(403).json({
        success: false,
        message: "Admin account is disabled",
      });
    }

    return res.status(200).json({
      success: true,
      admin: {
        id: admin.id,
        name: admin.name,
        email: admin.email,
        role: admin.role,
      },
    });
  } catch (error) {
    console.error("Admin session error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to verify admin session",
    });
  }
});

export default router;
