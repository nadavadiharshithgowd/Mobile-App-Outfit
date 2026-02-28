export type TryOnStatus = 'pending' | 'processing' | 'completed' | 'failed';

export interface TryOnResult {
  id: string;
  user_id: string;
  person_image_url: string;
  garment_item_id: string;
  result_image_url?: string;
  status: TryOnStatus;
  error_message?: string;
  processing_started_at?: string;
  processing_completed_at?: string;
  created_at: string;
}

export interface CreateTryOnRequest {
  person_image: File;
  garment_item_id: string;
}

export interface TryOnStatusUpdate {
  status: TryOnStatus;
  progress_percent?: number;
  result_url?: string;
  error_message?: string;
}
