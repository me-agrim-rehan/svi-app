import express from "express";

const router = express.Router();

router.get("/", (req, res) => {
  const experienceRanges = [
    {
      id: 1,
      label: "Less than 1 Year",
    },
    {
      id: 2,
      label: "1-3 Years",
    },
    {
      id: 3,
      label: "3-6 Years",
    },
    {
      id: 4,
      label: "6-10 Years",
    },
    {
      id: 5,
      label: "10+ Years",
    },
  ];

  return res.json({
    success: true,
    data: experienceRanges,
  });
});

export default router;