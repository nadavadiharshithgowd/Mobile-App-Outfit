# Quick Reference - Outfit Stylist Platform

## 🚀 Quick Start Commands

### Backend (Django + FastAPI)

```bash
cd backend
.\start_with_admin.bat          # Windows - with admin user
# OR
python manage.py runserver      # Manual start
```

**Runs at**: `http://localhost:8000`

### Frontend (React Web App)

```bash
cd frontend
npm install                     # First time only
npm run dev
```

**Runs at**: `http://localhost:3000`

### Flutter Mobile App

```bash
cd flutter_app
flutter pub get                 # First time only
flutter run
```

**Runs on**: Selected device/emulator

---

## 🔑 Default Credentials

### Admin Account
- **Email**: `admin@outfitstylist.com`
- **Password**: `admin123`
- **Access**: `http://localhost:8000/admin/`

### Test User (Create via registration)
- Register at: `http://localhost:3000/register`
- Check backend console for OTP code

---

## 📡 API Endpoints

**Base URL**: `http://localhost:8000/api/v1`

### Authentication
- `POST /auth/email/send-otp/` - Send OTP
- `POST /auth/email/verify-otp/` - Verify OTP
- `POST /auth/google/` - Google OAuth
- `GET /auth/me/` - Current user

### Wardrobe
- `GET /wardrobe/` - List items
- `POST /upload/presigned-url/` - Get upload URL
- `POST /upload/confirm/` - Confirm upload
- `DELETE /wardrobe/{id}/` - Delete item

### Outfits
- `GET /outfits/` - List outfits
- `POST /recommendations/generate/` - Generate recommendations
- `GET /recommendations/daily/` - Daily suggestions

### Try-On
- `POST /tryon/` - Create try-on
- `GET /tryon/{id}/` - Get result
- `WS /ws/tryon/{id}/status/` - Real-time status

---

## 🛠️ Common Commands

### Backend

```bash
# Create admin user
python create_admin.py

# Run migrations
python manage.py migrate

# Create superuser (custom)
python manage.py createsuperuser

# Django shell
python manage.py shell

# Collect static files
python manage.py collectstatic
```

### Frontend

```bash
# Install dependencies
npm install

# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint
```

### Flutter

```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# List devices
flutter devices

# Clean build
flutter clean

# Build APK
flutter build apk --release

# Run tests
flutter test
```

---

## 📁 Project Structure

```
outfit-stylist-platform/
├── backend/              # Django + FastAPI
│   ├── apps/            # Django apps
│   ├── ai/              # AI models
│   ├── config/          # Settings
│   └── manage.py
│
├── frontend/            # React web app
│   ├── src/
│   │   ├── api/        # API client
│   │   ├── components/ # UI components
│   │   ├── pages/      # Route pages
│   │   └── hooks/      # Custom hooks
│   └── package.json
│
└── flutter_app/         # Flutter mobile app
    ├── lib/
    │   ├── features/   # Feature modules
    │   ├── core/       # Core utilities
    │   └── main.dart
    └── pubspec.yaml
```

---

## 🐛 Quick Troubleshooting

### Backend Issues

**Port 8000 in use:**
```bash
python manage.py runserver 8001
```

**Database locked:**
```bash
rm db.sqlite3
python manage.py migrate
```

**Module not found:**
```bash
pip install -r requirements.txt
```

### Frontend Issues

**CORS errors:**
- Ensure backend is running
- Check `VITE_API_BASE_URL` in `.env.development`

**Port 3000 in use:**
- Vite will auto-use next available port

**npm install fails:**
```bash
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

### Flutter Issues

**No devices:**
- Start emulator or simulator
- Connect physical device

**Gradle build failed:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Connection refused:**
- Use `10.0.2.2:8000` for Android emulator
- Use computer IP for physical device

---

## 🔧 Configuration Files

### Backend
- `backend/.env` - Environment variables
- `backend/config/settings/local.py` - Django settings

### Frontend
- `frontend/.env.development` - Dev environment
- `frontend/.env.production` - Prod environment
- `frontend/vite.config.ts` - Vite config

### Flutter
- `flutter_app/lib/core/constants/api_constants.dart` - API URLs

---

## 📚 Documentation Files

- `QUICKSTART.md` - Quick start guide
- `BACKEND_SETUP.md` - Backend detailed setup
- `FRONTEND_SUMMARY.md` - Frontend features
- `FLUTTER_SETUP.md` - Flutter setup guide
- `GMAIL_APP_PASSWORD_GUIDE.md` - Email setup
- `DEBUG_AUTH.md` - Auth debugging
- `ADMIN_SETUP.md` - Admin panel setup

---

## 🌐 URLs

| Service | URL |
|---------|-----|
| Backend API | http://localhost:8000/api/v1/ |
| Admin Panel | http://localhost:8000/admin/ |
| FastAPI Docs | http://localhost:8000/fastapi/docs |
| Web Frontend | http://localhost:3000 |

---

## 💡 Pro Tips

1. **Keep 3 terminals open**: Backend, Frontend, Flutter
2. **Use admin account** for quick testing
3. **Check backend console** for OTP codes
4. **Use browser DevTools** (F12) for debugging
5. **Clear localStorage** if auth issues: `localStorage.clear()`
6. **Hot reload** in Flutter: Press `r` while running

---

## 🎯 Testing Flow

1. **Start backend**: `cd backend && python manage.py runserver`
2. **Start frontend**: `cd frontend && npm run dev`
3. **Open browser**: `http://localhost:3000`
4. **Login**: Use admin account or register new user
5. **Upload item**: Click "Add Item" in wardrobe
6. **Test features**: Explore wardrobe, outfits, try-on

---

## 📞 Need Help?

Check these files for detailed guides:
- Backend issues → `BACKEND_SETUP.md`
- Frontend issues → `frontend/SETUP.md`
- Flutter issues → `FLUTTER_SETUP.md`
- Auth issues → `DEBUG_AUTH.md`
- Email setup → `GMAIL_APP_PASSWORD_GUIDE.md`

---

**Happy coding! 🎉**
