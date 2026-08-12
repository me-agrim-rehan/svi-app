import express from "express";
import pool from "../db.js";
import fs from "fs";
import path from "path";

import uploadSignedDocument from "../middleware/signedDocumentUpload.js";

const router = express.Router();

function normalizePhone(phone) {
    let cleanPhone = phone?.replace(/\D/g, "");

    if (cleanPhone?.length === 12 && cleanPhone.startsWith("91")) {
        cleanPhone = cleanPhone.substring(2);
    }

    return cleanPhone;
}

router.post(
    "/upload",

    (req, res, next) => {
        uploadSignedDocument.single("file")(req, res, (err) => {
            if (err) {
                console.error("========================================");
                console.error("MULTER ERROR");
                console.error(err);
                console.error("========================================");

                return res.status(400).json({
                    success: false,
                    message: err.message,
                });
            }

            console.log("MULTER SUCCESS");
            console.log("File:", req.file);
            console.log("Body:", req.body);

            next();
        });
    },

    async (req, res) => {
        try {
            const phone = normalizePhone(req.body.phone);

            console.log("PHONE:", phone);

            if (!phone) {
                return res.status(400).json({
                    success: false,
                    message: "Phone number is required.",
                });
            }

            if (!req.file) {
                return res.status(400).json({
                    success: false,
                    message: "Document file is required.",
                });
            }

            console.log("FILE RECEIVED:", req.file);

            const fileUrl =
                `/uploads/signed-documents/${req.file.filename}`;

            console.log("FILE URL:", fileUrl);

            // Check whether this user already has a signed certificate
            const existing = await pool.query(
                `
                SELECT file_url
                FROM user_signed_documents
                WHERE phone = $1
                  AND document_type = 'signed_certificate'
                `,
                [phone]
            );

            // Insert new record or update existing record
            const result = await pool.query(
                `
                INSERT INTO user_signed_documents
                    (
                        phone,
                        document_type,
                        file_url
                    )
                VALUES
                    (
                        $1,
                        'signed_certificate',
                        $2
                    )
                ON CONFLICT (phone, document_type)
                DO UPDATE SET
                    file_url = EXCLUDED.file_url,
                    uploaded_at = CURRENT_TIMESTAMP
                RETURNING *
                `,
                [phone, fileUrl]
            );

            console.log("DB RECORD:", result.rows[0]);

            // Delete old physical file if user replaced
            // their existing certificate.
            if (existing.rows.length > 0) {
                const oldUrl = existing.rows[0].file_url;

                if (oldUrl && oldUrl !== fileUrl) {
                    const oldFilePath = path.join(
                        process.cwd(),
                        oldUrl.replace(/^\/uploads\//, "uploads/")
                    );

                    if (fs.existsSync(oldFilePath)) {
                        fs.unlinkSync(oldFilePath);

                        console.log(
                            "Deleted old signed document:",
                            oldFilePath
                        );
                    }
                }
            }

            return res.status(200).json({
                success: true,
                message: "Signed document uploaded successfully.",
                document: result.rows[0],
            });

        } catch (error) {
            console.error("========================================");
            console.error("SIGNED DOCUMENT ERROR");
            console.error(error);
            console.error("========================================");

            // If the DB operation failed, remove the
            // newly uploaded physical file.
            if (req.file?.path && fs.existsSync(req.file.path)) {
                try {
                    fs.unlinkSync(req.file.path);

                    console.log(
                        "Deleted orphaned uploaded file:",
                        req.file.path
                    );
                } catch (deleteError) {
                    console.error(
                        "Failed to delete uploaded file:",
                        deleteError
                    );
                }
            }

            return res.status(500).json({
                success: false,
                message: "Failed to upload signed document.",
            });
        }
    }
);

export default router;