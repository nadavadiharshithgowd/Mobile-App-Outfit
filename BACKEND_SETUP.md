# Backend Setup Guide

## Quick Start (Windows)

The easiest way to run the backend on Windows:

```bash
cd backend
start.bat
```

This script will:
1. Install all dependencies
2. Run database migrations
3. Start the Django development server on `http://localhost:8000`

## Manual Setup (All Platforms)

### Prerequisites

- Python 3.10 or higher
- pip (Python package manager)
- Virtual environment (recommended)

### Step-by-Step Setup

#### 1. Create Virtual Environment (Recommended)

**Windows:**
```bash
cd backend
python -m venv venv
venv\Scripts\activate
```

**macOS/Linux:**
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
```

#### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

This installs:
- Django 5.1.4 + Django REST Framework
- FastAPI + Uvicorn (for WebSocket support)
- AWS SDK (boto3) for S3 storage
- Pillow + NumPy for image processing
- Google Auth for OAuth
- JWT authentication
- CORS headers
- And more...

#### 3. Configure Environment Variables

The `.env` file is already configured in `backend/.env`. Verify these settings:

```env
# Django
SECRET_KEY=your-django-secret-key-here
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2
DJANGO_SETTINGS_MODULE=config.settings.local

# AWS S3 (for image storage)
AWS_ACCESS_KEY_ID=your-aws-access-key-id
AWS_SECRET_ACCESS_KEY=your-aws-secret-access-key
AWS_STORAGE_BUCKET_NAME=your-s3-bucket-name
AWS_S3_REGION_NAME=ap-south-1

# Google OAuth
GOOGLE_CLIENT_ID=your-google-client-id.apps.googleusercontent.com

# Email (for OTP)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-gmail-app-password
EMAIL_USE_TLS=True

# Hugging Face (for AI models)
HF_TOKEN=your-huggingface-token
```

**⚠️ Security Note**: These are development credentials. For production, use your own credentials and keep them secure!

#### 4. Run Database Migrations

```bash
python manage.py migrate
```

This creates the SQLite database and all necessary tables.

#### 5. Create Superuser (Optional)

To access the Django admin panel:

```bash
python manage.py createsuperuser
```

Follow the prompts to create an admin account.

#### 6. Start the Development Server

```bash
python manage.py runserver
```

Or to make it accessible from other devices on your network:

```bash
python manage.py runserver 0.0.0.0:8000
```

The server will start at:
- **API**: `http://localhost:8000/api/v1/`
- **Admin Panel**: `http://localhost:8000/admin/`
- **API Docs**: `http://localhost:8000/fastapi/docs` (FastAPI endpoints)

## Running with Celery (For Background Tasks)

The platform uses Celery for async tasks like image processing and AI model inference.

### 1. Install Redis (Required for Celery)

**Windows:**
- Download Redis from: https://github.com/microsoftarchive/redis/releases
- Or use Docker: `docker run -d -p 6379:6379 redis`

**macOS:**
```bash
brew install redis
brew services start redis
```

**Linux:**
```bash
sudo apt-get install redis-server
sudo systemctl start redis
```

### 2. Start Celery Worker

In a new terminal (with virtual environment activated):

```bash
cd backend
celery -A config.celery_app worker --loglevel=info
```

**Windows Note**: Celery 4.x+ doesn't officially support Windows. Use one of these options:
- Use WSL (Windows Subsystem for Linux)
- Use Docker
- Use `eventlet` pool: `celery -A config.celery_app worker --pool=eventlet --loglevel=info`

### 3. Start Celery Beat (Optional - for scheduled tasks)

```bash
celery -A config.celery_app beat --loglevel=info
```

## Project Structure

```
backend/
├── ai/                      # AI models (YOLO, CLIP, VTON)
│   ├── clip/               # CLIP embeddings
│   ├── recommendation/     # Outfit recommendation engine
│   ├── vton/              # Virtual try-on pipeline
│   └── yolo/              # Object detection
├── apps/                   # Django apps
│   ├── users/             # User authentication
│   ├── wardrobe/          # Wardrobe management
│   ├── outfits/           # Outfit recommendations
│   └── tryon/             # Virtual try-on
├── common/                # Shared utilities
├── config/                # Django configuration
│   ├── settings/          # Settings by environment
│   ├── urls.py           # URL routing
│   └── celery_app.py     # Celery configuration
├── fastapi_app/          # FastAPI for WebSocket
├── staticfiles/          # Static files
├── manage.py             # Django management
├── requirements.txt      # Python dependencies
├── start.bat            # Windows startup script
└── .env                 # Environment variables
```

## API Endpoints

### Authentication
- `POST /api/v1/auth/email/send-otp/` - Send OTP to email
- `POST /api/v1/auth/email/verify-otp/` - Verify OTP and login
- `POST /api/v1/auth/google/` - Google OAuth login
- `GET /api/v1/auth/me/` - Get current user
- `POST /api/v1/auth/token/refresh/` - Refresh JWT token

### Wardrobe
- `GET /api/v1/wardrobe/` - List wardrobe items
- `POST /api/v1/upload/presigned-url/` - Get S3 upload URL
- `POST /api/v1/upload/confirm/` - Confirm upload and process
- `GET /api/v1/wardrobe/{id}/` - Get item details
- `PATCH /api/v1/wardrobe/{id}/` - Update item
- `DELETE /api/v1/wardrobe/{id}/` - Delete item
- `GET /api/v1/wardrobe/{id}/similar/` - Find similar items

### Outfits
- `GET /api/v1/outfits/` - List outfits
- `POST /api/v1/outfits/` - Create outfit
- `GET /api/v1/recommendations/daily/` - Get daily recommendations
- `POST /api/v1/recommendations/generate/` - Generate custom recommendations
- `POST /api/v1/recommendations/{id}/accept/` - Accept recommendation
- `PATCH /api/v1/outfits/{id}/` - Update outfit (favorite, etc.)
- `DELETE /api/v1/outfits/{id}/` - Delete outfit

### Virtual Try-On
- `POST /api/v1/tryon/` - Create try-on request
- `GET /api/v1/tryon/{id}/` - Get try-on result
- `GET /api/v1/tryon/` - Get try-on history
- `WS /ws/tryon/{id}/status/` - WebSocket for real-time status

## Testing the API

### Using curl

**Send OTP:**
```bash
curl -X POST http://localhost:8000/api/v1/auth/email/send-otp/ \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

**Verify OTP:**
```bash
curl -X POST http://localhost:8000/api/v1/auth/email/verify-otp/ \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "otp": "123456"}'
```

**List Wardrobe (with JWT):**
```bash
curl -X GET http://localhost:8000/api/v1/wardrobe/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Using Django Admin

1. Go to `http://localhost:8000/admin/`
2. Login with superuser credentials
3. Browse and manage data directly

### Using FastAPI Docs

1. Go to `http://localhost:8000/fastapi/docs`
2. Interactive API documentation for FastAPI endpoints
3. Test WebSocket connections

## Troubleshooting

### Port Already in Use

If port 8000 is already in use:

```bash
# Use a different port
python manage.py runserver 8001

# Or find and kill the process using port 8000
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# macOS/Linux:
lsof -ti:8000 | xargs kill -9
```

### Database Locked Error

If you get "database is locked" error:

```bash
# Delete the database and recreate
rm db.sqlite3
python manage.py migrate
```

### Import Errors

If you get module import errors:

```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### AWS S3 Errors

If image uploads fail:

1. Verify AWS credentials in `.env`
2. Check S3 bucket exists and is accessible
3. Verify bucket CORS configuration allows your domain
4. Check IAM permissions for the access key

### Email OTP Not Sending

If OTP emails aren't being sent:

1. Verify email credentials in `.env`
2. Check if Gmail "Less secure app access" is enabled
3. Or use Gmail App Password instead of regular password
4. Check spam folder

### Celery Not Working

If background tasks aren't processing:

1. Ensure Redis is running: `redis-cli ping` (should return "PONG")
2. Check Celery worker is running
3. Check Celery logs for errors
4. On Windows, use `--pool=eventlet`

## Development Tips

### Hot Reload

Django automatically reloads when you change Python files. No need to restart the server.

### Database Shell

Access Django ORM shell:

```bash
python manage.py shell
```

### Create Test Data

```python
python manage.py shell

from apps.users.models import User
user = User.objects.create_user(
    email='test@example.com',
    password='testpass123'
)
```

### View Logs

Django logs appear in the terminal where you ran `runserver`.

For more detailed logs, check:
- `config/settings/local.py` - Logging configuration
- Celery worker terminal - Background task logs

## Production Deployment

For production deployment:

1. Set `DEBUG=False` in `.env`
2. Use PostgreSQL instead of SQLite
3. Use proper secret key (not the one in `.env`)
4. Set up proper CORS origins
5. Use Gunicorn/uWSGI instead of `runserver`
6. Set up Nginx as reverse proxy
7. Use Redis for caching and Celery
8. Set up proper logging
9. Use environment-specific settings

Example production command:

```bash
gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 4
```

## Next Steps

1. ✅ Start the backend server
2. ✅ Test API endpoints
3. ✅ Start the frontend (see `frontend/SETUP.md`)
4. ✅ Test full integration
5. 🚀 Build amazing features!

## Support

If you encounter issues:

1. Check this guide's troubleshooting section
2. Review Django logs in terminal
3. Check `.env` configuration
4. Verify all services are running (Django, Redis, Celery)
5. Test API endpoints individually

---

**Backend is ready!** Start the server and begin building your AI-powered outfit stylist platform! 🎉
