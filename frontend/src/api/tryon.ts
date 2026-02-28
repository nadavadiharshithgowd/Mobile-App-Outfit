import axios from 'axios';
import { apiClient } from './client';
import type { TryOnResult, CreateTryOnRequest } from '@/types/tryon.types';
import type { PaginatedResponse } from '@/types/api.types';
import type { UploadPresignedUrlResponse } from '@/types/wardrobe.types';

export const tryonAPI = {
  createTryOn: async (personImage: File, garmentItemId: string) => {
    // Step 1: Get presigned URL for person image
    const { data: presignedData } = await apiClient.post<UploadPresignedUrlResponse>(
      '/upload/presigned-url/',
      {
        file_name: personImage.name,
        content_type: personImage.type,
        upload_type: 'tryon_person',
      }
    );

    // Step 2: Upload directly to S3
    await axios.put(presignedData.presigned_url, personImage, {
      headers: { 'Content-Type': personImage.type },
    });

    // Step 3: Submit try-on with S3 key
    return apiClient.post<TryOnResult>('/tryon/', {
      person_image_s3: presignedData.s3_key,
      garment_item_id: garmentItemId,
    });
  },
  
  getTryOnResult: (id: string) =>
    apiClient.get<TryOnResult>(`/tryon/${id}/`),
  
  getTryOnHistory: (params?: { limit?: number; offset?: number }) =>
    apiClient.get<PaginatedResponse<TryOnResult>>('/tryon/', { params }),
  
  deleteTryOn: (id: string) =>
    apiClient.delete(`/tryon/${id}/`),
};
