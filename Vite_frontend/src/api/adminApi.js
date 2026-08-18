const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

export async function adminLogin(email, password) {
  const response = await fetch(`${API_BASE_URL}/admin/login`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    credentials: "include",
    body: JSON.stringify({
      email,
      password,
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Login failed");
  }

  return data;
}

export async function getCurrentAdmin() {
  const response = await fetch(`${API_BASE_URL}/admin/me`, {
    method: "GET",
    credentials: "include",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Session invalid");
  }

  return data;
}
export async function getAdminUsers() {
  const response = await fetch(`${API_BASE_URL}/admin/users`, {
    method: "GET",
    credentials: "include",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Failed to fetch users");
  }

  return data;
}

export async function getAdminUser(userId) {
  const response = await fetch(`${API_BASE_URL}/admin/users/${userId}`, {
    method: "GET",
    credentials: "include",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Failed to fetch user");
  }

  return data;
}

export function getFileUrl(fileUrl) {
  if (!fileUrl) {
    return null;
  }

  // Already an absolute URL
  if (fileUrl.startsWith("http://") || fileUrl.startsWith("https://")) {
    return fileUrl;
  }

  return `${API_BASE_URL}${fileUrl}`;
}

export async function getJobMeta() {
  const response = await fetch(`${API_BASE_URL}/admin/jobs/meta`, {
    method: "GET",
    credentials: "include",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Failed to fetch job categories");
  }

  return data;
}

export async function createAdminJob(job) {
  const response = await fetch(`${API_BASE_URL}/admin/jobs`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    credentials: "include",
    body: JSON.stringify(job),
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Failed to create job");
  }

  return data;
}
export async function getAdminJobs() {
  const response = await fetch(`${API_BASE_URL}/admin/jobs`, {
    method: "GET",
    credentials: "include",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Failed to fetch jobs");
  }

  return data;
}

export async function getJobApplications() {
  const response = await fetch(`${API_BASE_URL}/admin/job-applications`, {
    method: "GET",
    credentials: "include",
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.message || "Failed to fetch jobs");
  }

  return data;
}

export async function getJobApplicationsByJob(jobId) {
  const response = await fetch(
    `${API_BASE_URL}/admin/job-applications/job/${jobId}`,
    {
      method: "GET",
      credentials: "include",
    }
  );

  const data = await response.json();

  if (!response.ok) {
    throw new Error(
      data.message || "Failed to fetch job applications"
    );
  }

  return data;
}