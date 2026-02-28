# Gmail App Password Setup Guide

## What is an App Password?

An App Password is a 16-character code that allows less secure apps (like your Django backend) to access your Gmail account. It's more secure than using your regular Gmail password.

## Prerequisites

⚠️ **Important**: You MUST have **2-Step Verification** enabled on your Google account to create App Passwords.

## Step-by-Step Guide

### Step 1: Enable 2-Step Verification (If Not Already Enabled)

1. Go to your Google Account: https://myaccount.google.com/
2. Click on **Security** in the left sidebar
3. Under "How you sign in to Google", click **2-Step Verification**
4. Click **Get Started** and follow the prompts
5. Choose your verification method (phone, authenticator app, etc.)
6. Complete the setup

### Step 2: Generate App Password

1. Go to your Google Account: https://myaccount.google.com/
2. Click on **Security** in the left sidebar
3. Under "How you sign in to Google", click **2-Step Verification**
4. Scroll down to the bottom
5. Click on **App passwords**

   **Alternative direct link**: https://myaccount.google.com/apppasswords

6. You may need to sign in again

7. On the App passwords page:
   - **Select app**: Choose "Mail" or "Other (Custom name)"
   - **Select device**: Choose "Other (Custom name)"
   - Enter a name like "Outfit Stylist Backend"
   - Click **Generate**

8. Google will show you a 16-character password like: `abcd efgh ijkl mnop`

9. **Copy this password immediately** - you won't be able to see it again!

### Step 3: Update Your .env File

1. Open `backend/.env`
2. Update these lines:

```env
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-actual-email@gmail.com
EMAIL_HOST_PASSWORD=abcdefghijklmnop
EMAIL_USE_TLS=True
```

**Important Notes:**
- Remove spaces from the app password: `abcd efgh ijkl mnop` → `abcdefghijklmnop`
- Use your actual Gmail address for `EMAIL_HOST_USER`
- Keep the quotes if your password has special characters

### Step 4: Test Email Sending

1. Restart your Django server (Ctrl+C, then run again)
2. Try registering a new user
3. Check if you receive the OTP email

## Troubleshooting

### Issue 1: "App passwords" option not showing

**Cause**: 2-Step Verification is not enabled

**Solution**:
1. Go to https://myaccount.google.com/security
2. Enable 2-Step Verification first
3. Wait a few minutes
4. Try accessing App passwords again

### Issue 2: "Less secure app access" message

**Cause**: Google has deprecated "Less secure app access" in favor of App Passwords

**Solution**: Use App Passwords (follow the guide above)

### Issue 3: Still not receiving emails

**Possible causes and solutions:**

1. **Wrong credentials**
   - Double-check email and app password in `.env`
   - Make sure there are no spaces in the app password
   - Restart Django server after changing `.env`

2. **Firewall blocking SMTP**
   - Check if port 587 is open
   - Try using port 465 with SSL:
     ```env
     EMAIL_PORT=465
     EMAIL_USE_TLS=False
     EMAIL_USE_SSL=True
     ```

3. **Gmail blocking the app**
   - Check your Gmail inbox for security alerts
   - Allow the app if prompted

4. **Check Django logs**
   - Look at the terminal where Django is running
   - You should see error messages if email fails

### Issue 4: Testing without email

If you can't get email working right now, you can still test the app:

**Option A: Check backend console for OTP**

When you register, the OTP is printed in the Django console:
```
OTP for user@example.com: 123456
```

**Option B: Use the admin account**

Skip registration and use:
- Email: `admin@outfitstylist.com`
- Password: `admin123`

**Option C: Manually verify users**

```bash
python manage.py shell
```

```python
from apps.users.models import User
user = User.objects.get(email='test@example.com')
user.is_verified = True
user.save()
```

## Alternative Email Providers

If Gmail doesn't work, you can use other providers:

### SendGrid (Recommended for Production)

```env
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_HOST_USER=apikey
EMAIL_HOST_PASSWORD=your-sendgrid-api-key
EMAIL_USE_TLS=True
```

### Mailgun

```env
EMAIL_HOST=smtp.mailgun.org
EMAIL_PORT=587
EMAIL_HOST_USER=postmaster@your-domain.mailgun.org
EMAIL_HOST_PASSWORD=your-mailgun-password
EMAIL_USE_TLS=True
```

### Outlook/Hotmail

```env
EMAIL_HOST=smtp-mail.outlook.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@outlook.com
EMAIL_HOST_PASSWORD=your-password
EMAIL_USE_TLS=True
```

## Testing Email Configuration

Create a test script `backend/test_email.py`:

```python
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.local')
django.setup()

from django.core.mail import send_mail
from django.conf import settings

try:
    send_mail(
        subject='Test Email from Outfit Stylist',
        message='If you receive this, email is working!',
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=['your-email@example.com'],
        fail_silently=False,
    )
    print("✓ Email sent successfully!")
    print(f"Check your inbox at: your-email@example.com")
except Exception as e:
    print(f"✗ Email failed: {str(e)}")
```

Run it:
```bash
cd backend
python test_email.py
```

## Security Best Practices

1. **Never commit .env to Git**
   - Already in `.gitignore`
   - Double-check before pushing

2. **Use different passwords for dev/prod**
   - Create separate app passwords for each environment

3. **Rotate passwords regularly**
   - Delete old app passwords from Google Account
   - Generate new ones periodically

4. **Limit app password scope**
   - Only create app passwords when needed
   - Delete unused ones

5. **Monitor usage**
   - Check Google Account activity regularly
   - Look for suspicious sign-ins

## Quick Reference

**Gmail SMTP Settings:**
```env
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
```

**Get App Password:**
https://myaccount.google.com/apppasswords

**Enable 2-Step Verification:**
https://myaccount.google.com/signinoptions/two-step-verification

---

**Still having issues?** Check the Django console for error messages or use the admin account for testing!
