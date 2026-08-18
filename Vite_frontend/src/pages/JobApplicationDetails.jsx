import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";

import {
  getJobApplicationsByJob,
} from "../api/adminApi";

import styles from "./CSS/JobApplications.module.css";

function JobApplications() {
  const { jobId } = useParams();
  const navigate = useNavigate();

  const [job, setJob] = useState(null);
  const [applicants, setApplicants] = useState([]);

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    async function loadApplications() {
      try {
        const data = await getJobApplicationsByJob(jobId);

        setJob(data.job);
        setApplicants(data.applicants || []);
      } catch (error) {
        console.error(
          "Failed to load job applications:",
          error
        );

        setError(
          error.message ||
            "Failed to load job applications"
        );
      } finally {
        setLoading(false);
      }
    }

    loadApplications();
  }, [jobId]);

  // ==========================================================
  // LOADING
  // ==========================================================

  if (loading) {
    return (
      <div className={styles.page}>
        <div className={styles.loading}>
          Loading applications...
        </div>
      </div>
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  if (error) {
    return (
      <div className={styles.page}>
        <div className={styles.error}>
          {error}
        </div>
      </div>
    );
  }

  if (!job) {
    return (
      <div className={styles.page}>
        <div className={styles.error}>
          Job not found.
        </div>
      </div>
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  return (
    <div className={styles.page}>

      {/* BACK */}

      <button
        className={styles.backButton}
        onClick={() => navigate(-1)}
      >
        ← Back to Applications
      </button>

      {/* ======================================================
          JOB HEADER
      ====================================================== */}

      <section className={styles.jobCard}>

        <div className={styles.jobHeader}>

          <div>
            <h1 className={styles.jobTitle}>
              {job.name}
            </h1>

            <p className={styles.company}>
              {job.company}
            </p>
          </div>

          <div className={styles.applicationBadge}>
            {applicants.length}
            <span>
              {applicants.length === 1
                ? "Applicant"
                : "Applicants"}
            </span>
          </div>

        </div>

        {/* JOB INFO */}

        <div className={styles.jobInfo}>

          <div>
            <span className={styles.label}>
              Salary
            </span>

            <span>
              ₹{job.salary_min ?? "—"} - ₹
              {job.salary_max ?? "—"}
            </span>
          </div>

          <div>
            <span className={styles.label}>
              Location
            </span>

            <span>
              {job.work_location}
            </span>
          </div>

          <div>
            <span className={styles.label}>
              Job Type
            </span>

            <span>
              {job.job_type?.replace("_", " ")}
            </span>
          </div>

          <div>
            <span className={styles.label}>
              Openings
            </span>

            <span>
              {job.no_of_openings}
            </span>
          </div>

        </div>

        {/* CATEGORY */}

        <div className={styles.tags}>

          {job.category_name && (
            <span className={styles.tag}>
              {job.category_name}
            </span>
          )}

          {job.occupation && (
            <span className={styles.tag}>
              {job.occupation}
            </span>
          )}

        </div>

        {/* DESCRIPTION */}

        <div className={styles.description}>

          <h3>Description</h3>

          <p>
            {job.description}
          </p>

        </div>

      </section>

      {/* ======================================================
          APPLICANTS
      ====================================================== */}

      <div className={styles.applicantsHeader}>

        <div>
          <h2>
            Applicants
          </h2>

          <p>
            Review applicants for this job.
          </p>
        </div>

        <span className={styles.totalApplicants}>
          {applicants.length}
        </span>

      </div>

      {/* ======================================================
          NO APPLICANTS
      ====================================================== */}

      {applicants.length === 0 ? (

        <div className={styles.empty}>
          No applications received for this job yet.
        </div>

      ) : (

        <div className={styles.applicants}>

          {applicants.map((applicant) => (

            <div
              key={applicant.application_id}
              className={styles.applicantCard}
            >

              {/* APPLICANT */}

              <div className={styles.applicantMain}>

                <button
                  className={styles.applicantName}
                  onClick={() =>
                    navigate(
                      `/dashboard/users/${applicant.user_id}`
                    )
                  }
                >
                  {applicant.applicant_name}
                </button>

                <div className={styles.meta}>

                  <span>
                    📱 {applicant.applicant_mobile}
                  </span>

                  <span>
                    💼{" "}
                    {applicant.years_of_experience ||
                      "Not provided"}
                  </span>

                  <span>
                    📍{" "}
                    {applicant.city || "—"},{" "}
                    {applicant.state || "—"}
                  </span>

                </div>

              </div>

              {/* STATUS / ACTIONS */}

              <div className={styles.actions}>

                <span
                  className={`${styles.status} ${
                    styles[applicant.status]
                  }`}
                >
                  {applicant.status}
                </span>

                {applicant.status ===
                  "processing" && (

                  <div className={styles.buttons}>

                    <button
                      className={styles.accept}
                    >
                      Accept
                    </button>

                    <button
                      className={styles.reject}
                    >
                      Reject
                    </button>

                  </div>
                )}

              </div>

            </div>

          ))}

        </div>

      )}

    </div>
  );
}

export default JobApplications;