const http = require("http");
const path = require("path");
const sqlite3 = require("sqlite3");
const { open } = require("sqlite");

const PORT = process.env.PORT || 3000;

const makeRequest = (method, endpoint, data = null) => {
  return new Promise((resolve, reject) => {
    const postData = data ? JSON.stringify(data) : "";
    const options = {
      hostname: "localhost",
      port: PORT,
      path: endpoint,
      method: method,
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(postData),
      },
    };

    const req = http.request(options, (res) => {
      let body = "";
      res.on("data", (chunk) => {
        body += chunk;
      });
      res.on("end", () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: body,
        });
      });
    });

    req.on("error", (err) => {
      reject(err);
    });

    if (postData) {
      req.write(postData);
    }
    req.end();
  });
};

const runTests = async () => {
  console.log("==================================================");
  console.log("  LAB 4: REGISTRATION, LOGIN AND JWT - TEST RUNNER");
  console.log("==================================================\n");

  // Load app in-process if not already running
  try {
    const { startServer } = require("./app.js");
    await startServer();
  } catch (e) {
    // Server or DB might already be initialized
  }

  // Allow time for server binding
  await new Promise((res) => setTimeout(res, 800));

  let passedCount = 0;
  let totalCount = 0;

  const assertTest = (description, condition, details = "") => {
    totalCount++;
    if (condition) {
      console.log(`[PASS] Test ${totalCount}: ${description}`);
      passedCount++;
    } else {
      console.error(`[FAIL] Test ${totalCount}: ${description}`);
      if (details) console.error(`       Details: ${details}`);
    }
  };

  try {
    // 1. Sanity check: GET /
    const rootRes = await makeRequest("GET", "/");
    assertTest(
      "GET / sanity check returns status 200",
      rootRes.statusCode === 200,
      `Status: ${rootRes.statusCode}`
    );

    const testUser = {
      username: "rohith_reddy",
      name: "T. Rohith Reddy",
      password: "StrongPassword@123",
      gender: "Male",
      location: "Hyderabad"
    };

    // 2. POST /register - First time (Success)
    console.log("\n--- Testing Registration ---");
    const regRes = await makeRequest("POST", "/register", testUser);
    if (regRes.statusCode === 200) {
      assertTest(
        "POST /register successfully registers new user (status 200)",
        regRes.statusCode === 200 && regRes.body === "User created successfully",
        `Status: ${regRes.statusCode}, Body: ${regRes.body}`
      );
    } else if (regRes.statusCode === 400 && regRes.body === "User already exists") {
      assertTest(
        "POST /register recognizes existing user in database (status 400)",
        true
      );
    }

    // 3. POST /register - Duplicate username (Reject with 400)
    const duplicateRes = await makeRequest("POST", "/register", testUser);
    assertTest(
      "POST /register rejects duplicate username with status 400 ('User already exists')",
      duplicateRes.statusCode === 400 && duplicateRes.body === "User already exists",
      `Status: ${duplicateRes.statusCode}, Body: ${duplicateRes.body}`
    );

    // 4. POST /register - Missing fields (Reject with 400)
    const missingRegRes = await makeRequest("POST", "/register", {
      username: "incomplete_user"
    });
    assertTest(
      "POST /register rejects missing required fields with status 400",
      missingRegRes.statusCode === 400 && missingRegRes.body === "Username, name, and password are required",
      `Status: ${missingRegRes.statusCode}, Body: ${missingRegRes.body}`
    );

    // 5. POST /login - Unknown user (Reject with 400)
    console.log("\n--- Testing Login ---");
    const unknownUserRes = await makeRequest("POST", "/login", {
      username: "non_existent_user_999",
      password: "anyPassword"
    });
    assertTest(
      "POST /login rejects unknown user with status 400 ('Invalid user')",
      unknownUserRes.statusCode === 400 && unknownUserRes.body === "Invalid user",
      `Status: ${unknownUserRes.statusCode}, Body: ${unknownUserRes.body}`
    );

    // 6. POST /login - Wrong password (Reject with 400)
    const wrongPasswordRes = await makeRequest("POST", "/login", {
      username: testUser.username,
      password: "WrongPassword999!"
    });
    assertTest(
      "POST /login rejects incorrect password with status 400 ('Invalid password')",
      wrongPasswordRes.statusCode === 400 && wrongPasswordRes.body === "Invalid password",
      `Status: ${wrongPasswordRes.statusCode}, Body: ${wrongPasswordRes.body}`
    );

    // 7. POST /login - Missing fields (Reject with 400)
    const missingLoginRes = await makeRequest("POST", "/login", {
      username: testUser.username
    });
    assertTest(
      "POST /login rejects missing password/username with status 400",
      missingLoginRes.statusCode === 400 && missingLoginRes.body === "Username and password are required",
      `Status: ${missingLoginRes.statusCode}, Body: ${missingLoginRes.body}`
    );

    // 8. POST /login - Successful login (Status 200, returns { jwt_token })
    const loginRes = await makeRequest("POST", "/login", {
      username: testUser.username,
      password: testUser.password
    });
    let parsedLogin = {};
    try {
      parsedLogin = JSON.parse(loginRes.body);
    } catch (e) {}

    assertTest(
      "POST /login with valid credentials returns status 200 and { jwt_token }",
      loginRes.statusCode === 200 && typeof parsedLogin.jwt_token === "string",
      `Status: ${loginRes.statusCode}, Body: ${loginRes.body}`
    );

    // 9. JWT Token Verification and Decoding
    console.log("\n--- Decoding & Inspecting JWT Token ---");
    const token = parsedLogin.jwt_token;
    if (token) {
      const parts = token.split(".");
      assertTest("JWT token has 3 parts (header, payload, signature)", parts.length === 3);

      const header = JSON.parse(Buffer.from(parts[0], "base64url").toString());
      const payload = JSON.parse(Buffer.from(parts[1], "base64url").toString());

      console.log("\n[Decoded JWT Token Structure]:");
      console.log("1. Header:", JSON.stringify(header, null, 2));
      console.log("2. Payload:", JSON.stringify(payload, null, 2));
      console.log("3. Signature (Base64URL):", parts[2]);

      assertTest(
        "Payload contains only username (no plain password)",
        payload.username === testUser.username && payload.password === undefined,
        `Payload keys: ${Object.keys(payload).join(", ")}`
      );
    }

    // 10. Inspect Database to prove passwords are saved as hashes
    console.log("\n--- Inspecting SQLite Database ---");
    const db = await open({
      filename: path.join(__dirname, "userData.db"),
      driver: sqlite3.Database,
    });
    const users = await db.all("SELECT id, username, name, password, gender, location FROM user;");
    console.log(`Found ${users.length} user(s) in userData.db:`);
    users.forEach((u) => {
      console.log(`- ID: ${u.id} | User: ${u.username} | Name: ${u.name}`);
      console.log(`  Hashed Password: ${u.password}`);
    });

    const storedHash = users.find((u) => u.username === testUser.username)?.password || "";
    assertTest(
      "Password stored in database is a bcrypt hash ($2b$10$...) and NOT plain text",
      storedHash.startsWith("$2b$") && storedHash !== testUser.password
    );

    console.log("\n==================================================");
    console.log(`Summary: ${passedCount}/${totalCount} tests passed.`);
    console.log("==================================================\n");

    if (passedCount === totalCount) {
      console.log("ALL LAB 4 REQUIREMENTS VERIFIED SUCCESSFULLY!\n");
      process.exit(0);
    } else {
      process.exit(1);
    }
  } catch (err) {
    console.error("Test execution error:", err);
    process.exit(1);
  }
};

runTests();
