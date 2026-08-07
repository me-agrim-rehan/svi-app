import pool from "../db.js";

export async function createAccount(req, res) {
  const client = await pool.connect();
  const aadhaarPhoto = req.files?.aadhaarPhoto?.[0];
  const livePhoto = req.files?.livePhoto?.[0];
  console.log(aadhaarPhoto);
  console.log(livePhoto);
  try {
    const {
      phone,
      name,
      address,
      city,
      state,
      occupation,
      description,
      aadhaarNumber,
      aadhaarPhotoUrl,
      livePhotoUrl,
    } = req.body;

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
            ($1,$2,true)
            RETURNING id
            `,
      [name, phone],
    );

    const userId = userResult.rows[0].id;

    // Insert details
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
            ($1,$2,$3,$4,$5,$6,$7,$8,$9)
            `,
      [
        userId,
        address,
        city,
        state,
        occupation,
        description,
        aadhaarNumber,
        aadhaarPhotoUrl,
        livePhotoUrl,
      ],
    );

    await client.query("COMMIT");

    res.json({
      success: true,
      userId,
    });
  } catch (err) {
    await client.query("ROLLBACK");

    console.error(err);

    res.status(500).json({
      success: false,
      message: err.message,
    });
  } finally {
    client.release();
  }
}
