export type WardrobeCategory = 'top' | 'bottom' | 'dress' | 'shoes' | 'accessory' | 'outerwear';
export type Season = 'spring' | 'summer' | 'fall' | 'winter' | 'all';

export interface WardrobeImage {
  id: string;
  url: string | null;
  image_type: 'original' | 'cropped' | 'thumbnail';
  width: number | null;
  height: number | null;
}

export interface WardrobeItem {
  id: string;
  category: WardrobeCategory;
  subcategory?: string;
  primary_color?: string;
  secondary_color?: string;
  color_hex?: string;
  brand?: string;
  name?: string;
  season: Season;
  images: WardrobeImage[];
  created_at: string;
  updated_at: string;
}

export interface WardrobeItemMetadata {
  name?: string;
  category?: WardrobeCategory;
  brand?: string;
  season?: Season;
}

export interface UploadPresignedUrlResponse {
  presigned_url: string;
  s3_key: string;
}

export interface ConfirmUploadRequest {
  s3_key: string;
  upload_type: 'wardrobe' | 'profile' | 'tryon_person';
  name?: string;
  category?: WardrobeCategory;
  brand?: string;
  season?: Season;
}

export interface WardrobeFilters {
  category?: WardrobeCategory;
  season?: Season;
  limit?: number;
  offset?: number;
}

export interface SimilarItem extends WardrobeItem {
  similarity_score: number;
}
