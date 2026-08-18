import { useEffect, useMemo, useState } from "react";

import { getAdminUsers } from "../api/adminApi";
import styles from "./CSS/UserInfo.module.css";
import { Link } from "react-router-dom";
function Users() {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    async function loadUsers() {
      try {
        setLoading(true);
        setError("");

        const data = await getAdminUsers();

        setUsers(data.users || []);
      } catch (error) {
        console.error("Failed to load users:", error);

        setError(error.message || "Failed to load users");
      } finally {
        setLoading(false);
      }
    }

    loadUsers();
  }, []);

  const filteredUsers = useMemo(() => {
    const query = search.trim().toLowerCase();

    if (!query) {
      return users;
    }

    return users.filter((user) => {
      return (
        user.name?.toLowerCase().includes(query) ||
        user.mobile?.includes(query) ||
        user.details?.occupation?.toLowerCase().includes(query) ||
        user.details?.city?.toLowerCase().includes(query) ||
        user.details?.state?.toLowerCase().includes(query)
      );
    });
  }, [users, search]);

  return (
    <div className={styles.page}>
      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>Users</h1>

          <p className={styles.subtitle}>Manage registered users</p>
        </div>

        <div className={styles.count}>{filteredUsers.length} users</div>
      </div>

      <div className={styles.toolbar}>
        <input
          className={styles.search}
          type="text"
          placeholder="Search by name, mobile, occupation or location..."
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
      </div>

      {loading && <div className={styles.message}>Loading users...</div>}

      {!loading && error && <div className={styles.error}>{error}</div>}

      {!loading && !error && filteredUsers.length === 0 && (
        <div className={styles.message}>No users found.</div>
      )}

      {!loading && !error && filteredUsers.length > 0 && (
        <div className={styles.tableContainer}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>Name</th>
                <th>Mobile</th>
                <th>Occupation</th>
                <th>Location</th>
                <th>Experience</th>
                <th>Verified</th>
              </tr>
            </thead>

            <tbody>
              {filteredUsers.map((user) => (
                <tr key={user.id}>
                  <td>
                    <Link
                      to={`/dashboard/users/${user.id}`}
                      className={styles.name}
                    >
                      {user.name}
                    </Link>
                  </td>

                  <td>{user.mobile}</td>

                  <td>{user.details?.occupation || "—"}</td>

                  <td>
                    {user.details
                      ? `${user.details.city}, ${user.details.state}`
                      : "—"}
                  </td>

                  <td>{user.details?.years_of_experience || "—"}</td>

                  <td>
                    <span
                      className={
                        user.is_mobile_verified
                          ? styles.verified
                          : styles.notVerified
                      }
                    >
                      {user.is_mobile_verified ? "Verified" : "Not verified"}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default Users;
