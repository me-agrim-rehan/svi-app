import multer from "multer";
import path from "path";
import fs from "fs";

const uploadDir = "uploads/signed-documents";

if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

console.log("SIGNED DOCUMENT UPLOAD MIDDLEWARE LOADED");
console.log("Upload directory:", path.resolve(uploadDir));

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        console.log("MULTER DESTINATION CALLED");
        console.log("Field name:", file.fieldname);
        console.log("Original name:", file.originalname);
        console.log("MIME:", file.mimetype);

        cb(null, uploadDir);
    },

    filename: (req, file, cb) => {
        console.log("MULTER FILENAME CALLED");

        const extension = path.extname(
            file.originalname
        ).toLowerCase();

        const uniqueName = `${Date.now()}-${Math.round(
            Math.random() * 1e9
        )}${extension}`;

        console.log("Generated filename:", uniqueName);

        cb(null, uniqueName);
    },
});

const fileFilter = (req, file, cb) => {
    console.log("MULTER FILE FILTER CALLED");
    console.log("Field:", file.fieldname);
    console.log("Name:", file.originalname);
    console.log("MIME:", file.mimetype);

    const allowedMimeTypes = [
        "application/pdf",
        "image/png",
        "image/jpeg",
    ];

    if (!allowedMimeTypes.includes(file.mimetype)) {
        console.log("MULTER REJECTED FILE");

        return cb(
            new Error(
                "Only PDF, PNG, JPG and JPEG files are allowed."
            )
        );
    }

    console.log("MULTER ACCEPTED FILE");

    cb(null, true);
};

const uploadSignedDocument = multer({
    storage,
    fileFilter,
    limits: {
        fileSize: 10 * 1024 * 1024,
    },
});

export default uploadSignedDocument;