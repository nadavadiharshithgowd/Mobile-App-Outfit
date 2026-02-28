# Frontend Setup Guide

## Quick Start

Follow these steps to get the frontend running:

### 1. Install Dependencies

```bash
cd frontend
npm install
```

### 2. Configure Environment

The `.env.development` file is already created with default values:

```env
VITE_API_BASE_URL=http://localhost:8000
VITE_WS_BASE_URL=ws://localhost:8000
VITE_GOOGLE_CLIENT_ID=702596586580-lt6m2jha8j9da3l52jid1nle43cpp135.apps.googleusercontent.com
```

### 3. Start Backend

Make sure your Django + FastAPI backend is running:

```bash
cd backend
python manage.py runserver
```

### 4. Start Frontend

```bash
cd frontend
npm run dev
```

The app will open at `http://localhost:3000`

## Project Structure

```
frontend/
├── public/              # Static assets
├── src/
│   ├── api/            # API client and endpoints
│   │   ├── client.ts   # Axios instance with JWT interceptors
│   │   ├── auth.ts     # Authentication API
│   │   ├── wardrobe.ts # Wardrobe API
│   │   ├── outfits.ts  # Outfits API
│   │   ├── tryon.ts    # Try-on API
│   │   └── websocket.ts # WebSocket client
│   ├── components/
│   │   ├── auth/       # Login, Register, OTP
│   │   ├── common/     # Button, Input, Modal, Spinner
│   │   ├── layout/     # Header, Layout
│   │   └── wardrobe/   # Upload, Grid, Card
│   ├── hooks/          # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useWardrobe.ts
│   │   ├── useOutfits.ts
│   │   └── useTryOn.ts
│   ├── pages/          # Route pages
│   │   ├── HomePage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   └── WardrobePage.tsx
│   ├── store/          # Zustand stores
│   │   └── authStore.ts
│   ├── types/          # TypeScript types
│   │   ├── auth.types.ts
│   │   ├── wardrobe.types.ts
│   │   ├── outfit.types.ts
│   │   ├── tryon.types.ts
│   │   └── api.types.ts
│   ├── utils/          # Utility functions
│   │   ├── cn.ts       # Class name merger
│   │   └── imageUtils.ts # Image validation
│   ├── App.tsx         # Main app with providers
│   ├── main.tsx        # Entry point
│   ├── router.tsx      # Route configuration
│   └── index.css       # Global styles
├── .env.development    # Development environment variables
├── .env.production     # Production environment variables
├── package.json        # Dependencies
├── tsconfig.json       # TypeScript config
├── vite.config.ts      # Vite config
└── tailwind.config.js  # Tailwind CSS config
```

## Available Scripts

```bash
# Development server with hot reload
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Lint code
npm run lint
```

## Features Implemented

### ✅ Core Infrastructure
- React 18 + TypeScript + Vite setup
- Tailwind CSS styling
- React Router v6 routing
- Axios API client with JWT interceptors
- React Query for server state
- Zustand for client state

### ✅ Authentication
- Email/OTP registration flow
- Login page
- OTP verification modal
- Protected routes
- JWT token management with auto-refresh
- Google OAuth integration (ready)

### ✅ Wardrobe Management
- Image upload with drag-and-drop
- Upload modal with metadata form
- Wardrobe grid view
- Item cards with hover actions
- Category and season filtering
- Processing status indicators
- Color swatches display
- Delete confirmation

### ✅ UI Components
- Reusable Button component
- Input component with validation
- Modal component
- Loading spinner
- Responsive header with navigation
- Layout wrapper

## Next Steps

To complete the application, implement:

1. **Outfit Recommendations**
   - Daily recommendations page
   - Custom recommendation generator
   - Manual outfit composer
   - Outfit gallery

2. **Virtual Try-On**
   - Try-on studio page
   - Person photo upload
   - Garment selector
   - WebSocket status updates
   - Result display
   - Try-on history

3. **Additional Features**
   - Similar items discovery
   - Semantic search
   - Outfit favoriting
   - User profile page
   - Settings page

## API Endpoints Used

### Authentication
- `POST /api/v1/auth/email/send-otp/` - Send OTP
- `POST /api/v1/auth/email/verify-otp/` - Verify OTP
- `POST /api/v1/auth/google/` - Google OAuth
- `GET /api/v1/auth/me/` - Get current user
- `POST /api/v1/auth/token/refresh/` - Refresh JWT

### Wardrobe
- `GET /api/v1/wardrobe/` - List items
- `GET /api/v1/wardrobe/{id}/` - Get item
- `POST /api/v1/upload/presigned-url/` - Get S3 upload URL
- `POST /api/v1/upload/confirm/` - Confirm upload
- `PATCH /api/v1/wardrobe/{id}/` - Update item
- `DELETE /api/v1/wardrobe/{id}/` - Delete item
- `GET /api/v1/wardrobe/{id}/similar/` - Similar items

### Outfits
- `GET /api/v1/outfits/` - List outfits
- `POST /api/v1/outfits/` - Create outfit
- `GET /api/v1/recommendations/daily/` - Daily recommendations
- `POST /api/v1/recommendations/generate/` - Generate recommendations
- `PATCH /api/v1/outfits/{id}/` - Update outfit
- `DELETE /api/v1/outfits/{id}/` - Delete outfit

### Try-On
- `POST /api/v1/tryon/` - Create try-on
- `GET /api/v1/tryon/{id}/` - Get result
- `GET /api/v1/tryon/` - Get history
- `WS /ws/tryon/{id}/status/` - Status updates

## Troubleshooting

### CORS Issues
If you see CORS errors, ensure your Django backend has CORS configured:

```python
# backend/config/settings/base.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
]
```

### API Connection Failed
- Check backend is running on port 8000
- Verify `VITE_API_BASE_URL` in `.env.development`
- Check browser console for errors

### Images Not Loading
- Verify AWS S3 credentials in backend `.env`
- Check S3 bucket CORS configuration
- Ensure presigned URLs are being generated

### Authentication Issues
- Clear localStorage: `localStorage.clear()`
- Check JWT token expiration
- Verify backend JWT settings

## Production Deployment

### Build

```bash
npm run build
```

This creates an optimized build in the `dist/` folder.

### Environment Variables

Update `.env.production` with your production API URL:

```env
VITE_API_BASE_URL=https://api.yourdomain.com
VITE_WS_BASE_URL=wss://api.yourdomain.com
VITE_GOOGLE_CLIENT_ID=your-production-client-id
```

### Deploy to Vercel

```bash
npm i -g vercel
vercel
```

### Deploy to Netlify

1. Build: `npm run build`
2. Upload `dist/` folder to Netlify
3. Configure environment variables in Netlify dashboard

## Support

For issues or questions:
1. Check the backend logs
2. Check browser console for errors
3. Verify API endpoints are accessible
4. Review the tasks.md file for implementation details
