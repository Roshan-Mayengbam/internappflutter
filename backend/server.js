import express from "express";
import http from "http";
import { Server } from "socket.io";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";

import Message from "./models/message.js";
import studentRoutes from "./routes/student.js";

dotenv.config(); // Load .env

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const io = new Server(server, { cors: { origin: "*" } });

// ✅ Connect to MongoDB
mongoose.connect(`${process.env.MONGODB_URL}/chatapp`, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log("✅ MongoDB connected"))
.catch(err => console.error("❌ DB error", err));

// 🔹 Socket.IO
io.on("connection", (socket) => {
  console.log("🟢 User connected:", socket.id);

  socket.on("set_username", (username) => {
    socket.data.username = username;
    console.log(`👤 ${username} connected`);
  });

  socket.on("joinRoom", async (roomId) => {
    socket.join(roomId);
    console.log(`${socket.data.username || socket.id} joined room ${roomId}`);

    const history = await Message.find({ roomId }).sort({ createdAt: 1 }).limit(50);
    socket.emit("chat_history", history);
  });

  socket.on("sendMessage", async ({ roomId, text }) => {
    const message = new Message({
      roomId,
      user: socket.data.username || "Anonymous",
      text,
    });
    await message.save();

    io.to(roomId).emit("receiveMessage", message);
  });

  socket.on("disconnect", () => {
    console.log("🔴 Disconnected:", socket.data.username || socket.id);
  });
});

// Routes
app.use('/student', studentRoutes);

// Start server
server.listen(process.env.PORT, () => console.log(`🚀 Server running on port ${process.env.PORT}`));
