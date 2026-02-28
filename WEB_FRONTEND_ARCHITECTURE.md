# Web Frontend Architecture for Outfit Stylist Platform

## Overview

This document outlines the recommended architecture for building a modern web application that integrates with your existing Django REST Framework + FastAPI backend.

## Technology Stack Recommendation

### Primary Stack: React + TypeScript + Vite

**Why React?**
- Large ecosystem and community support
- Excellent for complex UI interactions (drag-drop wardrobe, image uploads)
- Strong TypeScript support for type-safe API integration
- Rich component libraries for fashion/e-commerce UIs

**Alternative Options:**
- **Next.js**: If you need SEO and server-side rendering
- **Vue 3 + Vite**: Lighter alternative with similar capabilities
- **SvelteKit**: Modern, performant option with less boilerplate

### Core Technologies

```json
{
  "framework": "React 18 + TypeScript",
  "build_tool": "Vite",
  "routing": "React Router v6",
  "state_management": "Zustand (lightweight) or Redux Toolkit",
  "api_client": "Axios + React Query (TanStack Query)",
  "ui_framework": "Tailwind CSS + shadcn/ui",
  "forms": "React Hook Form + Zod validation",
  "image_handling": "react-dropzone + react-image-crop",
  "websocket": "Socket.io-client or native WebSocket API",
  "authentication": "JWT with axios interceptors"
}
```

## Project Structure

```
frontend/
├── public/
│   ├── favicon.ico
│   └── assets/
├── src/
│   ├── api/                    # API client and endpoints
│   │   ├── client.ts          # Axios instance with interceptors
│   │   ├── auth.ts            # Authentication endpoints
│   │   ├── wardrobe.ts        # Wardrobe API calls
│   │   ├── outfits.ts         # Outfit recommendations
│   │   ├── tryon.ts           # Virtual try-on
│   │   └── websocket.ts       # WebSocket/SSE connections
│   ├── components/            # Reusable UI components
│   │   ├── common/            # Buttons, inputs, modals
│   │   ├── layout/            # Header, sidebar, footer
│   │   ├── auth/              # Login, register, OTP forms
│   │   ├── wardrobe/          # Wardrobe item cards, upload
│   │   ├── outfits/           # Outfit display, recommendations
│   │   └── tryon/             # Virtual try-on interface
│   ├── pages/                 # Route pages
│   │   ├── HomePage.tsx
│   │   ├── LoginPage.tsx
│   │   ├── RegisterPage.tsx
│   │   ├── WardrobePage.tsx
│   │   ├── OutfitsPage.tsx
│   │   ├── RecommendationsPage.tsx
│   │   └── TryOnPage.tsx
│   ├── hooks/                 # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useWardrobe.ts
│   │   ├── useOutfits.ts
│   │   └── useTryOn.ts
│   ├── store/                 # State management
│   │   ├── authStore.ts
│   │   ├── wardrobeStore.ts
│   │   └── outfitStore.ts
│   ├── types/                 # TypeScript types
│   │   ├── auth.types.ts
│   │   ├── wardrobe.types.ts
│   │   ├── outfit.types.ts
│   │   └── api.types.ts
│   ├── utils/                 # Helper functions
│   │   ├── imageUtils.ts
│   │   ├── colorUtils.ts
│   │   └── validators.ts
│   ├── App.tsx
│   ├── main.tsx
│   └── router.tsx
├── .env.development
├── .env.production
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.js
```

## API Integration Architecture

### 1. Axios Client Setup

```typescript
// src/api/client.ts
import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000';

export const apiClient = axios.create({
  baseURL: `${API_BASE_URL}/api/v1`,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor - Add JWT token
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('access_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor - Handle token refresh
apiClient.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        const refreshToken = localStorage.getItem('refresh_token');
        const response = await axios.post(
          `${API_BASE_URL}/api/v1/auth/token/refresh/`,
          { refresh: refreshToken }
        );
        
        const { access } = response.data;
        localStorage.setItem('access_token', access);
        
        originalRequest.headers.Authorization = `Bearer ${access}`;
        return apiClient(originalRequest);
      } catch (refreshError) {
        localStorage.clear();
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(error);
  }
);
```

### 2. API Endpoints

```typescript
// src/api/auth.ts
export const authAPI = {
  sendOTP: (email: string) => 
    apiClient.post('/auth/email/send-otp/', { email }),
  
  verifyOTP: (email: string, otp: string) =>
    apiClient.post('/auth/email/verify-otp/', { email, otp }),
  
  googleAuth: (credential: string) =>
    apiClient.post('/auth/google/', { credential }),
  
  getMe: () =>
    apiClient.get('/auth/me/'),
};

// src/api/wardrobe.ts
export const wardrobeAPI = {
  getItems: (params?: { category?: string; season?: string }) =>
    apiClient.get('/wardrobe/', { params }),
  
  getItem: (id: string) =>
    apiClient.get(`/wardrobe/${id}/`),
  
  uploadItem: async (file: File, metadata: WardrobeItemMetadata) => {
    // Step 1: Get presigned URL
    const { data } = await apiClient.post('/upload/presigned-url/', {
      filename: file.name,
      content_type: file.type,
    });
    
    // Step 2: Upload to S3
    await axios.put(data.presigned_url, file, {
      headers: { 'Content-Type': file.type },
    });
    
    // Step 3: Confirm upload
    return apiClient.post('/upload/confirm/', {
      s3_key: data.s3_key,
      ...metadata,
    });
  },
  
  updateItem: (id: string, data: Partial<WardrobeItem>) =>
    apiClient.patch(`/wardrobe/${id}/`, data),
  
  deleteItem: (id: string) =>
    apiClient.delete(`/wardrobe/${id}/`),
  
  getSimilar: (id: string, limit?: number) =>
    apiClient.get(`/wardrobe/${id}/similar/`, { params: { limit } }),
};

// src/api/outfits.ts
export const outfitsAPI = {
  getOutfits: (params?: { is_favorite?: boolean }) =>
    apiClient.get('/outfits/', { params }),
  
  createOutfit: (data: CreateOutfitData) =>
    apiClient.post('/outfits/', data),
  
  getDailyRecommendations: (date?: string) =>
    apiClient.get('/recommendations/daily/', { params: { date } }),
  
  generateRecommendations: (params: RecommendationParams) =>
    apiClient.post('/recommendations/generate/', params),
  
  acceptRecommendation: (id: string) =>
    apiClient.post(`/recommendations/${id}/accept/`),
  
  toggleFavorite: (id: string, is_favorite: boolean) =>
    apiClient.patch(`/outfits/${id}/`, { is_favorite }),
};

// src/api/tryon.ts
export const tryonAPI = {
  createTryOn: async (personImage: File, garmentItemId: string) => {
    const formData = new FormData();
    formData.append('person_image', personImage);
    formData.append('garment_item_id', garmentItemId);
    
    return apiClient.post('/tryon/', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
  },
  
  getTryOnResult: (id: string) =>
    apiClient.get(`/tryon/${id}/`),
  
  getTryOnHistory: () =>
    apiClient.get('/tryon/'),
};
```

### 3. WebSocket Integration

```typescript
// src/api/websocket.ts
const WS_BASE_URL = import.meta.env.VITE_WS_BASE_URL || 'ws://localhost:8000';

export class TryOnWebSocket {
  private ws: WebSocket | null = null;
  
  connect(tryonId: string, onMessage: (data: any) => void) {
    const token = localStorage.getItem('access_token');
    this.ws = new WebSocket(
      `${WS_BASE_URL}/ws/tryon/${tryonId}/status/?token=${token}`
    );
    
    this.ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      onMessage(data);
    };
    
    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };
    
    return this.ws;
  }
  
  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
  }
}
```

## Key Features Implementation

### 1. Authentication Flow

**Pages:**
- Login with email/password
- Register with email + OTP verification
- Google OAuth integration
- Protected routes with JWT

**Components:**
- `<LoginForm />` - Email/password login
- `<RegisterForm />` - Email registration
- `<OTPVerification />` - OTP input modal
- `<GoogleLoginButton />` - Google OAuth button
- `<ProtectedRoute />` - Route wrapper for authentication

### 2. Digital Wardrobe

**Features:**
- Grid/list view of wardrobe items
- Drag-and-drop image upload
- Category filters (top, bottom, dress, shoes, accessory)
- Season filters
- Search by description (semantic search)
- Similar items discovery
- Item detail view with metadata

**Components:**
- `<WardrobeGrid />` - Responsive grid of items
- `<WardrobeItemCard />` - Individual item display
- `<ImageUploadZone />` - Drag-drop upload area
- `<ItemFilters />` - Category/season filters
- `<ItemDetailModal />` - Full item view
- `<SimilarItemsPanel />` - Similar items sidebar

### 3. Outfit Recommendations

**Features:**
- Daily outfit recommendations
- Generate custom recommendations (occasion, season)
- View compatibility scores
- Accept/reject recommendations
- Save favorite outfits
- Manual outfit creation

**Components:**
- `<RecommendationCard />` - Outfit display with score
- `<OutfitComposer />` - Drag items to create outfit
- `<CompatibilityScore />` - Visual score indicator
- `<DailyRecommendations />` - Today's suggestions
- `<OutfitGallery />` - Saved outfits grid

### 4. Virtual Try-On

**Features:**
- Upload person photo
- Select garment from wardrobe
- Real-time processing status (WebSocket)
- View try-on results
- Try-on history
- Download results

**Components:**
- `<TryOnStudio />` - Main try-on interface
- `<PersonPhotoUpload />` - Person image upload
- `<GarmentSelector />` - Select from wardrobe
- `<ProcessingStatus />` - Real-time progress
- `<TryOnResult />` - Result image display
- `<TryOnHistory />` - Past try-ons

## State Management Strategy

### Using Zustand (Recommended for simplicity)

```typescript
// src/store/authStore.ts
import create from 'zustand';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  login: (tokens: Tokens) => void;
  logout: () => void;
  setUser: (user: User) => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: !!localStorage.getItem('access_token'),
  
  login: (tokens) => {
    localStorage.setItem('access_token', tokens.access);
    localStorage.setItem('refresh_token', tokens.refresh);
    set({ isAuthenticated: true });
  },
  
  logout: () => {
    localStorage.clear();
    set({ user: null, isAuthenticated: false });
  },
  
  setUser: (user) => set({ user }),
}));
```

### Using React Query for Server State

```typescript
// src/hooks/useWardrobe.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { wardrobeAPI } from '@/api/wardrobe';

export const useWardrobe = () => {
  const queryClient = useQueryClient();
  
  const { data: items, isLoading } = useQuery({
    queryKey: ['wardrobe'],
    queryFn: () => wardrobeAPI.getItems(),
  });
  
  const uploadMutation = useMutation({
    mutationFn: ({ file, metadata }: UploadParams) =>
      wardrobeAPI.uploadItem(file, metadata),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['wardrobe'] });
    },
  });
  
  const deleteMutation = useMutation({
    mutationFn: (id: string) => wardrobeAPI.deleteItem(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['wardrobe'] });
    },
  });
  
  return {
    items: items?.data || [],
    isLoading,
    uploadItem: uploadMutation.mutate,
    deleteItem: deleteMutation.mutate,
  };
};
```

## UI/UX Recommendations

### Design System

**Color Palette:**
- Primary: Fashion-forward colors (e.g., #E91E63 pink, #9C27B0 purple)
- Secondary: Neutral grays for backgrounds
- Accent: Gold/bronze for premium features
- Success/Error: Standard green/red

**Typography:**
- Headings: Playfair Display or Montserrat
- Body: Inter or Roboto
- Monospace: JetBrains Mono (for technical info)

### Key UI Components

1. **Wardrobe Grid**: Masonry layout with hover effects
2. **Outfit Cards**: Large images with overlay scores
3. **Upload Zone**: Prominent drag-drop area with preview
4. **Processing Indicators**: Animated progress bars
5. **Image Galleries**: Lightbox for full-screen viewing

## Performance Optimizations

1. **Image Optimization**:
   - Use thumbnail URLs for grid views
   - Lazy load images with Intersection Observer
   - Progressive image loading

2. **Code Splitting**:
   - Route-based code splitting
   - Lazy load heavy components (try-on studio)

3. **Caching**:
   - React Query caching for API responses
   - Service Worker for offline support

4. **Virtual Scrolling**:
   - Use `react-window` for large wardrobe lists

## Deployment Architecture

```
┌─────────────────┐
│   Cloudflare    │  CDN + DDoS protection
│   or Vercel    │
└────────┬────────┘
         │
┌────────▼────────┐
│  React SPA      │  Static hosting
│  (Vite build)   │
└────────┬────────┘
         │
         │ API Calls
         │
┌────────▼────────┐
│  Django +       │  Backend server
│  FastAPI        │  (AWS EC2 / Railway)
└────────┬────────┘
         │
┌────────▼────────┐
│  PostgreSQL     │  Database
│  Redis          │  Cache
│  S3             │  Storage
└─────────────────┘
```

## Environment Variables

```env
# .env.development
VITE_API_BASE_URL=http://localhost:8000
VITE_WS_BASE_URL=ws://localhost:8000
VITE_GOOGLE_CLIENT_ID=your-google-client-id

# .env.production
VITE_API_BASE_URL=https://api.outfitstylist.com
VITE_WS_BASE_URL=wss://api.outfitstylist.com
VITE_GOOGLE_CLIENT_ID=your-google-client-id
```

## Next Steps

1. **Setup Project**: Initialize Vite + React + TypeScript
2. **Install Dependencies**: Core libraries and UI framework
3. **Configure API Client**: Axios with interceptors
4. **Build Authentication**: Login, register, OTP flow
5. **Implement Wardrobe**: Upload, display, manage items
6. **Add Recommendations**: Daily suggestions, custom generation
7. **Integrate Try-On**: WebSocket status, result display
8. **Polish UI/UX**: Animations, responsive design
9. **Testing**: Unit tests, E2E tests
10. **Deploy**: Build and deploy to hosting platform

## Estimated Timeline

- **Week 1**: Project setup, authentication, basic layout
- **Week 2**: Wardrobe management, image upload
- **Week 3**: Outfit recommendations, manual creation
- **Week 4**: Virtual try-on, WebSocket integration
- **Week 5**: UI polish, responsive design
- **Week 6**: Testing, bug fixes, deployment

---

**Ready to start building?** I can generate the complete starter code for any of these components!
