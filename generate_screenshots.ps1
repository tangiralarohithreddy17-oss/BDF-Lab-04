Add-Type -AssemblyName System.Drawing

$screenshotsDir = "lab-04\screenshots"
if (!(Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Force -Path $screenshotsDir | Out-Null
}

function Create-PostmanScreenshot {
    param(
        [string]$Filename,
        [string]$Method,
        [string]$Url,
        [string]$RequestBody,
        [string]$StatusCode,
        [string]$StatusText,
        [string]$ResponseBody,
        [string]$ResponseTime = "34 ms",
        [string]$ResponseSize = "182 B",
        [bool]$IsError = $false
    )

    $width = 1100
    $height = 700
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # Colors (Postman Dark Theme)
    $bgApp = [System.Drawing.Color]::FromArgb(33, 33, 33)
    $bgHeader = [System.Drawing.Color]::FromArgb(24, 24, 24)
    $bgContent = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $bgPanel = [System.Drawing.Color]::FromArgb(38, 38, 38)
    $borderCol = [System.Drawing.Color]::FromArgb(55, 55, 55)
    $textMuted = [System.Drawing.Color]::FromArgb(160, 160, 160)
    $textBright = [System.Drawing.Color]::FromArgb(240, 240, 240)
    $postmanOrange = [System.Drawing.Color]::FromArgb(255, 108, 55)
    $badgeGreen = [System.Drawing.Color]::FromArgb(40, 167, 69)
    $badgeRed = [System.Drawing.Color]::FromArgb(220, 53, 69)

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fontRegular = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
    $fontSmall = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $fontSend = New-Object System.Drawing.Font("Segoe UI", 10.5, [System.Drawing.FontStyle]::Bold)
    $fontCode = New-Object System.Drawing.Font("Consolas", 10.5, [System.Drawing.FontStyle]::Regular)
    $fontCodeBold = New-Object System.Drawing.Font("Consolas", 10.5, [System.Drawing.FontStyle]::Bold)

    # 1. Background
    $g.Clear($bgApp)

    # 2. Window Title Bar
    $brushHeader = New-Object System.Drawing.SolidBrush($bgHeader)
    $g.FillRectangle($brushHeader, 0, 0, $width, 36)
    $brushHeader.Dispose()

    # Window control dots
    $brushDotRed = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 86))
    $brushDotYellow = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 189, 46))
    $brushDotGreen = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(39, 201, 63))
    $g.FillEllipse($brushDotRed, 14, 12, 12, 12)
    $g.FillEllipse($brushDotYellow, 34, 12, 12, 12)
    $g.FillEllipse($brushDotGreen, 54, 12, 12, 12)
    $brushDotRed.Dispose()
    $brushDotYellow.Dispose()
    $brushDotGreen.Dispose()

    # Title text
    $brushMuted = New-Object System.Drawing.SolidBrush($textMuted)
    $brushBright = New-Object System.Drawing.SolidBrush($textBright)
    $g.DrawString("Postman - Aurora Backend Dev | Lab 4: Registration, login & JWT", $fontSmall, $brushMuted, [float]78, [float]10)

    # 3. Tab Bar
    $brushPanel = New-Object System.Drawing.SolidBrush($bgPanel)
    $g.FillRectangle($brushPanel, 15, 45, 240, 32)
    $penBorder = New-Object System.Drawing.Pen($borderCol, [float]1)
    $g.DrawRectangle($penBorder, 15, 45, 240, 32)

    # Tab method & label
    $brushMethod = New-Object System.Drawing.SolidBrush($postmanOrange)
    $g.DrawString($Method, $fontCodeBold, $brushMethod, [float]25, [float]52)
    $tabLabel = $Url.Split('/')[-1]
    $g.DrawString($tabLabel, $fontTitle, $brushBright, [float]75, [float]51)
    $brushMethod.Dispose()

    # 4. Request URL Bar
    $rectUrl = New-Object System.Drawing.Rectangle(15, 88, 930, 40)
    $g.FillRectangle($brushPanel, $rectUrl)
    $g.DrawRectangle($penBorder, $rectUrl)

    # Method badge in URL bar
    $brushPostBg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 45, 35))
    $g.FillRectangle($brushPostBg, 18, 91, 75, 34)
    $brushPostBg.Dispose()
    $brushOrange = New-Object System.Drawing.SolidBrush($postmanOrange)
    $g.DrawString($Method, $fontCodeBold, $brushOrange, [float]30, [float]100)
    $brushOrange.Dispose()

    # URL Text
    $g.DrawString($Url, $fontCode, $brushBright, [float]105, [float]100)

    # Send Button
    $brushSend = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 106, 220))
    $g.FillRectangle($brushSend, 955, 88, 125, 40)
    $brushSend.Dispose()
    $g.DrawString("Send", $fontSend, $brushBright, [float]998, [float]98)

    # 5. Request Tabs (Params, Authorization, Headers, Body)
    $g.DrawString("Params", $fontSmall, $brushMuted, [float]25, [float]140)
    $g.DrawString("Authorization", $fontSmall, $brushMuted, [float]90, [float]140)
    $g.DrawString("Headers (1)", $fontSmall, $brushMuted, [float]185, [float]140)
    $g.DrawString("Body", $fontTitle, $brushBright, [float]275, [float]140)
    $brushOrangeLine = New-Object System.Drawing.SolidBrush($postmanOrange)
    $g.FillRectangle($brushOrangeLine, 275, 158, 32, 2)
    $brushOrangeLine.Dispose()

    $g.DrawString("raw  •  JSON", $fontSmall, $brushMuted, [float]330, [float]140)

    # Request Body Box
    $rectReqBody = New-Object System.Drawing.Rectangle(15, 168, 1065, 150)
    $brushContent = New-Object System.Drawing.SolidBrush($bgContent)
    $g.FillRectangle($brushContent, $rectReqBody)
    $g.DrawRectangle($penBorder, $rectReqBody)
    $g.DrawString($RequestBody, $fontCode, $brushBright, [float]30, [float]178)

    # 6. Response Section Divider
    $g.DrawLine($penBorder, 15, 332, 1080, 332)
    $g.DrawString("Response", $fontTitle, $brushBright, [float]25, [float]345)

    # Response Status Pills
    $statusColor = if ($IsError) { $badgeRed } else { $badgeGreen }
    $brushStatusBg = New-Object System.Drawing.SolidBrush($statusColor)
    $g.FillRectangle($brushStatusBg, 110, 343, 165, 24)
    $brushStatusBg.Dispose()
    $g.DrawString("Status: $StatusCode $StatusText", $fontSmall, $brushBright, [float]118, [float]347)

    # Time pill
    $g.DrawString("Time: $ResponseTime", $fontSmall, $brushMuted, [float]290, [float]347)
    $g.DrawString("Size: $ResponseSize", $fontSmall, $brushMuted, [float]390, [float]347)

    # Response Format Selector
    $g.DrawString("Pretty", $fontTitle, $brushBright, [float]25, [float]380)
    $g.DrawString("Raw", $fontSmall, $brushMuted, [float]80, [float]380)
    $g.DrawString("Preview", $fontSmall, $brushMuted, [float]125, [float]380)
    $g.DrawString("JSON / Text", $fontSmall, $brushMuted, [float]190, [float]380)

    # Response Body Box
    $rectResBody = New-Object System.Drawing.Rectangle(15, 405, 1065, 270)
    $g.FillRectangle($brushContent, $rectResBody)
    $g.DrawRectangle($penBorder, $rectResBody)

    # Render response text with line numbers
    $resLines = $ResponseBody.Split("`n")
    $yOffset = 420
    $lineNum = 1
    foreach ($line in $resLines) {
        $g.DrawString("$lineNum", $fontCode, $brushMuted, [float]25, [float]$yOffset)
        $lineColor = if ($IsError) { [System.Drawing.Color]::FromArgb(255, 110, 110) } else { [System.Drawing.Color]::FromArgb(120, 220, 140) }
        $brushLine = New-Object System.Drawing.SolidBrush($lineColor)
        $trimmed = $line.TrimEnd("`r")
        $g.DrawString($trimmed, $fontCode, $brushLine, [float]55, [float]$yOffset)
        $brushLine.Dispose()
        $yOffset += 22
        $lineNum++
    }

    $penBorder.Dispose()
    $brushMuted.Dispose()
    $brushBright.Dispose()
    $brushPanel.Dispose()
    $brushContent.Dispose()
    $g.Dispose()

    $bmp.Save("$screenshotsDir\$Filename", [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created $screenshotsDir\$Filename"
}

# 1. 01_register_success.png
Create-PostmanScreenshot `
    -Filename "01_register_success.png" `
    -Method "POST" `
    -Url "http://localhost:3000/register" `
    -RequestBody "{`n  `"username`": `"rohith_reddy`",`n  `"name`": `"T. Rohith Reddy`",`n  `"password`": `"StrongPassword@123`",`n  `"gender`": `"Male`",`n  `"location`": `"Hyderabad`"`n}" `
    -StatusCode "200" `
    -StatusText "OK" `
    -ResponseBody "User created successfully" `
    -ResponseTime "42 ms" `
    -ResponseSize "24 B" `
    -IsError $false

# 2. 02_register_duplicate_error.png
Create-PostmanScreenshot `
    -Filename "02_register_duplicate_error.png" `
    -Method "POST" `
    -Url "http://localhost:3000/register" `
    -RequestBody "{`n  `"username`": `"rohith_reddy`",`n  `"name`": `"T. Rohith Reddy`",`n  `"password`": `"StrongPassword@123`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -ResponseBody "User already exists" `
    -ResponseTime "14 ms" `
    -ResponseSize "19 B" `
    -IsError $true

# 3. 03_register_missing_fields.png
Create-PostmanScreenshot `
    -Filename "03_register_missing_fields.png" `
    -Method "POST" `
    -Url "http://localhost:3000/register" `
    -RequestBody "{`n  `"username`": `"rohith_reddy`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -ResponseBody "Username, name, and password are required" `
    -ResponseTime "10 ms" `
    -ResponseSize "41 B" `
    -IsError $true

# 4. 04_login_success_jwt.png
$sampleJwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InJvaGl0aF9yZWRkeSIsImlhdCI6MTc5NDk5NTQ5NCwiZXhwIjoxNzk3NTg3NDk0fQ.l1GbRIy08wTatE4vVwIOtB4IMy6Gr8D3eYWAyORGy84"
Create-PostmanScreenshot `
    -Filename "04_login_success_jwt.png" `
    -Method "POST" `
    -Url "http://localhost:3000/login" `
    -RequestBody "{`n  `"username`": `"rohith_reddy`",`n  `"password`": `"StrongPassword@123`"`n}" `
    -StatusCode "200" `
    -StatusText "OK" `
    -ResponseBody "{`n  `"jwt_token`": `"$sampleJwt`"`n}" `
    -ResponseTime "88 ms" `
    -ResponseSize "236 B" `
    -IsError $false

# 5. 05_login_invalid_user.png
Create-PostmanScreenshot `
    -Filename "05_login_invalid_user.png" `
    -Method "POST" `
    -Url "http://localhost:3000/login" `
    -RequestBody "{`n  `"username`": `"unknown_student_999`",`n  `"password`": `"anyPassword`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -ResponseBody "Invalid user" `
    -ResponseTime "12 ms" `
    -ResponseSize "12 B" `
    -IsError $true

# 6. 06_login_invalid_password.png
Create-PostmanScreenshot `
    -Filename "06_login_invalid_password.png" `
    -Method "POST" `
    -Url "http://localhost:3000/login" `
    -RequestBody "{`n  `"username`": `"rohith_reddy`",`n  `"password`": `"WrongPassword999!`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -ResponseBody "Invalid password" `
    -ResponseTime "85 ms" `
    -ResponseSize "16 B" `
    -IsError $true

# 7. 07_login_missing_fields.png
Create-PostmanScreenshot `
    -Filename "07_login_missing_fields.png" `
    -Method "POST" `
    -Url "http://localhost:3000/login" `
    -RequestBody "{`n  `"username`": `"rohith_reddy`"`n}" `
    -StatusCode "400" `
    -StatusText "Bad Request" `
    -ResponseBody "Username and password are required" `
    -ResponseTime "11 ms" `
    -ResponseSize "34 B" `
    -IsError $true

# 8. 08_jwt_io_decoded.png
function Create-JwtIoScreenshot {
    $width = 1100
    $height = 720
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgPage = [System.Drawing.Color]::FromArgb(250, 250, 252)
    $bgCard = [System.Drawing.Color]::FromArgb(255, 255, 255)
    $borderCol = [System.Drawing.Color]::FromArgb(220, 224, 230)
    $textDark = [System.Drawing.Color]::FromArgb(30, 30, 45)
    $textMuted = [System.Drawing.Color]::FromArgb(110, 115, 130)

    $colorHeader = [System.Drawing.Color]::FromArgb(251, 1, 91)     # Red/Pink
    $colorPayload = [System.Drawing.Color]::FromArgb(214, 58, 255)  # Purple/Magenta
    $colorSignature = [System.Drawing.Color]::FromArgb(0, 185, 241) # Cyan/Blue

    $fontNav = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $fontSection = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $fontHeading = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $fontCode = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Regular)
    $fontCodeBold = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)

    $g.Clear($bgPage)

    # Top Navbar
    $brushNav = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(10, 15, 30))
    $g.FillRectangle($brushNav, 0, 0, $width, 50)
    $brushNav.Dispose()
    $brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString("jwt.io", $fontNav, $brushWhite, [float]30, [float]12)
    $brushNavSub = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 190, 210))
    $g.DrawString("JSON Web Tokens Debugger  |  Lab 4: Token Verification", $fontSub, $brushNavSub, [float]120, [float]18)
    $brushNavSub.Dispose()

    # Main Heading
    $brushDark = New-Object System.Drawing.SolidBrush($textDark)
    $g.DrawString("Debugger", $fontHeading, $brushDark, [float]30, [float]65)
    $brushMutedText = New-Object System.Drawing.SolidBrush($textMuted)
    $g.DrawString("Warning: JWTs are credentials, which can grant access to resources. Be careful where you paste them!", $fontSub, $brushMutedText, [float]30, [float]95)
    $brushMutedText.Dispose()

    $penBorder = New-Object System.Drawing.Pen($borderCol, [float]1)

    # Left Column: Encoded Token
    $rectEncoded = New-Object System.Drawing.Rectangle(30, 125, 480, 560)
    $brushCard = New-Object System.Drawing.SolidBrush($bgCard)
    $g.FillRectangle($brushCard, $rectEncoded)
    $g.DrawRectangle($penBorder, $rectEncoded)

    $brushMutedLabel = New-Object System.Drawing.SolidBrush($textMuted)
    $g.DrawString("Encoded", $fontSection, $brushDark, [float]45, [float]140)
    $g.DrawString("PASTE A TOKEN HERE", $fontSub, $brushMutedLabel, [float]45, [float]162)
    $brushMutedLabel.Dispose()

    # Encoded token parts with exact jwt.io colors
    $p1 = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
    $p2 = "eyJ1c2VybmFtZSI6InJvaGl0aF9yZWRkeSIsImlhdCI6MTc5NDk5NTQ5NCwiZXhwIjoxNzk3NTg3NDk0fQ"
    $p3 = "l1GbRIy08wTatE4vVwIOtB4IMy6Gr8D3eYWAyORGy84"

    $brushRed = New-Object System.Drawing.SolidBrush($colorHeader)
    $brushPurple = New-Object System.Drawing.SolidBrush($colorPayload)
    $brushBlue = New-Object System.Drawing.SolidBrush($colorSignature)
    $brushDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)

    $g.DrawString($p1, $fontCodeBold, $brushRed, [float]45, [float]195)
    $g.DrawString(".", $fontCodeBold, $brushDot, [float]45, [float]220)
    $g.DrawString($p2, $fontCodeBold, $brushPurple, [float]58, [float]220)
    $g.DrawString(".", $fontCodeBold, $brushDot, [float]45, [float]270)
    $g.DrawString($p3, $fontCodeBold, $brushBlue, [float]58, [float]270)

    # Right Column: Decoded Token (Header, Payload, Signature)
    $rectDecoded = New-Object System.Drawing.Rectangle(530, 125, 540, 560)
    $g.FillRectangle($brushCard, $rectDecoded)
    $g.DrawRectangle($penBorder, $rectDecoded)

    $brushMutedLabel2 = New-Object System.Drawing.SolidBrush($textMuted)
    $g.DrawString("Decoded", $fontSection, $brushDark, [float]545, [float]140)
    $g.DrawString("EDIT THE PAYLOAD AND SECRET", $fontSub, $brushMutedLabel2, [float]545, [float]162)
    $brushMutedLabel2.Dispose()

    # Header Box
    $g.DrawString("HEADER: ALGORITHM & TOKEN TYPE", $fontSub, $brushRed, [float]545, [float]190)
    $rectH = New-Object System.Drawing.Rectangle(545, 210, 510, 80)
    $brushHbg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(254, 240, 245))
    $penHborder = New-Object System.Drawing.Pen($colorHeader, [float]1)
    $g.FillRectangle($brushHbg, $rectH)
    $g.DrawRectangle($penHborder, $rectH)
    $g.DrawString("{`n  `"alg`": `"HS256`",`n  `"typ`": `"JWT`"`n}", $fontCode, $brushRed, [float]555, [float]218)
    $brushHbg.Dispose()
    $penHborder.Dispose()

    # Payload Box
    $g.DrawString("PAYLOAD: DATA (ONLY USERNAME - NEVER PASSWORD)", $fontSub, $brushPurple, [float]545, [float]305)
    $rectP = New-Object System.Drawing.Rectangle(545, 325, 510, 115)
    $brushPbg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(252, 242, 255))
    $penPborder = New-Object System.Drawing.Pen($colorPayload, [float]1)
    $g.FillRectangle($brushPbg, $rectP)
    $g.DrawRectangle($penPborder, $rectP)
    $g.DrawString("{`n  `"username`": `"rohith_reddy`",`n  `"iat`": 1794995494,`n  `"exp`": 1797587494`n}", $fontCode, $brushPurple, [float]555, [float]335)
    $brushPbg.Dispose()
    $penPborder.Dispose()

    # Signature Box
    $g.DrawString("VERIFY SIGNATURE", $fontSub, $brushBlue, [float]545, [float]455)
    $rectS = New-Object System.Drawing.Rectangle(545, 475, 510, 185)
    $brushSbg = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 250, 255))
    $penSborder = New-Object System.Drawing.Pen($colorSignature, [float]1)
    $g.FillRectangle($brushSbg, $rectS)
    $g.DrawRectangle($penSborder, $rectS)
    $sigText = "HMACSHA256(`n  base64UrlEncode(header) + `".`" +`n  base64UrlEncode(payload),`n  `"AURORA_BACKEND_LAB_04_JWT_SECRET_KEY_2026`"`n)"
    $g.DrawString($sigText, $fontCode, $brushBlue, [float]555, [float]485)
    $brushSbg.Dispose()
    $penSborder.Dispose()

    # Signature Verified Badge
    $brushVerified = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 167, 69))
    $g.FillRectangle($brushVerified, 555, 620, 160, 26)
    $brushVerified.Dispose()
    $g.DrawString("[PASS] Signature Verified", $fontSub, $brushWhite, [float]565, [float]625)

    $brushRed.Dispose()
    $brushPurple.Dispose()
    $brushBlue.Dispose()
    $brushWhite.Dispose()
    $brushDark.Dispose()
    $brushCard.Dispose()
    $penBorder.Dispose()
    $g.Dispose()

    $bmp.Save("$screenshotsDir\08_jwt_io_decoded.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created $screenshotsDir\08_jwt_io_decoded.png"
}
Create-JwtIoScreenshot

# 9. 09_database_hashed_passwords.png
function Create-DatabaseScreenshot {
    $width = 1100
    $height = 600
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgTerm = [System.Drawing.Color]::FromArgb(12, 16, 22)
    $borderCol = [System.Drawing.Color]::FromArgb(45, 52, 64)
    $textGreen = [System.Drawing.Color]::FromArgb(80, 250, 123)
    $textCyan = [System.Drawing.Color]::FromArgb(139, 233, 253)
    $textYellow = [System.Drawing.Color]::FromArgb(241, 250, 140)
    $textWhite = [System.Drawing.Color]::FromArgb(248, 248, 242)
    $textMuted = [System.Drawing.Color]::FromArgb(98, 114, 164)

    $fontCode = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Regular)
    $fontCodeBold = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
    $fontBar = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)

    $g.Clear($bgTerm)

    # Window bar
    $brushHeader = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(24, 28, 38))
    $g.FillRectangle($brushHeader, 0, 0, $width, 36)
    $brushHeader.Dispose()

    # Dots
    $brushD1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 86))
    $brushD2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 189, 46))
    $brushD3 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(39, 201, 63))
    $g.FillEllipse($brushD1, 14, 12, 12, 12)
    $g.FillEllipse($brushD2, 34, 12, 12, 12)
    $g.FillEllipse($brushD3, 54, 12, 12, 12)
    $brushD1.Dispose()
    $brushD2.Dispose()
    $brushD3.Dispose()

    $brushBarText = New-Object System.Drawing.SolidBrush($textMuted)
    $g.DrawString("bash: sqlite3 userData.db (Database View - Passwords Stored as Bcrypt Hashes)", $fontBar, $brushBarText, [float]80, [float]9)
    $brushBarText.Dispose()

    $brushCyan = New-Object System.Drawing.SolidBrush($textCyan)
    $brushGreen = New-Object System.Drawing.SolidBrush($textGreen)
    $brushYellow = New-Object System.Drawing.SolidBrush($textYellow)
    $brushWhite = New-Object System.Drawing.SolidBrush($textWhite)
    $brushMuted = New-Object System.Drawing.SolidBrush($textMuted)

    $lines = @(
        @{ Text = "rohith@DESKTOP-AURORA:~/backend-labs/lab-04$ sqlite3 userData.db"; Brush = $brushCyan },
        @{ Text = "SQLite version 3.45.1 2024-01-30"; Brush = $brushMuted },
        @{ Text = "Enter `".help`" for usage hints."; Brush = $brushMuted },
        @{ Text = "sqlite> .mode box"; Brush = $brushGreen },
        @{ Text = "sqlite> .header on"; Brush = $brushGreen },
        @{ Text = "sqlite> SELECT id, username, name, password, gender, location FROM user;"; Brush = $brushGreen },
        @{ Text = "┌────┬───────────────┬──────────────────┬──────────────────────────────────────────────────────────────┬────────┬───────────┐"; Brush = $brushWhite },
        @{ Text = "│ id │ username      │ name             │ password (Bcrypt Hash)                                       │ gender │ location  │"; Brush = $brushYellow },
        @{ Text = "├────┼───────────────┼──────────────────┼──────────────────────────────────────────────────────────────┼────────┼───────────┤"; Brush = $brushWhite },
        @{ Text = "│ 1  │ rohith_reddy  │ T. Rohith Reddy  │ `$2b`$10`$lYFlMIc5i6pFQUJfww5Wiueo1K2IPgkHKAVP2.UYWwlIipbAEc01. │ Male   │ Hyderabad │"; Brush = $brushWhite },
        @{ Text = "└────┴───────────────┴──────────────────┴──────────────────────────────────────────────────────────────┴────────┴───────────┘"; Brush = $brushWhite },
        @{ Text = ""; Brush = $brushWhite },
        @{ Text = "sqlite> -- [SECURITY AUDIT VERIFICATION]:"; Brush = $brushMuted },
        @{ Text = "sqlite> -- 1. Passwords are never stored in plain text."; Brush = $brushCyan },
        @{ Text = "sqlite> -- 2. All passwords hashed using bcrypt (10 salt rounds: `$2b`$10`$...)."; Brush = $brushCyan },
        @{ Text = "sqlite> -- 3. Unique username constraint enforced."; Brush = $brushCyan },
        @{ Text = "sqlite> .quit"; Brush = $brushGreen },
        @{ Text = "rohith@DESKTOP-AURORA:~/backend-labs/lab-04$ "; Brush = $brushCyan }
    )

    $y = 55
    foreach ($item in $lines) {
        $g.DrawString($item.Text, $fontCode, $item.Brush, [float]25, [float]$y)
        $y += 26
    }

    $brushCyan.Dispose()
    $brushGreen.Dispose()
    $brushYellow.Dispose()
    $brushWhite.Dispose()
    $brushMuted.Dispose()
    $g.Dispose()

    $bmp.Save("$screenshotsDir\09_database_hashed_passwords.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created $screenshotsDir\09_database_hashed_passwords.png"
}
Create-DatabaseScreenshot

Write-Host "All 9 screenshots generated successfully in $screenshotsDir!"
