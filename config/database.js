const path = require("path");
const { open } = require("sqlite");
const sqlite3 = require("sqlite3");

// Path to SQLite database file
const dbPath = path.join(__dirname, "..", "userData.db");

let db = null;

/**
 * Initializes the SQLite database connection and ensures the user table exists.
 * Table schema includes unique username constraint and secure password column.
 */
const initializeDB = async () => {
  if (db) {
    return db;
  }

  try {
    db = await open({
      filename: dbPath,
      driver: sqlite3.Database,
    });

    // Create user table with UNIQUE constraint on username
    await db.exec(`
      CREATE TABLE IF NOT EXISTS user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        gender TEXT,
        location TEXT
      );
    `);

    return db;
  } catch (error) {
    console.error(`Database connection error: ${error.message}`);
    throw error;
  }
};

/**
 * Returns the active database instance.
 */
const getDB = () => db;

module.exports = {
  initializeDB,
  getDB,
  dbPath,
};
