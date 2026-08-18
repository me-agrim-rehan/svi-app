// Backend/server.js
import dotenv from "dotenv";
import express from "express";
import pool from "./db.js";
// import otpRoutes from "./routes/registerOtpRoutes.js"; twilio expired
import cors from "cors";
import cookieParser from "cookie-parser";
import registrationRoutes from "./routes/registrationRoutes.js";
import jobRoutes from "./routes/jobRoutes.js";
// import loginRoutes from "./routes/loginOtpRoutes.js"; twilio expired
import postedJobRoutes from "./routes/postedJobRoutes.js";
import recommendedJobRoutes from "./routes/recommendedJobRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import experienceRoutes from "./routes/experienceRoutes.js";
import applyJobRoutes from "./routes/applyJobRoutes.js";
import signedDocumentRoutes from "./routes/signedDocumentRoutes.js";
import userOfferRoutes from "./routes/offer/userOfferRoutes.js";
// temp routes login/ regitster
import tempLoginOtpRoutes from "./routes/temp/tempLoginOtpRoutes.js";
import tempRegisterOtpRoutes from "./routes/temp/tempRegisterOtpRoutes.js";

// admin routes
import adminAuthRoutes from "./routes/adminside/adminAuthRoutes.js"; // admin login 
import adminUserRoutes from "./routes/adminside/adminUserRoutes.js"; // admin routes for all user info
import adminJobRoutes from "./routes/adminside/adminJobRoutes.js"; // admin job creation and get
dotenv.config();

const app = express();


const allowedOrigins = [
  process.env.ADMIN_FRONTEND_URL,
];

app.use(
  cors({
    origin: (origin, callback) => {
      // Flutter/mobile requests generally don't send an Origin header.
      if (!origin) {
        return callback(null, true);
      }

      if (allowedOrigins.includes(origin)) {
        return callback(null, true);
      }

      return callback(new Error("Not allowed by CORS"));
    },
    credentials: true,
  })
);
app.use(express.json());
app.use(cookieParser());

// Serve locally uploaded files
app.use("/uploads", express.static("uploads"));

app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// app.use("/otp", otpRoutes);
// app.use("/auth/login", loginRoutes); twilio Epired
// temp routes for login and register
app.use("/auth/login", tempLoginOtpRoutes);
app.use("/otp", tempRegisterOtpRoutes);

app.use("/registration", registrationRoutes);
app.use("/jobs", jobRoutes);
app.use("/posted-jobs", postedJobRoutes);
app.use("/recommended-jobs", recommendedJobRoutes);
app.use("/users", userRoutes);
app.use("/experience-ranges", experienceRoutes);
app.use("/apply-job", applyJobRoutes);
app.use("/signed-documents", signedDocumentRoutes);
app.use("/offer", userOfferRoutes);

// admin routes real
app.use("/admin", adminAuthRoutes); // admin login
app.use("/admin/users", adminUserRoutes); // admin routes for all user info
app.use("/admin/jobs", adminJobRoutes); // admin job creation and get

pool.query("SELECT NOW()")
  .then((result) => {
    console.log("Connected to PostgreSQL");
    console.log(result.rows[0]);
  })
  .catch((err) => console.error(err));

app.listen(5000, () => {
  console.log("Server running on port 5000");
});