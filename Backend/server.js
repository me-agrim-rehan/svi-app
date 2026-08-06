import dotenv from "dotenv";
import express from "express";
import pool from "./db.js"; // default import

dotenv.config();

const app = express();

app.use(express.json());

pool.query("SELECT NOW()")
  .then((result) => {
    console.log("Connected to PostgreSQL");
    console.log(result.rows[0]);
  })
  .catch((err) => console.error(err));

app.listen(5000, () => {
  console.log("Server running on port 5000");
});