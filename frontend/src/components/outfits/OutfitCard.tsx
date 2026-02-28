import { Heart, Trash2, Star } from 'lucide-react';
import { cn } from '@/utils/cn';
import type { Outfit, OutfitItem } from '@/types/outfit.types';

interface OutfitCardProps {
  outfit: Outfit;
  onToggleFavorite?: (id: string, current: boolean) => void;
  onDelete?: (id: string) => void;
}

const occasionColors: Record<string, string> = {
  casual: 'bg-blue-100 text-blue-700',
  formal: 'bg-purple-100 text-purple-700',
  business: 'bg-gray-100 text-gray-700',
  sport: 'bg-green-100 text-green-700',
  party: 'bg-pink-100 text-pink-700',
};

const getItemImage = (item: OutfitItem) => {
  const imgs = item.wardrobe_item?.images || [];
  return (
    imgs.find((i) => i.image_type === 'thumbnail')?.url ||
    imgs.find((i) => i.image_type === 'cropped')?.url ||
    imgs.find((i) => i.image_type === 'original')?.url ||
    null
  );
};

export const OutfitCard = ({ outfit, onToggleFavorite, onDelete }: OutfitCardProps) => {
  const score = Math.round((outfit.compatibility_score || 0) * 100);

  const scoreColor =
    score >= 80 ? 'text-green-600' : score >= 60 ? 'text-yellow-600' : 'text-red-500';

  const displayItems = outfit.items?.slice(0, 4) ?? [];
  const extraCount = Math.max(0, (outfit.items?.length ?? 0) - 4);

  return (
    <div className="bg-white rounded-2xl shadow-sm hover:shadow-md transition-all border border-gray-100 overflow-hidden group">
      {/* Score bar */}
      <div className="h-1.5 bg-gray-100">
        <div
          className={cn(
            'h-full rounded-full transition-all',
            score >= 80 ? 'bg-green-400' : score >= 60 ? 'bg-yellow-400' : 'bg-red-400'
          )}
          style={{ width: `${score}%` }}
        />
      </div>

      {/* Item image collage */}
      {displayItems.length > 0 && (
        <div
          className={cn(
            'grid gap-px bg-gray-200',
            displayItems.length === 1 ? 'grid-cols-1' : 'grid-cols-2'
          )}
        >
          {displayItems.map((item, idx) => {
            const url = getItemImage(item);
            const isLast = idx === displayItems.length - 1;
            const showExtra = isLast && extraCount > 0;
            const isLastOfThree = displayItems.length === 3 && idx === 2;

            return (
              <div
                key={idx}
                className={cn(
                  'relative overflow-hidden bg-gray-50',
                  displayItems.length === 1 ? 'aspect-[4/3]' : 'aspect-square',
                  isLastOfThree && 'col-span-2 aspect-[2/1]'
                )}
              >
                {url ? (
                  <img
                    src={url}
                    alt={item.wardrobe_item?.name || item.slot}
                    className="w-full h-full object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center bg-gray-100">
                    <span className="text-xs text-gray-400 capitalize">{item.slot}</span>
                  </div>
                )}
                {showExtra && (
                  <div className="absolute inset-0 bg-black/50 flex items-center justify-center">
                    <span className="text-white font-semibold text-sm">+{extraCount}</span>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      <div className="p-5">
        {/* Header */}
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1 min-w-0">
            <h3 className="font-semibold text-gray-900 truncate text-lg">{outfit.name}</h3>
            <span
              className={cn(
                'inline-block mt-1 px-2.5 py-0.5 text-xs font-medium rounded-full capitalize',
                occasionColors[outfit.occasion] || 'bg-gray-100 text-gray-700'
              )}
            >
              {outfit.occasion}
            </span>
          </div>
          <div className="flex items-center gap-1 ml-2">
            {onToggleFavorite && (
              <button
                onClick={() => onToggleFavorite(outfit.id, outfit.is_favorite)}
                className="p-1.5 rounded-lg hover:bg-gray-50 transition-colors"
              >
                <Heart
                  className={cn(
                    'h-5 w-5 transition-colors',
                    outfit.is_favorite ? 'fill-rose-500 text-rose-500' : 'text-gray-400'
                  )}
                />
              </button>
            )}
            {onDelete && (
              <button
                onClick={() => onDelete(outfit.id)}
                className="p-1.5 rounded-lg hover:bg-red-50 transition-colors opacity-0 group-hover:opacity-100"
              >
                <Trash2 className="h-4 w-4 text-red-400" />
              </button>
            )}
          </div>
        </div>

        {/* Items count */}
        <p className="text-sm text-gray-500 mb-4">
          {outfit.items?.length || 0} piece{outfit.items?.length !== 1 ? 's' : ''}
        </p>

        {/* Scores */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-sm">
            <span className="text-gray-500 flex items-center gap-1">
              <Star className="h-3.5 w-3.5" /> Compatibility
            </span>
            <span className={cn('font-semibold', scoreColor)}>{score}%</span>
          </div>
          {outfit.color_harmony_score != null && (
            <div className="flex items-center justify-between text-sm">
              <span className="text-gray-500">Color Harmony</span>
              <span className="font-medium text-gray-700">
                {Math.round(outfit.color_harmony_score * 100)}%
              </span>
            </div>
          )}
        </div>

        {/* Date */}
        <p className="mt-3 text-xs text-gray-400">
          {new Date(outfit.created_at).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
          })}
        </p>
      </div>
    </div>
  );
};
