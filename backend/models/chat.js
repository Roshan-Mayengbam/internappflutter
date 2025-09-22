import express from "express";
import { Chat } from "../models/chat.js";

const router = express.Router();

// Save a new chat
router.post("/add", async (req, res) => {
  try {
    const { senderId, receiverId, message } = req.body;

    const newChat = new Chat({
      senderId,
      receiverId,
      message,
    });

    await newChat.save();
    res.status(201).json({ success: true, chat: newChat });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get chats between two users
router.get("/:senderId/:receiverId", async (req, res) => {
  try {
    const { senderId, receiverId } = req.params;

    const chats = await Chat.find({
      $or: [
        { senderId, receiverId },
        { senderId: receiverId, receiverId: senderId },
      ],
    }).sort({ timestamp: 1 });

    res.status(200).json({ success: true, chats });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

export default router;
