# 🧪 Testing Guide — AI Outfit Stylist

Live App: **https://master.dohxlxk826bym.amplifyapp.com**

---

## ⚠️ Step 1: Trust the SSL Certificate (Required — Do This First!)

The backend runs on an EC2 server with a self-signed SSL certificate.
Browsers block API calls to self-signed certs by default, so you need to manually trust it **once** before using the app.

### Instructions (takes ~10 seconds)

1. Open this URL in the **same browser** you'll use for testing:

   👉 **https://43.205.228.79/api/v1/**

2. You'll see a **"Your connection is not private"** warning page.

3. Click **Advanced** → **Proceed to 43.205.228.79 (unsafe)**

4. You should see a small JSON response like:
   ```json
   {"detail": "Not found."}
   ```
   ✅ That means the certificate is now trusted for this browser session.

5. Close that tab and go to the app:

   👉 **https://master.dohxlxk826bym.amplifyapp.com**

> **Note:** You may need to repeat this step if you clear browser data or switch to a different browser.

---

## 🔐 Step 2: Log In with Test Credentials

On the login page, enter:

| Field    | Value             |
|----------|-------------------|
| Email    | `test@gmail.com`  |
| Password | `test123`         |

Click **Sign In** — you should be redirected to the Wardrobe page. ✅

---

## 📱 What You Can Test

### 👗 Wardrobe
- View your clothing items
- Upload new clothing photos
- Filter by category (Tops, Bottoms, Shoes, etc.)
- Delete items

### 👔 Outfits
- Browse AI-generated outfit combinations
- View outfit details and compatibility scores

### ✨ Recommendations
- Get daily outfit suggestions based on your wardrobe
- Season and color-aware recommendations

### 🪄 Virtual Try-On
- Submit a try-on request with a clothing item
- Track processing status in real time (WebSocket)

### 👤 Profile
- View account info
- Update display name / profile photo

---

## 🐛 Troubleshooting

| Problem | Fix |
|--------|-----|
| Login fails with network error | Repeat Step 1 — trust the SSL cert in your browser |
| "Registration failed" error | Make sure you trusted the cert first (Step 1) |
| App loads but API calls fail | Open https://43.205.228.79/api/v1/ and click "Proceed anyway" |
| Blank/white screen | Hard refresh with `Ctrl + Shift + R` (or `Cmd + Shift + R` on Mac) |
| Cert warning returns next day | Re-do Step 1 — self-signed certs require re-trust after browser data is cleared |

---

## 🏗️ Tech Stack (FYI)

| Layer | Technology |
|-------|-----------|
| Frontend | React + Vite + TypeScript (hosted on AWS Amplify) |
| Backend | Django REST Framework + FastAPI (hosted on AWS EC2) |
| Database | PostgreSQL |
| Cache / Queue | Redis + Celery |
| AI | YOLO + FashionCLIP + IDM-VTON |

---

> 💡 **For permanent SSL fix**: A proper domain + Let's Encrypt certificate will remove the manual trust step entirely. Contact the dev team if you'd like this set up.
