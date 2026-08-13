// Backend/routes/offer/userOfferRoutes.js

import express from "express";
import pool from "../../db.js";
import uploadOfferDocument from "../../middleware/offerDocumentUpload.js";

const router = express.Router();

// ============================================================================
// ADMIN → SEND DOCUMENT TO USER
// POST /offer/send
// ============================================================================

router.post(
    "/send",
    uploadOfferDocument.single("file"),
    async (req, res) => {
        try {
            const {
                user_id,
                document_name,
                document_type,
            } = req.body;

            // ================================================================
            // VALIDATION
            // ================================================================

            if (!user_id) {
                return res.status(400).json({
                    success: false,
                    message: "user_id is required",
                });
            }

            if (!document_name) {
                return res.status(400).json({
                    success: false,
                    message: "document_name is required",
                });
            }

            if (!document_type) {
                return res.status(400).json({
                    success: false,
                    message: "document_type is required",
                });
            }

            if (!req.file) {
                return res.status(400).json({
                    success: false,
                    message: "Document file is required",
                });
            }

            // ================================================================
            // CHECK USER EXISTS
            // ================================================================

            const userResult = await pool.query(
                `
                SELECT
                    id,
                    name,
                    mobile
                FROM public.users
                WHERE id = $1
                LIMIT 1
                `,
                [user_id],
            );

            if (userResult.rowCount === 0) {
                return res.status(404).json({
                    success: false,
                    message: "User not found",
                });
            }

            const user = userResult.rows[0];

            console.log(
                "[OFFER] Sending document to:",
                user.name,
                user.mobile,
                user.id,
            );

            // ================================================================
            // CREATE FILE URL
            // ================================================================

            const fileUrl =
                `/uploads/offer-documents/${req.file.filename}`;

            // ================================================================
            // SAVE DOCUMENT
            // ================================================================

            const result = await pool.query(
                `
                INSERT INTO public.user_documents
                (
                    user_id,
                    document_name,
                    document_type,
                    file_url
                )
                VALUES
                (
                    $1,
                    $2,
                    $3,
                    $4
                )
                RETURNING
                    id,
                    user_id,
                    document_name,
                    document_type,
                    file_url,
                    uploaded_at
                `,
                [
                    user_id,
                    document_name,
                    document_type,
                    fileUrl,
                ],
            );

            // ================================================================
            // SUCCESS
            // ================================================================

            console.log(
                "[OFFER] Document sent successfully:",
                result.rows[0],
            );

            return res.status(201).json({
                success: true,
                message: "Document sent successfully",
                document: result.rows[0],
            });

        } catch (error) {
            console.error(
                "[OFFER] Send document error:",
                error,
            );

            return res.status(500).json({
                success: false,
                message: "Failed to send document",
            });
        }
    },
);

export default router;