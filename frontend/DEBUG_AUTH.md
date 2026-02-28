# Authentication Debugging Guide

## Common 400 Bad Request Issues

### 1. Check Request Payload

The backend expects:
```json
{
  "email": "user@example.com",
  "otp": "123456"
}
```

**Common mistakes:**
- Using `otp_code` instead of `otp`
- OTP not exactly 6 characters
- Email format incorrect

### 2. Check Backend Response

Open browser DevTools (F12) → Network tab → Click on the failed request → Response tab

**Possible error responses:**

**Invalid OTP:**
```json
{
  "detail": "Invalid or expired OTP"
}
```

**User not found:**
```json
{
  "detail": "User not found"
}
```

**Validation error:**
```json
{
  "email": ["This field is required."],
  "otp": ["This field is required."]
}
```

### 3. Test with curl

Test the backend directly:

**Step 1: Send OTP**
```bash
curl -X POST http://localhost:8000/api/v1/auth/email/send-otp/ \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

Expected response:
```json
{
  "message": "OTP sent",
  "expires_in": 300
}
```

**Step 2: Check your email or backend logs for the OTP**

The OTP will be printed in the Django console if email sending fails.

**Step 3: Verify OTP**
```bash
curl -X POST http://localhost:8000/api/v1/auth/email/verify-otp/ \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "otp": "123456"}'
```

Expected response:
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "user": {
    "id": "...",
    "email": "test@example.com",
    ...
  }
}
```

### 4. Check Backend Logs

Look at the Django console where you ran `python manage.py runserver`.

You should see:
```
[timestamp] "POST /api/v1/auth/email/send-otp/ HTTP/1.1" 200
[timestamp] "POST /api/v1/auth/email/verify-otp/ HTTP/1.1" 400
```

If you see 400, there will be error details above it.

### 5. Common Solutions

#### Solution 1: Email Not Configured

If OTP emails aren't being sent, the OTP is printed in the console:

```
OTP for test@example.com: 123456
```

Look for this in your backend terminal.

#### Solution 2: Use Admin Login Instead

For testing, you can use the admin account:

1. Go to `http://localhost:8000/admin/`
2. Login with:
   - Email: `admin@outfitstylist.com`
   - Password: `admin123`
3. Go to Users section
4. Find your test user
5. Check if user exists and is verified

#### Solution 3: Create User Manually

```bash
python manage.py shell
```

```python
from apps.users.models import User

# Create and verify user
user = User.objects.create_user(
    email='test@example.com',
    password='testpass123'
)
user.is_verified = True
user.save()

print(f"User created: {user.email}")
```

Then try logging in with this user.

#### Solution 4: Check CORS

If you see CORS errors in browser console:

1. Check `backend/config/settings/local.py`
2. Ensure CORS is configured:

```python
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]
```

3. Restart backend server

### 6. Frontend Debugging

Add console logs to see what's being sent:

Edit `frontend/src/components/auth/OTPVerification.tsx`:

```typescript
const handleVerify = async () => {
  try {
    setError('');
    
    console.log('Sending OTP verification:', { email, otp }); // ADD THIS
    
    await verifyOTP(
      { email, otp },
      {
        onSuccess: () => {
          console.log('OTP verified successfully'); // ADD THIS
          navigate('/wardrobe');
        },
        onError: (err: any) => {
          console.error('OTP verification error:', err.response?.data); // ADD THIS
          setError(err.response?.data?.detail || 'Invalid OTP');
        },
      }
    );
  } catch (err) {
    console.error('Unexpected error:', err); // ADD THIS
    setError('An unexpected error occurred');
  }
};
```

Check browser console (F12) for these logs.

### 7. Quick Test Flow

**Test the complete flow:**

1. **Start backend:**
   ```bash
   cd backend
   python manage.py runserver
   ```

2. **Start frontend:**
   ```bash
   cd frontend
   npm run dev
   ```

3. **Register:**
   - Go to `http://localhost:3000/register`
   - Enter email: `test@example.com`
   - Enter password: `password123`
   - Click "Create Account"

4. **Check backend console for OTP:**
   ```
   OTP for test@example.com: 123456
   ```

5. **Enter OTP:**
   - Enter the 6-digit code
   - Click "Verify Email"

6. **Check browser console (F12):**
   - Look for any error messages
   - Check Network tab for request/response

### 8. Alternative: Skip OTP for Development

If you want to skip OTP verification for development:

**Option A: Manually verify users**

```bash
python manage.py shell
```

```python
from apps.users.models import User
user = User.objects.get(email='test@example.com')
user.is_verified = True
user.save()
```

**Option B: Use admin account**

Just use the pre-created admin account:
- Email: `admin@outfitstylist.com`
- Password: `admin123`

This account is already verified and ready to use.

### 9. Check API Response Format

The error might be in how the error is parsed. Check the actual response:

1. Open DevTools (F12)
2. Go to Network tab
3. Click on the failed request
4. Check Response tab

If you see:
```json
{
  "detail": "Invalid or expired OTP"
}
```

The frontend should show: "Invalid or expired OTP"

If you see:
```json
{
  "email": ["This field is required."]
}
```

The request payload is malformed.

### 10. Still Not Working?

If none of the above works:

1. **Share the exact error message** from:
   - Browser console (F12 → Console)
   - Network tab (F12 → Network → Click failed request → Response)
   - Backend console (Django terminal)

2. **Check these files:**
   - `backend/apps/users/views.py` - verify_otp_view
   - `backend/apps/users/services.py` - verify_otp function
   - `frontend/src/api/auth.ts` - verifyOTP function

3. **Try the curl commands** above to test backend directly

---

**Most Common Issue:** OTP not being sent because email is not configured. Check backend console for the OTP code and use that!
