import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

import { getJobApplications } from "../api/adminApi";

import styles from "./CSS/Applications.module.css";

function Applications() {
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  const navigate = useNavigate();

  useEffect(() => {
    async function loadJobs() {
      try {
        const data = await getJobApplications();

        setJobs(data.jobs || []);
      } catch (error) {
        console.error("Failed to load application jobs:", error);

        setError(error.message || "Failed to load application jobs");
      } finally {
        setLoading(false);
      }
    }

    loadJobs();
  }, []);

  // ==========================================================
  // GROUP JOBS BY CATEGORY
  // ==========================================================

  const groupedJobs = {};

  jobs.forEach((job) => {
    const category = job.category_name || "Other";

    if (!groupedJobs[category]) {
      groupedJobs[category] = [];
    }

    groupedJobs[category].push(job);
  });

  // ==========================================================
  // LOADING
  // ==========================================================

  if (loading) {
    return (
      <div className={styles.page}>
        <div className={styles.loading}>Loading applications...</div>
      </div>
    );
  }

  // ==========================================================
  // ERROR
  // ==========================================================

  if (error) {
    return (
      <div className={styles.page}>
        <div className={styles.error}>{error}</div>
      </div>
    );
  }

  // ==========================================================
  // UI
  // ==========================================================

  return (
    <div className={styles.page}>
      {/* ======================================================
          HEADER
      ====================================================== */}

      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>Applications</h1>

          <p className={styles.subtitle}>
            Select a job to review its applications.
          </p>
        </div>

        <div className={styles.count}>
          {jobs.length}
          <span>Jobs</span>
        </div>
      </div>

      {/* ======================================================
          EMPTY
      ====================================================== */}

      {jobs.length === 0 ? (
        <div className={styles.empty}>No jobs found.</div>
      ) : (
        <div className={styles.categories}>
          {Object.entries(groupedJobs).map(([category, categoryJobs]) => (
            <section key={category} className={styles.categorySection}>
              {/* ==================================================
                    CATEGORY HEADER
                ================================================== */}

              <div className={styles.categoryHeader}>
                <h2>{category}</h2>

                <span>
                  {categoryJobs.length}{" "}
                  {categoryJobs.length === 1 ? "Job" : "Jobs"}
                </span>
              </div>

              {/* ==================================================
                    JOBS
                ================================================== */}

              <div className={styles.jobs}>
                {categoryJobs.map((job) => (
                  <div
                    key={job.job_id}
                    className={styles.jobCard}
                    onClick={() =>
                      navigate(`/dashboard/applications/${job.job_id}`)
                    }
                  >
                    {/* JOB HEADER */}

                    <div className={styles.jobHeader}>
                      <div>
                        <h3 className={styles.jobName}>{job.job_name}</h3>

                        <p className={styles.company}>{job.company}</p>
                      </div>

                      <span className={styles.applicationCount}>
                        {job.application_count}{" "}
                        {job.application_count === 1
                          ? "Applicant"
                          : "Applicants"}
                      </span>
                    </div>

                    {/* JOB INFORMATION */}

                    <div className={styles.jobInfo}>
                      <span>
                        ₹{job.salary_min ?? "—"}
                        {" - "}₹{job.salary_max ?? "—"}
                      </span>

                      <span>{job.work_location}</span>

                      <span>{job.no_of_openings} openings</span>

                      <span>{job.job_type?.replace("_", " ")}</span>
                    </div>

                    {/* SUBCATEGORY */}

                    <div className={styles.subcategory}>{job.occupation}</div>
                  </div>
                ))}
              </div>
            </section>
          ))}
        </div>
      )}
    </div>
  );
}

export default Applications;
