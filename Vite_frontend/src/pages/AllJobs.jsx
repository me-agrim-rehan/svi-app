import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

import { getAdminJobs } from "../api/adminApi";

import styles from "./CSS/AllJobs.module.css";

function Jobs() {
  const navigate = useNavigate();

  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    loadJobs();
  }, []);

  async function loadJobs() {
    try {
      setLoading(true);
      setError("");

      const data = await getAdminJobs();

      setJobs(data.jobs || []);
    } catch (error) {
      console.error("Failed to load jobs:", error);

      setError(error.message || "Failed to load jobs");
    } finally {
      setLoading(false);
    }
  }

  function formatJobType(type) {
    if (!type) return "—";

    return type
      .split("_")
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(" ");
  }

  function formatSalary(min, max) {
    if (min == null && max == null) {
      return "Not specified";
    }

    if (min != null && max != null) {
      return `₹${Number(min).toLocaleString()} - ₹${Number(
        max,
      ).toLocaleString()}`;
    }

    if (min != null) {
      return `₹${Number(min).toLocaleString()}+`;
    }

    return `Up to ₹${Number(max).toLocaleString()}`;
  }

  function formatDate(date) {
    if (!date) return "—";

    return new Date(date).toLocaleDateString();
  }

  return (
    <div className={styles.page}>
      {/* Header */}

      <div className={styles.header}>
        <div>
          <h1>All Jobs</h1>

          <p>Manage jobs available on the platform</p>
        </div>

        <button
          type="button"
          className={styles.createButton}
          onClick={() => navigate("/dashboard/jobs/create")}
        >
          + Create New Job
        </button>
      </div>

      {/* Error */}

      {error && (
        <div className={styles.error}>
          {error}

          <button type="button" onClick={loadJobs}>
            Retry
          </button>
        </div>
      )}

      {/* Loading */}

      {loading ? (
        <div className={styles.message}>Loading jobs...</div>
      ) : jobs.length === 0 ? (
        <div className={styles.empty}>
          <h2>No Jobs Yet</h2>

          <p>Create your first job to get started.</p>

          <button
            type="button"
            onClick={() => navigate("/dashboard/jobs/create")}
          >
            Create New Job
          </button>
        </div>
      ) : (
        <div className={styles.card}>
          <div className={styles.tableWrapper}>
            <table className={styles.table}>
              <thead>
                <tr>
                  <th>Job</th>
                  <th>Company</th>
                  <th>Category</th>
                  <th>Type</th>
                  <th>Salary</th>
                  <th>Openings</th>
                  <th>Location</th>
                  <th>Created</th>
                </tr>
              </thead>

              <tbody>
                {jobs.map((job) => (
                  <tr key={job.id}>
                    <td>
                      <div className={styles.jobName}>{job.name}</div>
                    </td>

                    <td>{job.company}</td>

                    <td>
                      <div>{job.category_name || "—"}</div>

                      <div className={styles.subcategory}>
                        {job.subcategory_name || "—"}
                      </div>
                    </td>

                    <td>
                      <span className={styles.type}>
                        {formatJobType(job.job_type)}
                      </span>
                    </td>

                    <td>{formatSalary(job.salary_min, job.salary_max)}</td>

                    <td>{job.no_of_openings}</td>

                    <td>{job.work_location}</td>

                    <td>{formatDate(job.created_at)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}

export default Jobs;
