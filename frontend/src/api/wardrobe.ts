import axios from 'axios';
import { apiClient } from './client';
import type {
  WardrobeItem,
  WardrobeItemMetadata,
  WardrobeFilters,
  UploadPresignedUrlResponse,
  ConfirmUploadRequest,
  SimilarItem,
} from '@/types/wardrobe.types';
import type { PaginatedResponse } from '@/types/api.types';

export const wardrobeAPI = {
  getItems: (params?: WardrobeFilters) =>
    apiClient.get<PaginatedResponse<WardrobeItem>>('/wardrobe/', { params }),
  
  getItem: (id: string) =>
    apiClient.get<WardrobeItem>(`/wardrobe/${id}/`),
  
  uploadItem: async (file: File, metadata: WardrobeItemMetadata) => {
    // Step 1: Get presigned URL
    const { data: presignedData } = await apiClient.post<UploadPresignedUrlResponse>(
      '/upload/presigned-url/',
      {
        file_name: file.name,
        content_type: file.type,
        upload_type: 'wardrobe',
      }
    );
    
    // Step 2: Upload to S3
    await axios.put(presignedData.presigned_url, file, {
      headers: { 'Content-Type': file.type },
    });
    
    // Step 3: Confirm upload
    const confirmData: ConfirmUploadRequest = {
      s3_key: presignedData.s3_key,
      upload_type: 'wardrobe',
      ...metadata,
    };
    
    return apiClient.post<WardrobeItem>('/upload/confirm/', confirmData);
  },
  
  updateItem: (id: string, data: Partial<WardrobeItem>) =>
    apiClient.patch<WardrobeItem>(`/wardrobe/${id}/`, data),
  
  deleteItem: (id: string) =>
    apiClient.delete(`/wardrobe/${id}/`),
  
  getSimilar: (id: string, limit?: number) =>
    apiClient.get<SimilarItem[]>(`/wardrobe/${id}/similar/`, { params: { limit } }),
};
