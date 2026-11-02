"use strict";

const express = require("express");
const mysql = require("mysql2/promise");

const app = express();
app.use(express.json());

const required = ["DB_HOST", "DB_USER", "DB_PASSWORD", "DB_NAME"];
for (const key of required) {
  if (!process.env[key]) {
    console.error(`Missing required environment variable: ${key}`);
    process.exit(1);
  }
}

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 5,
  ssl: process.env.DB_SSL === "true" ? { rejectUnauthorized: true } : undefined
});

async function initializeDatabase() {
  await pool.execute(`
    CREATE TABLE IF NOT EXISTS tasks (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
  `);
}

app.get("/api/health", async (_req, res) => {
  try {
    await pool.query("SELECT 1");
    res.json({ status: "ok", service: "backend", database: "connected" });
  } catch (error) {
    res.status(503).json({ status: "error", database: "unavailable" });
  }
});

app.get("/api/tasks", async (_req, res) => {
  try {
    const [rows] = await pool.execute(
      "SELECT id, title, created_at FROM tasks ORDER BY id DESC"
    );
    res.json(rows);
  } catch (error) {
    console.error("GET /api/tasks:", error.message);
    res.status(500).json({ error: "Could not retrieve tasks" });
  }
});

app.post("/api/tasks", async (req, res) => {
  const title = typeof req.body.title === "string" ? req.body.title.trim() : "";
  if (!title || title.length > 255) {
    return res.status(400).json({ error: "Enter a task title (1-255 characters)" });
  }

  try {
    const [result] = await pool.execute(
      "INSERT INTO tasks (title) VALUES (?)",
      [title]
    );
    res.status(201).json({ id: result.insertId, title });
  } catch (error) {
    console.error("POST /api/tasks:", error.message);
    res.status(500).json({ error: "Could not save task" });
  }
});

const port = Number(process.env.PORT || 8080);

initializeDatabase()
  .then(() => {
    app.listen(port, "0.0.0.0", () => {
      console.log(`Backend listening on ${port}`);
    });
  })
  .catch((error) => {
    console.error("Database initialization failed:", error.message);
    process.exit(1);
  });
