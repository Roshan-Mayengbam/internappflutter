import express from "express";
import Message from "../models/message.js";

const router = express.Router();

// Get chat history by roomId
router.get("/:roomId", async (req, res) => {
  const { roomId } = req.params;
  const messages = await Message.find({ roomId }).sort({ timestamp: 1 });
  res.json(messages);
});

export default router;
