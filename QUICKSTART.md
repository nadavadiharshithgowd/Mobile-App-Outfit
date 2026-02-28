# 🚀 Quick Start Guide - Outfit Stylist Platform

Get your AI-powered outfit stylist platform running in minutes!

## Prerequisites

- **Python 3.10+** (for backend)
- **Node.js 18+** (for frontend)
- **Git** (to clone/manage code)

## 🎯 Super Quick Start (Windows)

### 1. Start Backend (Terminal 1)

```bash
cd backend
start.bat
```

Wait for the server to start at `http://localhost:8000`

### 2. Start Frontend (Terminal 2)

```bash
cd frontend
npm install
npm run dev
```

Frontend will open at `http://localhost:3000`

### 3. Open Your Browser

Go to `http://localhost:3000` and start using the app! 🎉

---

## 📋 Detailed Setup

### Backend Setup

#### Option A: Using start.bat (Windows - Easiest)

```bash
cd backend
start.bat
```

This automatically:
- Installs dependencies
- Runs migrations
- Starts the server

#### Option B: Manual Setup (All Platforms)

```bash
# Navigate to backend
cd backend

# Create virtual environment (recommended)
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Start server
python manage.py runserver
```

**Backend runs at**: `http://localhost:8000`

### Frontend Setup

```bash
# Navigate to frontend
cd frontend

# Install dependencies (first time only)
npm install

# Start development server
npm run dev
```

**Frontend runs at**: `http://localhost:3000`

---

## ✅ Verify Everything Works

### 1. Check Backend

Open `http://localhost:8000/admin/` - You should see Django admin login

### 2. Check Frontend

Open `http://localhost:3000` - You should see the home page

### 3. Test Registration

1. Click "Get Started" on home page
2. Enter email and password
3. Check your email for OTP (if email is configured)
4. Verify and login

### 4. Test Wardrobe

1. After login, you'll be on the Wardrobe page
2. Click "Add Item" button
3. Drag and drop a clothing image
4. Fill in details and upload
5. Item will appear in your wardrobe grid

---

## 🔧 Configuration

### Backend Configuration

File: `backend/.env`

Key settings:
```env
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1

# AWS S3 (for image storage)
AWS_ACCESS_KEY_ID=your-key
AWS_SECRET_ACCESS_KEY=your-secret
AWS_STORAGE_BUCKET_NAME=your-bucket

# Email (for OTP)
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
```

### Frontend Configuration

File: `frontend/.env.development`

```env
VITE_API_BASE_URL=http://localhost:8000
VITE_WS_BASE_URL=ws://localhost:8000
VITE_GOOGLE_CLIENT_ID=your-google-client-id
```

---

## 📁 Project Structure

```
outfit-stylist-platform/
├── backend/              # Django + FastAPI backend
│   ├── apps/            # Django apps (users, wardrobe, outfits, tryon)
│   ├── ai/              # AI models (YOLO, CLIP, VTON)
│   ├── config/          # Django settings
│   ├── manage.py        # Django management
│   ├── requirements.txt # Python dependencies
│   └── start.bat        # Windows startup script
│
├── frontend/            # React + TypeScript frontend
│   ├── src/
│   │   ├── api/        # API client
│   │   ├── components/ # React components
│   │   ├── pages/      # Route pages
│   │   ├── hooks/      # Custom hooks
│   │   └── types/      # TypeScript types
│   ├── package.json    # Node dependencies
│   └── vite.config.ts  # Vite configuration
│
└── docs/               # Documentation
    ├── BACKEND_SETUP.md
    ├── FRONTEND_SUMMARY.md
    └── QUICKSTART.md (this file)
```

---

## 🎨 Features Available

### ✅ Currently Working

- **Authentication**
  - Email/OTP registration
  - Login with JWT tokens
  - Google OAuth (configured)
  - Protected routes

- **Digital Wardrobe**
  - Upload clothing images
  - Drag-and-drop interface
  - Category and season filtering
  - View, edit, delete items
  - Color extraction
  - AI categorization

- **UI/UX**
  - Responsive design
  - Modern, clean interface
  - Loading states
  - Error handling

### 🚧 Coming Soon

- **Outfit Recommendations**
  - Daily outfit suggestions
  - Custom recommendations
  - Manual outfit creation
  - Compatibility scoring

- **Virtual Try-On**
  - Upload person photo
  - Select garment
  - Real-time processing
  - View results

---

## 🐛 Common Issues & Solutions

### Backend Issues

**Port 8000 already in use:**
```bash
# Use different port
python manage.py runserver 8001

# Update frontend .env to match:
VITE_API_BASE_URL=http://localhost:8001
```

**Module not found errors:**
```bash
pip install -r requirements.txt --force-reinstall
```

**Database locked:**
```bash
rm db.sqlite3
python manage.py migrate
```

### Frontend Issues

**CORS errors:**
- Ensure backend is running
- Check `VITE_API_BASE_URL` in `.env.development`
- Verify Django CORS settings

**npm install fails:**
```bash
# Clear cache and retry
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

**Port 3000 already in use:**
```bash
# Vite will automatically use next available port
# Or specify port:
npm run dev -- --port 3001
```

---

## 📚 Documentation

- **Backend Setup**: See `BACKEND_SETUP.md`
- **Frontend Setup**: See `frontend/SETUP.md`
- **Frontend Features**: See `FRONTEND_SUMMARY.md`
- **Architecture**: See `WEB_FRONTEND_ARCHITECTURE.md`
- **Tasks**: See `.kiro/specs/outfit-stylist-platform/tasks.md`

---

## 🔄 Development Workflow

### Making Changes

1. **Backend Changes**
   - Edit Python files in `backend/`
   - Django auto-reloads (no restart needed)
   - Check terminal for errors

2. **Frontend Changes**
   - Edit files in `frontend/src/`
   - Vite hot-reloads instantly
   - Check browser console for errors

### Testing

**Backend:**
```bash
# Django shell
python manage.py shell

# Run tests (when added)
python manage.py test
```

**Frontend:**
```bash
# Type checking
npm run build

# Linting
npm run lint
```

### Building for Production

**Backend:**
```bash
# Collect static files
python manage.py collectstatic

# Use production settings
export DJANGO_SETTINGS_MODULE=config.settings.production
```

**Frontend:**
```bash
# Create production build
npm run build

# Preview production build
npm run preview
```

---

## 🚀 Deployment

### Backend Deployment Options

- **Railway**: Easy Python deployment
- **Heroku**: Classic PaaS
- **AWS EC2**: Full control
- **DigitalOcean**: Simple VPS
- **Google Cloud Run**: Serverless

### Frontend Deployment Options

- **Vercel**: Recommended (automatic)
- **Netlify**: Easy static hosting
- **Cloudflare Pages**: Fast CDN
- **AWS S3 + CloudFront**: Scalable

---

## 💡 Tips

1. **Keep both terminals open** - One for backend, one for frontend
2. **Check browser console** - Shows frontend errors
3. **Check terminal logs** - Shows backend errors
4. **Use Django admin** - `http://localhost:8000/admin/` for data management
5. **Clear localStorage** - If auth issues: `localStorage.clear()` in browser console

---

## 🎓 Learning Resources

- **Django**: https://docs.djangoproject.com/
- **Django REST Framework**: https://www.django-rest-framework.org/
- **React**: https://react.dev/
- **TypeScript**: https://www.typescriptlang.org/
- **Tailwind CSS**: https://tailwindcss.com/
- **Vite**: https://vitejs.dev/

---

## 🤝 Need Help?

1. Check the troubleshooting sections above
2. Review the detailed setup guides
3. Check browser console and terminal logs
4. Verify all services are running
5. Ensure environment variables are set correctly

---

## ✨ You're All Set!

Your AI-powered outfit stylist platform is ready to go! 

**Next steps:**
1. Register a new account
2. Upload some clothing items
3. Explore the wardrobe features
4. Start building outfit recommendations
5. Add virtual try-on functionality

Happy coding! 🎉👔✨
