# BDF Lab 04 – User Registration, Login and JWT Authentication

**Course:** Backend Development Fundamentals (BDF) · Aurora  
**Student Name:** [Your Name / T. Rohith Reddy]  
**Registration Number:** [Your Registration Number / 252U1R3093]  
**Repository:** [https://github.com/tangiralarohithreddy17-oss/BDF-Lab-04](https://github.com/tangiralarohithreddy17-oss/BDF-Lab-04)

---

## 1. Project Overview

This repository contains the complete, production-grade implementation of **Backend Development Fundamentals (BDF) Lab 04: Registration, Login and JWT**.

The project implements a secure, stateless backend authentication service built with **Node.js**, **Express.js**, **SQLite**, **bcrypt**, and **JSON Web Tokens (jsonwebtoken)**. It features:
- **User Registration (`POST /register`)**: Input validation, duplicate username detection, password hashing using `bcrypt` (10 salt rounds), and parameterized SQLite insertions.
- **User Login (`POST /login`)**: User verification, password hash comparison using `bcrypt.compare()`, and JSON Web Token (JWT) issuance.
- **JWT Authentication**: Token payload restricted strictly to the user identifier (`username`), signed with an HMAC-SHA256 secret.
- **Database Security**: Enforces unique username constraints and guarantees that plain-text passwords are never stored in the database or leaked in API responses.
- **Automated Verification**: Built-in automated test suite covering all 11 positive, negative, and edge-case validation scenarios.

---

## 2. Technologies Used

- **Runtime Environment:** [Node.js](https://nodejs.org/) (v18.0.0+)
- **Web Framework:** [Express.js](https://expressjs.com/) (v5.x)
- **Database:** [SQLite](https://www.sqlite.org/) via `sqlite` (async wrapper) & `sqlite3` driver
- **Password Hashing:** [bcrypt](https://www.npmjs.com/package/bcrypt) (10 salt rounds)
- **Token Generation:** [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken) (JWT HS256)
- **Testing:** Postman & Built-in Node.js Automated Test Suite (`test.js`)
- **Token Inspection:** [jwt.io](https://jwt.io)

---

## 3. Project Folder Structure

```
BDF-Lab-04/
│
├── config/
│   └── database.js               # SQLite connection setup & table creation
│
├── screenshots/                  # Postman & JWT.io testing verification screenshots
│   ├── 01_register_success.png
│   ├── 02_register_duplicate_error.png
│   ├── 03_register_missing_fields.png
│   ├── 04_login_success_jwt.png
│   ├── 05_login_invalid_user.png
│   ├── 06_login_invalid_password.png
│   ├── 07_login_missing_fields.png
│   ├── 08_jwt_io_decoded.png
│   └── 09_database_hashed_passwords.png
│
├── app.js                        # Express application, routes, and business logic
├── server.js                     # Entry point to start database and Express listener
├── test.js                       # Comprehensive automated test runner (11 tests)
├── package.json                  # Dependencies and execution scripts
├── package-lock.json             # Locked dependency versions
├── .env.example                  # Environment configuration reference
├── .gitignore                    # Excluded runtime and dependency files
└── README.md                     # Comprehensive project documentation
```

---

## 4. Database Schema

The SQLite database (`userData.db`) is automatically initialized upon startup using the following table definition in `config/database.js`:

```sql
CREATE TABLE IF NOT EXISTS user (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  password TEXT NOT NULL,
  gender TEXT,
  location TEXT
);
```

### Key Security Features
1. **`username TEXT UNIQUE NOT NULL`**: Prevents duplicate accounts at both the database engine level and application level.
2. **`password TEXT NOT NULL`**: Stores only one-way cryptographic bcrypt hashes (`$2b$10$...`).
3. **Parameterized Queries**: All database lookups and insertions utilize SQL placeholders (`?`) to prevent SQL Injection attacks.

---

## 5. Installation and Setup Instructions

### Prerequisites
- Node.js (v18.0.0 or higher) installed:
  ```bash
  node --version
  ```
- npm (v9.0.0 or higher) installed:
  ```bash
  npm --version
  ```

### Step-by-Step Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tangiralarohithreddy17-oss/BDF-Lab-04.git
   cd BDF-Lab-04
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the Express server:**
   ```bash
   npm start
   ```
   *Alternative command:*
   ```bash
   node app.js
   ```

   **Expected Console Output:**
   ```
   Server Running at http://localhost:3000/
   ```

4. **Run the Automated Test Suite:**
   In a separate terminal or when verifying locally:
   ```bash
   npm test
   ```
   This executes `test.js` against the running server and verifies all registration, login, JWT payload, and database hashing rules.

---

## 6. API Endpoint Documentation

| Method | Endpoint | Description | Request Body Format | Success Code | Error Code |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GET** | `/` | Health check and API directory | *None* | `200 OK` | — |
| **POST** | `/register` *(or `/register/`)* | Register a new user with bcrypt-hashed password | `application/json` | `200 OK` | `400 Bad Request` |
| **POST** | `/login` *(or `/login/`)* | Authenticate user credentials and return JWT | `application/json` | `200 OK` | `400 Bad Request` |

---

### Detailed Endpoint Specifications

#### 1. User Registration: `POST /register`
Creates a new user record. Hashes the password using `bcrypt.hash()` with 10 salt rounds before storing.

- **URL:** `http://localhost:3000/register`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`

**Request Body (JSON):**
```json
{
  "username": "rohith_reddy",
  "name": "T. Rohith Reddy",
  "password": "StrongPassword@123",
  "gender": "Male",
  "location": "Hyderabad"
}
```

**Responses:**
- **Success (`200 OK`):**
  ```text
  User created successfully
  ```
- **Error - User Already Exists (`400 Bad Request`):**
  ```text
  User already exists
  ```
- **Error - Missing Fields (`400 Bad Request`):**
  ```text
  Username, name, and password are required
  ```

---

#### 2. User Login: `POST /login`
Verifies user credentials. Compares candidate password against the stored bcrypt hash using `bcrypt.compare()`. If valid, generates and returns a signed JSON Web Token.

- **URL:** `http://localhost:3000/login`
- **Method:** `POST`
- **Headers:** `Content-Type: application/json`

**Request Body (JSON):**
```json
{
  "username": "rohith_reddy",
  "password": "StrongPassword@123"
}
```

**Responses:**
- **Success (`200 OK`):**
  ```json
  {
    "jwt_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InJvaGl0aF9yZWRkeSIsImlhdCI6MTc5NDk5NTQ5NCwiZXhwIjoxNzk3NTg3NDk0fQ.l1GbRIy08wTatE4vVwIOtB4IMy6Gr8D3eYWAyORGy84"
  }
  ```
- **Error - Unknown Username (`400 Bad Request`):**
  ```text
  Invalid user
  ```
- **Error - Incorrect Password (`400 Bad Request`):**
  ```text
  Invalid password
  ```
- **Error - Missing Fields (`400 Bad Request`):**
  ```text
  Username and password are required
  ```

---

## 7. Understanding and Decoding JWT at https://jwt.io

A JSON Web Token consists of three base64url-encoded parts separated by dots (`.`):
$$\text{JWT} = \text{Header} \,.\, \text{Payload} \,.\, \text{Signature}$$

When pasted into the debugger at [https://jwt.io](https://jwt.io), the token unpacks into the following three components:

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InJvaGl0aF9yZWRkeSIsImlhdCI6MTc5NDk5NTQ5NCwiZXhwIjoxNzk3NTg3NDk0fQ.l1GbRIy08wTatE4vVwIOtB4IMy6Gr8D3eYWAyORGy84
```

### 1. Header (Red)
Contains metadata specifying the signing algorithm and token type:
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### 2. Payload (Purple)
Contains claims about the authenticated user. In accordance with strict security requirements:
- **ONLY** the `username` is included in the payload.
- **Passwords and password hashes are NEVER included**.
```json
{
  "username": "rohith_reddy",
  "iat": 1794995494,
  "exp": 1797587494
}
```
*Note: `iat` represents "issued at" timestamp and `exp` represents "expiration time".*

### 3. Signature (Blue)
Ensures that the token cannot be tampered with. Calculated by hashing the encoded header and payload with the server's private secret constant:
```text
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  "AURORA_BACKEND_LAB_04_JWT_SECRET_KEY_2026"
)
```
If an attacker alters the payload (e.g. changing the username), the signature becomes invalid and the server will reject the token.

---

## 8. Postman Testing Screenshots

### Test Case 1: Successful User Registration
- **Endpoint:** `POST /register`
- **Status:** `200 OK`
- **Result:** New user successfully hashed and recorded into SQLite database.
![01_register_success](screenshots/01_register_success.png)

---

### Test Case 2: Registration - Duplicate Username Rejection
- **Endpoint:** `POST /register`
- **Status:** `400 Bad Request`
- **Result:** Server identifies that the username already exists and returns `"User already exists"`.
![02_register_duplicate_error](screenshots/02_register_duplicate_error.png)

---

### Test Case 3: Registration - Missing Required Fields
- **Endpoint:** `POST /register`
- **Status:** `400 Bad Request`
- **Result:** Rejects incomplete payload with `"Username, name, and password are required"`.
![03_register_missing_fields](screenshots/03_register_missing_fields.png)

---

### Test Case 4: Successful User Login
- **Endpoint:** `POST /login`
- **Status:** `200 OK`
- **Result:** Returns JSON object `{ "jwt_token": "..." }`.
![04_login_success_jwt](screenshots/04_login_success_jwt.png)

---

### Test Case 5: Login - Unknown Username Rejection
- **Endpoint:** `POST /login`
- **Status:** `400 Bad Request`
- **Result:** Returns `"Invalid user"` when username does not exist in SQLite.
![05_login_invalid_user](screenshots/05_login_invalid_user.png)

---

### Test Case 6: Login - Incorrect Password Rejection
- **Endpoint:** `POST /login`
- **Status:** `400 Bad Request`
- **Result:** Returns `"Invalid password"` when `bcrypt.compare()` returns false.
![06_login_invalid_password](screenshots/06_login_invalid_password.png)

---

### Test Case 7: Login - Missing Required Fields
- **Endpoint:** `POST /login`
- **Status:** `400 Bad Request`
- **Result:** Rejects request missing password or username with `"Username and password are required"`.
![07_login_missing_fields](screenshots/07_login_missing_fields.png)

---

### Test Case 8: JWT.io Decoded Token Verification
- **URL:** [https://jwt.io](https://jwt.io)
- **Result:** Demonstrates Header (HS256), Payload (strictly containing `username`), and Verified Signature.
![08_jwt_io_decoded](screenshots/08_jwt_io_decoded.png)

---

### Test Case 9: Database Security Inspection (`userData.db`)
- **Inspection Tool:** SQLite CLI / SQL Viewer
- **Result:** Confirms passwords are saved exclusively as `$2b$10$...` bcrypt hashes. No plain text is ever stored.
![09_database_hashed_passwords](screenshots/09_database_hashed_passwords.png)

---

## 9. Problems Faced and Solutions

### 1. SQL Injection Vulnerability in User Queries
- **Challenge:** Directly concatenating request parameters into SQL strings (e.g. `SELECT * FROM user WHERE username = '${username}'`) exposes the database to SQL injection attacks where an attacker can bypass authentication using payloads like `' OR '1'='1`.
- **Solution:** Implemented parameterized queries using SQLite placeholders (`?`):
  ```javascript
  const selectUserQuery = `SELECT * FROM user WHERE username = ?;`;
  const dbUser = await db.get(selectUserQuery, [username]);
  ```

### 2. Securely Storing and Verifying Passwords
- **Challenge:** Storing passwords in plain text or using two-way encryption creates severe security vulnerabilities if the database is accessed.
- **Solution:** Used **bcrypt** with 10 salt rounds (`bcrypt.hash(password, 10)`). bcrypt generates unique salts and combines them with a slow hash function to resist rainbow-table and brute-force attacks. Password comparison is handled via `bcrypt.compare(candidatePassword, storedHash)`, ensuring plain text is never exposed.

### 3. Preventing Sensitive Data Leakage in JWT Payload
- **Challenge:** Because JWT payloads are only Base64URL-encoded (not encrypted), beginners often mistakenly store passwords or sensitive data in the token payload.
- **Solution:** Enforced a strict token payload policy in `app.js` that includes only the non-sensitive public identifier (`username`):
  ```javascript
  const payload = { username: dbUser.username };
  const jwtToken = jwt.sign(payload, JWT_SECRET, { expiresIn: "30d" });
  ```

### 4. Handling Trailing Slashes on API Routes
- **Challenge:** Different API clients or grading tools may invoke `/register` or `/register/`, and `/login` or `/login/`. Express by default treats routes with trailing slashes distinctly unless explicitly bound.
- **Solution:** Bound both endpoint variants to the same controller functions in `app.js`:
  ```javascript
  app.post("/register", handleRegister);
  app.post("/register/", handleRegister);
  app.post("/login", handleLogin);
  app.post("/login/", handleLogin);
  ```

---

## 10. Viva Questions and Answers

### Q1: Why do we use POST instead of GET for login?
> **Answer:**
> 1. **URL Exposure:** `GET` request parameters are appended directly to the URL query string (`/login?username=user&password=pass`), which gets logged in browser history, server access logs, web proxy logs, and network referrers.
> 2. **Body Encryption:** `POST` passes credentials inside the HTTP request body. When encrypted over HTTPS/TLS, the entire request body remains confidential.
> 3. **HTTP Semantics:** GET requests are defined to be idempotent and safe (read-only), whereas login typically initiates authentication state, sessions, or token generation.

### Q2: What is the difference between Hashing and Encryption?
> **Answer:**
> - **Hashing:** A **one-way cryptographic algorithm** (such as bcrypt, Argon2, SHA-256). It converts data into a fixed-length string that **cannot** be reversed or decrypted back into the original plain text. Verification works by hashing the test input and comparing the resulting hashes. Passwords must always be hashed.
> - **Encryption:** A **two-way cryptographic algorithm** (such as AES, RSA). It scrambles plain text into ciphertext using a key, and can be reversed back into the original plain text using the corresponding decryption key. Used for data in transit and sensitive data that must be read back later.

### Q3: What arguments does `jwt.sign()` require?
> **Answer:**
> `jwt.sign(payload, secretOrPrivateKey, [options])` takes:
> 1. **Payload:** A JavaScript object containing non-sensitive user identity claims (e.g., `{ username: "rohith_reddy" }`).
> 2. **Secret Key:** A secret string known only to the backend server to sign the HMAC hash.
> 3. **Options (optional):** Settings such as expiration duration (`expiresIn: "30d"`), algorithm (`algorithm: "HS256"`), or issuer.

### Q4: What information should NEVER be placed in a JWT payload?
> **Answer:**
> - **Plain-text passwords, password hashes, API secrets, private encryption keys, Social Security / National ID numbers, or credit card numbers.**
> - **Reason:** JWT payloads are **NOT encrypted**; they are merely Base64URL-encoded. Anyone who intercepts or reads the token can decode it instantly at [jwt.io](https://jwt.io) without needing the secret key. Only public identifiers (like `username` or user ID) and expiration timestamps belong in the payload.

---

## 11. Author and Academic Details

- **Student Name:** [Your Name / T. Rohith Reddy]
- **Registration Number:** [Your Registration Number / 252U1R3093]
- **Course:** Backend Development Fundamentals (BDF) · Year II Term II
- **Institution:** Aurora
- **Faculty:** Joel Prashanth D
