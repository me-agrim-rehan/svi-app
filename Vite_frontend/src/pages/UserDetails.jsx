import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";

import { getAdminUser, getFileUrl } from "../api/adminApi";
import styles from "./CSS/UserDetails.module.css";

function UserDetails() {
  const { userId } = useParams();

  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    async function loadUser() {
      try {
        setLoading(true);
        setError("");

        const data = await getAdminUser(userId);

        setUser(data.user);
      } catch (error) {
        console.error("Failed to load user:", error);

        setError(error.message || "Failed to load user");
      } finally {
        setLoading(false);
      }
    }

    loadUser();
  }, [userId]);

  if (loading) {
    return (
      <div className={styles.page}>
        <div className={styles.message}>Loading user...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className={styles.page}>
        <div className={styles.error}>{error}</div>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  const details = user.details;

  return (
    <div className={styles.page}>
      <Link to="/dashboard/users" className={styles.backButton}>
        ← Back to Users
      </Link>

      {/* Header */}
      <div className={styles.header}>
        <div>
          <h1>{user.name}</h1>

          <p>User ID: {user.id}</p>
        </div>

        <span
          className={
            user.is_mobile_verified ? styles.verified : styles.notVerified
          }
        >
          {user.is_mobile_verified ? "Mobile Verified" : "Mobile Not Verified"}
        </span>
      </div>

      {/* Basic Information */}
      <section className={styles.section}>
        <h2>Basic Information</h2>

        <div className={styles.grid}>
          <Info label="Name" value={user.name} />

          <Info label="Mobile" value={user.mobile} />

          <Info
            label="Mobile Verified"
            value={user.is_mobile_verified ? "Yes" : "No"}
          />

          <Info label="Created" value={formatDate(user.created_at)} />

          <Info label="Last Updated" value={formatDate(user.updated_at)} />
        </div>
      </section>

      {/* Personal Details */}
      <section className={styles.section}>
        <h2>Personal Details</h2>

        {details ? (
          <div className={styles.grid}>
            <Info label="Occupation" value={details.occupation} />

            <Info label="Experience" value={details.years_of_experience} />

            <Info label="Address" value={details.address} />

            <Info label="City" value={details.city} />

            <Info label="State" value={details.state} />

            <Info label="Description" value={details.description} />
          </div>
        ) : (
          <p className={styles.empty}>Personal details have not been added.</p>
        )}
      </section>

      {/* Aadhaar */}
      <section className={styles.section}>
        <h2>Aadhaar</h2>

        {details ? (
          <div className={styles.grid}>
            <Info label="Aadhaar Number" value={details.aadhaar_number} />

            <Info
              label="Aadhaar Photo"
              value={
                details.aadhaar_photo_url ? (
                  <a
                    href={getFileUrl(details.aadhaar_photo_url)}
                    target="_blank"
                    rel="noreferrer"
                  >
                    View Aadhaar Photo
                  </a>
                ) : (
                  "Not uploaded"
                )
              }
            />
          </div>
        ) : (
          <p className={styles.empty}>No Aadhaar information available.</p>
        )}
      </section>

      {/* Live Photo */}
      <section className={styles.section}>
        <h2>Live Photo</h2>

        {details?.live_photo_url ? (
          <img
            src={getFileUrl(details.live_photo_url)}
            alt={`${user.name} live`}
            className={styles.photo}
          />
        ) : (
          <p className={styles.empty}>No live photo uploaded.</p>
        )}
      </section>

      {/* Preferred Jobs */}
      <section className={styles.section}>
        <h2>Preferred Jobs</h2>

        {user.preferred_jobs.length > 0 ? (
          <div className={styles.list}>
            {user.preferred_jobs.map((job) => (
              <div key={job.id} className={styles.listItem}>
                <strong>{job.name}</strong>

                <span>{job.category}</span>
              </div>
            ))}
          </div>
        ) : (
          <p className={styles.empty}>No preferred jobs.</p>
        )}
      </section>

      {/* Applied Jobs */}
      <section className={styles.section}>
        <h2>Applied Jobs</h2>

        {user.applied_jobs.length > 0 ? (
          <div className={styles.list}>
            {user.applied_jobs.map((application) => (
              <div key={application.application_id} className={styles.listItem}>
                <div>
                  <strong>{application.job_name}</strong>

                  <span>{application.company}</span>
                </div>

                <span className={styles.status}>{application.status}</span>
              </div>
            ))}
          </div>
        ) : (
          <p className={styles.empty}>No applications.</p>
        )}
      </section>

      {/* Documents */}
      <section className={styles.section}>
        <h2>Documents</h2>

        {user.documents.length > 0 ? (
          <div className={styles.list}>
            {user.documents.map((document) => (
              <div key={document.id} className={styles.listItem}>
                <div>
                  <strong>{document.name}</strong>

                  <span>{document.type}</span>
                </div>

                <a
                  href={getFileUrl(document.url)}
                  target="_blank"
                  rel="noreferrer"
                >
                  View
                </a>
              </div>
            ))}
          </div>
        ) : (
          <p className={styles.empty}>No documents uploaded.</p>
        )}
      </section>

      {/* Signed Documents */}
      <section className={styles.section}>
        <h2>Signed Documents</h2>

        {user.signed_documents.length > 0 ? (
          <div className={styles.list}>
            {user.signed_documents.map((document) => (
              <div key={document.id} className={styles.listItem}>
                <div>
                  <strong>{document.type}</strong>

                  <span>{formatDate(document.uploaded_at)}</span>
                </div>

                <a
                  href={getFileUrl(document.url)}
                  target="_blank"
                  rel="noreferrer"
                >
                  View
                </a>
              </div>
            ))}
          </div>
        ) : (
          <p className={styles.empty}>No signed documents.</p>
        )}
      </section>
    </div>
  );
}

function Info({ label, value }) {
  return (
    <div className={styles.info}>
      <span className={styles.label}>{label}</span>

      <span className={styles.value}>{value || "—"}</span>
    </div>
  );
}

function formatDate(value) {
  if (!value) {
    return "—";
  }

  return new Date(value).toLocaleString();
}

export default UserDetails;
