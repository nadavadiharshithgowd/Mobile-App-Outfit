import type { WardrobeItem } from './wardrobe.types';

export type Occasion = 'casual' | 'formal' | 'business' | 'sport' | 'party' | 'date' | 'work';

export interface OutfitItem {
  slot: string;
  wardrobe_item: WardrobeItem;
}

export interface Outfit {
  id: string;
  user_id: string;
  name: string;
  occasion: Occasion;
  season?: string;
  source?: string;
  items: OutfitItem[];
  compatibility_score: number;
  color_harmony_score: number;
  style_rules_score: number;
  is_favorite: boolean;
  created_at: string;
  updated_at?: string;
}

export interface DailyRecommendation {
  id: string;
  user_id: string;
  date: string;
  outfits: {
    outfit_id: string;
    rank: number;
    score: number;
  }[];
  generated_at: string;
}

export interface CreateOutfitRequest {
  name: string;
  occasion: Occasion;
  item_ids: string[];
}

export interface RecommendationParams {
  occasion?: Occasion;
  season?: string;
  num_outfits?: number;
}

export interface OutfitFilters {
  is_favorite?: boolean;
  limit?: number;
  offset?: number;
}
