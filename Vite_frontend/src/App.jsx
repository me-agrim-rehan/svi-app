import { Navigate, Route, Routes } from "react-router-dom";

import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import ProtectedRoute from "./pages/routes/ProtectedRoute";
import UserInfo from "./pages/UserInfo";
import UserDetails from "./pages/UserDetails";
import Jobs from "./pages/AllJobs";
import CreateJob from "./pages/CreateJob";

function App() {
  return (
    <Routes>
      {/* Public */}
      <Route path="/login" element={<Login />} />

      {/* Protected */}
      <Route element={<ProtectedRoute />}>
        {/* "/" is the actual dashboard */}
        <Route path="/" element={<Dashboard />} />

        {/* Keep /dashboard working too */}
        <Route path="/dashboard" element={<Dashboard />} />

        <Route path="/dashboard/users" element={<UserInfo />} />

        <Route path="/dashboard/users/:userId" element={<UserDetails />} />

        <Route path="/dashboard/jobs" element={<Jobs />} />

        <Route path="/dashboard/jobs/create" element={<CreateJob />} />
      </Route>

      {/* Unknown routes */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default App;
