import pool from "../db.js";

export async function createAccount(req, res) {
  const aadhaarPhoto = req.files?.aadhaarPhoto?.[0];
  const livePhoto = req.files?.livePhoto?.[0];

  console.log("Aadhaar photo:", aadhaarPhoto);
  console.log("Live photo:", livePhoto);

  // Make sure both required files were uploaded
  if (!aadhaarPhoto || !livePhoto) {
    return res.status(400).json({
      success: false,
      message: "Aadhaar photo and live photo are required",
    });
  }

  const {
    phone,
    name,
    address,
    city,
    state,
    occupation,
    description,
    aadhaarNumber,
    preferredJobs,
  } = req.body;

  let cleanPhone = phone?.replace(/\D/g, "");
  const cleanAadhaar = aadhaarNumber?.replace(/\D/g, "");

  // Convert Indian +91XXXXXXXXXX format to XXXXXXXXXX
  if (cleanPhone?.length === 12 && cleanPhone.startsWith("91")) {
    cleanPhone = cleanPhone.substring(2);
  }

  console.log("Registration body:", req.body);
  console.log("Raw phone:", phone);
  console.log("Clean phone:", cleanPhone);
  console.log("Raw Aadhaar:", aadhaarNumber);
  console.log("Clean Aadhaar:", cleanAadhaar);
  console.log("Preferred jobs:", preferredJobs);

  // Validate phone
  if (!cleanPhone || cleanPhone.length !== 10) {
    return res.status(400).json({
      success: false,
      message: "Phone number must contain exactly 10 digits",
    });
  }

  // Validate Aadhaar
  if (!cleanAadhaar || cleanAadhaar.length !== 12) {
    return res.status(400).json({
      success: false,
      message: "Aadhaar number must contain exactly 12 digits",
    });
  }

  // Convert preferredJobs into an array
  let parsedPreferredJobs = [];

  try {
    if (preferredJobs) {
      parsedPreferredJobs =
        typeof preferredJobs === "string"
          ? JSON.parse(preferredJobs)
          : preferredJobs;
    }
  } catch (error) {
    return res.status(400).json({
      success: false,
      message: "Invalid preferred jobs format",
    });
  }

  // Make sure preferredJobs is an array
  if (!Array.isArray(parsedPreferredJobs)) {
    return res.status(400).json({
      success: false,
      message: "Preferred jobs must be an array",
    });
  }

  // Make sure all IDs are integers
  const invalidJobIds = parsedPreferredJobs.some(
    (jobId) => !Number.isInteger(Number(jobId))
  );

  if (invalidJobIds) {
    return res.status(400).json({
      success: false,
      message: "Preferred job IDs must be integers",
    });
  }

  // Create URLs for the locally stored files
  const baseUrl = `${req.protocol}://${req.get("host")}`;

  const aadhaarPhotoUrl = `${baseUrl}/uploads/${aadhaarPhoto.filename}`;
  const livePhotoUrl = `${baseUrl}/uploads/${livePhoto.filename}`;

  console.log("Aadhaar URL:", aadhaarPhotoUrl);
  console.log("Live photo URL:", livePhotoUrl);

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    // Insert user
    const userResult = await client.query(
      `
        INSERT INTO users
        (
          name,
          mobile,
          is_mobile_verified
        )
        VALUES
        ($1, $2, true)
        RETURNING id
      `,
      [name, cleanPhone]
    );

    const userId = userResult.rows[0].id;

    // Insert registration details
    await client.query(
      `
        INSERT INTO user_details
        (
          user_id,
          address,
          city,
          state,
          occupation,
          description,
          aadhaar_number,
          aadhaar_photo_url,
          live_photo_url
        )
        VALUES
        ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      `,
      [
        userId,
        address,
        city,
        state,
        occupation,
        description,
        cleanAadhaar,
        aadhaarPhotoUrl,
        livePhotoUrl,
      ]
    );

    // Insert preferred jobs
    for (const jobSubcategoryId of parsedPreferredJobs) {
      await client.query(
        `
          INSERT INTO user_preferred_jobs
          (
            user_id,
            job_subcategory_id
          )
          VALUES
          ($1, $2)
        `,
        [userId, Number(jobSubcategoryId)]
      );
    }

    await client.query("COMMIT");

    res.status(201).json({
      success: true,
      userId,
      aadhaarPhotoUrl,
      livePhotoUrl,
    });
  } catch (err) {
    await client.query("ROLLBACK");

    console.error("createAccount error:", err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  } finally {
    client.release();
  }
}