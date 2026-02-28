import { createBrowserRouter } from 'react-router-dom';
import { ProtectedRoute } from '@/components/auth/ProtectedRoute';
import { Layout } from '@/components/layout/Layout';
import { HomePage } from '@/pages/HomePage';
import { LoginPage } from '@/pages/LoginPage';
import { RegisterPage } from '@/pages/RegisterPage';
import { WardrobePage } from '@/pages/WardrobePage';
import { OutfitsPage } from '@/pages/OutfitsPage';
import { RecommendationsPage } from '@/pages/RecommendationsPage';
import { TryOnPage } from '@/pages/TryOnPage';
import { ProfilePage } from '@/pages/ProfilePage';

export const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      { index: true, element: <HomePage /> },
      { path: 'login', element: <LoginPage /> },
      { path: 'register', element: <RegisterPage /> },
      {
        path: 'wardrobe',
        element: <ProtectedRoute><WardrobePage /></ProtectedRoute>,
      },
      {
        path: 'outfits',
        element: <ProtectedRoute><OutfitsPage /></ProtectedRoute>,
      },
      // {
      //   path: 'recommendations',
      //   element: <ProtectedRoute><RecommendationsPage /></ProtectedRoute>,
      // },
      {
        path: 'tryon',
        element: <ProtectedRoute><TryOnPage /></ProtectedRoute>,
      },
      {
        path: 'profile',
        element: <ProtectedRoute><ProfilePage /></ProtectedRoute>,
      },
    ],
  },
]);
