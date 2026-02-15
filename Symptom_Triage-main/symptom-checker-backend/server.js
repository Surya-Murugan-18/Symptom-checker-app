require("dotenv").config();
const express = require("express");
const cors = require("cors");

const chatRoutes = require("./routes/chat");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/chat", chatRoutes);

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`✅ Symptom Checker Backend running on port ${PORT}`);
});
