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
// ============================================================================
// USER → GET THEIR DOCUMENTS
// GET /offer/my-documents?phone=PHONE
// ============================================================================

function normalizePhone(phone) {
    let cleanPhone = phone?.replace(/\D/g, "");

    if (cleanPhone?.length === 12 && cleanPhone.startsWith("91")) {
        cleanPhone = cleanPhone.substring(2);
    }

    return cleanPhone;
}

router.get("/my-documents", async (req, res) => {
    try {
        const { phone } = req.query;

        // ================================================================
        // VALIDATE PHONE
        // ================================================================

        if (!phone) {
            return res.status(400).json({
                success: false,
                message: "Phone number is required",
            });
        }

        const cleanPhone = normalizePhone(phone);

        if (!cleanPhone || cleanPhone.length !== 10) {
            return res.status(400).json({
                success: false,
                message: "Phone number must contain exactly 10 digits",
            });
        }

        // ================================================================
        // FETCH USER DOCUMENTS
        // ================================================================

        const result = await pool.query(
            `
            SELECT
                ud.id,
                ud.user_id,
                ud.document_name,
                ud.document_type,
                ud.file_url,
                ud.uploaded_at
            FROM public.user_documents ud
            INNER JOIN public.users u
                ON u.id = ud.user_id
            WHERE u.mobile = $1
            ORDER BY ud.uploaded_at DESC
            `,
            [cleanPhone],
        );

        // ================================================================
        // SUCCESS
        // ================================================================

        console.log(
            "[OFFER] Documents found for phone:",
            cleanPhone,
            "Count:",
            result.rows.length,
        );

        return res.status(200).json({
            success: true,
            documents: result.rows,
        });

    } catch (error) {
        console.error(
            "[OFFER] Fetch documents error:",
            error,
        );

        return res.status(500).json({
            success: false,
            message: "Failed to fetch documents",
        });
    }
});
export default router;