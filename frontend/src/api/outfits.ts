import { apiClient } from './client';
import type {
  Outfit,
  DailyRecommendation,
  CreateOutfitRequest,
  RecommendationParams,
  OutfitFilters,
} from '@/types/outfit.types';
import type { PaginatedResponse } from '@/types/api.types';

export const outfitsAPI = {
  getOutfits: (params?: OutfitFilters) =>
    apiClient.get<PaginatedResponse<Outfit>>('/outfits/', { params }),
  
  getOutfit: (id: string) =>
    apiClient.get<Outfit>(`/outfits/${id}/`),
  
  createOutfit: (data: CreateOutfitRequest) =>
    apiClient.post<Outfit>('/outfits/', data),
  
  updateOutfit: (id: string, data: Partial<Outfit>) =>
    apiClient.patch<Outfit>(`/outfits/${id}/`, data),
  
  deleteOutfit: (id: string) =>
    apiClient.delete(`/outfits/${id}/`),
  
  getDailyRecommendations: (date?: string) =>
    apiClient.get<DailyRecommendation>('/recommendations/daily/', { params: { date } }),
  
  generateRecommendations: (params: RecommendationParams) =>
    apiClient.post<{ recommendations: Outfit[]; generated_at: string }>(
      '/recommendations/generate/',
      params
    ),
  
  acceptRecommendation: (id: string) =>
    apiClient.post<Outfit>(`/recommendations/${id}/accept/`),
  
  rejectRecommendation: (id: string) =>
    apiClient.post(`/recommendations/${id}/reject/`),
  
  toggleFavorite: (id: string, is_favorite: boolean) =>
    apiClient.patch<Outfit>(`/outfits/${id}/`, { is_favorite }),
};
