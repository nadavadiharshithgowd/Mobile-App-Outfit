# Outfit Stylist - Frontend

Modern web application for the AI-powered outfit styling and virtual try-on platform.

## Tech Stack

- **Framework**: React 18 + TypeScript
- **Build Tool**: Vite
- **Routing**: React Router v6
- **State Management**: Zustand + React Query (TanStack Query)
- **Styling**: Tailwind CSS
- **Forms**: React Hook Form + Zod
- **HTTP Client**: Axios
- **Icons**: Lucide React

## Getting Started

### Prerequisites

- Node.js 18+ and npm/yarn
- Backend API running on `http://localhost:8000`

### Installation

```bash
# Install dependencies
npm install

# Start development server
npm run dev
```

The app will be available at `http://localhost:3000`

### Build for Production

```bash
# Create production build
npm run build

# Preview production build
npm run preview
```

## Project Structure

```
src/
├── api/              # API client and endpoints
├── components/       # Reusable UI components
│   ├── auth/        # Authentication components
│   ├── common/      # Common UI elements
│   ├── layout/      # Layout components
│   └── wardrobe/    # Wardrobe-specific components
├── hooks/           # Custom React hooks
├── pages/           # Route pages
├── store/           # Zustand stores
├── types/           # TypeScript type definitions
├── utils/           # Utility functions
├── App.tsx          # Main app component
├── main.tsx         # Entry point
└── router.tsx       # Route configuration
```

## Features

### Implemented

- ✅ User authentication (Email/OTP, Google OAuth)
- ✅ Digital wardrobe management
- ✅ Image upload with drag-and-drop
- ✅ Wardrobe filtering and search
- ✅ Responsive design

### Coming Soon

- 🚧 Outfit recommendations
- 🚧 Virtual try-on
- 🚧 Daily outfit suggestions
- 🚧 Manual outfit creation

## Environment Variables

Create a `.env.development` file:

```env
VITE_API_BASE_URL=http://localhost:8000
VITE_WS_BASE_URL=ws://localhost:8000
VITE_GOOGLE_CLIENT_ID=your-google-client-id
```

## API Integration

The frontend communicates with the Django REST Framework + FastAPI backend:

- **REST API**: `http://localhost:8000/api/v1/`
- **WebSocket**: `ws://localhost:8000/ws/`

All API calls include JWT authentication via Axios interceptors.

## Development

### Code Style

- Use TypeScript for type safety
- Follow React best practices
- Use functional components with hooks
- Keep components small and focused

### State Management

- **Server State**: React Query for API data
- **Client State**: Zustand for auth and UI state
- **Form State**: React Hook Form

### Styling

- Tailwind CSS utility classes
- Custom components in `components/common/`
- Responsive design with mobile-first approach

## Deployment

### Vercel (Recommended)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

### Netlify

```bash
# Build
npm run build

# Deploy dist/ folder to Netlify
```

### Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "preview"]
```

## License

MIT
