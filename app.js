const express = require("express");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const { initializeDB } = require("./config/database");

const app = express();

// Middleware to parse JSON request bodies
app.use(express.json());

// JWT Secret Key stored in a constant (as per Lab 4 specification)
const JWT_SECRET = "AURORA_BACKEND_LAB_04_JWT_SECRET_KEY_2026";

let db = null;

// Initialize Database connection and Express Server
const startServer = async () => {
  try {
    db = await initializeDB();
    const PORT = process.env.PORT || 3000;
    const server = app.listen(PORT, () => {
      console.log(`Server Running at http://localhost:${PORT}/`);
    });
    return server;
  } catch (error) {
    console.error(`Failed to start server: ${error.message}`);
    process.exit(1);
  }
};

// Root route: Health check and lab details
app.get("/", (req, res) => {
  res.status(200).json({
    course: "Backend Development Fundamentals - Aurora",
    lab: "Lab 4: Registration, login and JWT",
    status: "Server is running",
    endpoints: {
      register: "POST /register/ (or /register)",
      login: "POST /login/ (or /login)"
    }
  });
});

/**
 * Task 3: POST /register and /register/
 * Requirements:
 * 1. Accept username, name and password (with optional gender and location).
 * 2. Validate presence of required fields.
 * 3. Check whether username already exists using parameterized query.
 * 4. If username exists, return HTTP 400.
 * 5. Hash password using bcrypt.hash() with salt rounds = 10.
 * 6. Store username, name, and hashed password in SQLite.
 * 7. Never store plain-text passwords.
 * 8. Return success response.
 */
const handleRegister = async (req, res) => {
  try {
    if (!db) {
      db = await initializeDB();
    }

    const { username, name, password, gender, location } = req.body;

    // Validate required fields
    if (!username || !name || !password) {
      return res.status(400).send("Username, name, and password are required");
    }

    // Check if user already exists using a parameterized query to prevent SQL injection
    const selectUserQuery = `SELECT * FROM user WHERE username = ?;`;
    const dbUser = await db.get(selectUserQuery, [username]);

    if (dbUser !== undefined) {
      // Username is already taken: reject with HTTP 400
      return res.status(400).send("User already exists");
    }

    // Hash password with bcrypt (10 salt rounds)
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert new user record using parameterized values
    const createUserQuery = `
      INSERT INTO user (username, name, password, gender, location)
      VALUES (?, ?, ?, ?, ?);
    `;
    await db.run(createUserQuery, [
      username,
      name,
      hashedPassword,
      gender || null,
      location || null
    ]);

    // Return success response (HTTP 200)
    return res.status(200).send("User created successfully");
  } catch (error) {
    console.error(`Registration error: ${error.message}`);
    return res.status(500).send("Internal Server Error");
  }
};

app.post("/register", handleRegister);
app.post("/register/", handleRegister);

/**
 * Task 4 & 5: POST /login and /login/
 * Requirements:
 * 1. Accept username and password.
 * 2. Validate presence of required fields.
 * 3. Check whether username exists using parameterized query.
 * 4. If username does not exist, return HTTP 400 ("Invalid user").
 * 5. Verify password using bcrypt.compare() against stored hash.
 * 6. If password does not match, return HTTP 400 ("Invalid password").
 * 7. If credentials match, generate a JWT with jwt.sign().
 * 8. Include ONLY username in JWT payload (never the password).
 * 9. Return JSON response format: { "jwt_token": "generated_token" }.
 */
const handleLogin = async (req, res) => {
  try {
    if (!db) {
      db = await initializeDB();
    }

    const { username, password } = req.body;

    // Validate required fields
    if (!username || !password) {
      return res.status(400).send("Username and password are required");
    }

    // Check if user exists using parameterized query
    const selectUserQuery = `SELECT * FROM user WHERE username = ?;`;
    const dbUser = await db.get(selectUserQuery, [username]);

    if (dbUser === undefined) {
      // User not registered: reject with HTTP 400
      return res.status(400).send("Invalid user");
    }

    // Securely compare provided plain password against stored bcrypt hash
    const isPasswordMatched = await bcrypt.compare(password, dbUser.password);

    if (!isPasswordMatched) {
      // Password mismatch: reject with HTTP 400
      return res.status(400).send("Invalid password");
    }

    // Create JWT payload containing strictly non-sensitive identity (username only)
    const payload = {
      username: dbUser.username
    };

    // Generate token signed with secret constant
    const jwtToken = jwt.sign(payload, JWT_SECRET, { expiresIn: "30d" });

    // Return response with jwt_token
    return res.status(200).json({ jwt_token: jwtToken });
  } catch (error) {
    console.error(`Login error: ${error.message}`);
    return res.status(500).send("Internal Server Error");
  }
};

app.post("/login", handleLogin);
app.post("/login/", handleLogin);

// Start server if script is run directly
if (require.main === module) {
  startServer();
}

module.exports = { app, startServer, JWT_SECRET };
