// Backend/server.js
import dotenv from "dotenv";
import express from "express";
import pool from "./db.js";
// import otpRoutes from "./routes/registerOtpRoutes.js"; twilio expired
import cors from "cors";
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

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

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

// admin
app.use("/admin", express.static("admin"));

pool.query("SELECT NOW()")
  .then((result) => {
    console.log("Connected to PostgreSQL");
    console.log(result.rows[0]);
  })
  .catch((err) => console.error(err));

app.listen(5000, () => {
  console.log("Server running on port 5000");
});