import { useState } from 'react';
import { Trash2, Edit, Eye } from 'lucide-react';
import type { WardrobeItem } from '@/types/wardrobe.types';
import { cn } from '@/utils/cn';

interface WardrobeItemCardProps {
  item: WardrobeItem;
  onView?: (item: WardrobeItem) => void;
  onEdit?: (item: WardrobeItem) => void;
  onDelete?: (id: string) => void;
  onSelect?: (item: WardrobeItem) => void;
  isSelected?: boolean;
}

const categoryLabels: Record<string, string> = {
  top: 'Top',
  bottom: 'Bottom',
  dress: 'Dress',
  shoes: 'Shoes',
  accessory: 'Accessory',
  outerwear: 'Outerwear',
};

function getImageUrl(item: WardrobeItem): string | undefined {
  if (!item.images || item.images.length === 0) return undefined;
  const thumbnail = item.images.find((i) => i.image_type === 'thumbnail');
  if (thumbnail?.url) return thumbnail.url;
  const cropped = item.images.find((i) => i.image_type === 'cropped');
  if (cropped?.url) return cropped.url;
  const original = item.images.find((i) => i.image_type === 'original');
  return original?.url ?? undefined;
}

function isProcessing(item: WardrobeItem): boolean {
  return item.name === 'Processing...' || !item.images.some((i) => i.image_type === 'thumbnail');
}

export const WardrobeItemCard = ({
  item,
  onView,
  onEdit,
  onDelete,
  onSelect,
  isSelected,
}: WardrobeItemCardProps) => {
  const [imageLoaded, setImageLoaded] = useState(false);
  const [imageError, setImageError] = useState(false);

  const imageUrl = getImageUrl(item);
  const processing = isProcessing(item);
  const displayName =
    item.name && item.name !== 'Processing...'
      ? item.name
      : item.brand || categoryLabels[item.category] || item.category;

  return (
    <div
      className={cn(
        'group relative bg-white rounded-lg shadow-sm hover:shadow-md transition-shadow overflow-hidden cursor-pointer',
        isSelected && 'ring-2 ring-primary-500'
      )}
      onClick={() => onSelect?.(item)}
    >
      {/* Image */}
      <div className="relative aspect-square bg-gray-100">
        {!imageLoaded && !imageError && (
          <div className="absolute inset-0 flex items-center justify-center">
            <div className="animate-pulse bg-gray-200 w-full h-full" />
          </div>
        )}

        {imageUrl && !imageError ? (
          <img
            src={imageUrl}
            alt={displayName}
            className={cn(
              'w-full h-full object-cover transition-opacity',
              imageLoaded ? 'opacity-100' : 'opacity-0'
            )}
            onLoad={() => setImageLoaded(true)}
            onError={() => setImageError(true)}
          />
        ) : (
          <div className="absolute inset-0 flex flex-col items-center justify-center text-gray-400">
            <svg
              className="w-10 h-10 mb-1"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={1.5}
                d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
              />
            </svg>
            <span className="text-xs">No image</span>
          </div>
        )}

        {/* Processing Badge */}
        {processing && (
          <div className="absolute top-2 left-2">
            <span className="px-2 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-800">
              Processing
            </span>
          </div>
        )}

        {/* Category Badge */}
        <div className="absolute top-2 right-2">
          <span className="px-2 py-1 text-xs font-medium bg-white bg-opacity-90 rounded-full">
            {categoryLabels[item.category] ?? item.category}
          </span>
        </div>

        {/* Hover Actions */}
        <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-40 transition-all flex items-center justify-center gap-2 opacity-0 group-hover:opacity-100">
          {onView && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                onView(item);
              }}
              className="p-2 bg-white rounded-full hover:bg-gray-100 transition-colors"
            >
              <Eye className="h-5 w-5 text-gray-700" />
            </button>
          )}
          {onEdit && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                onEdit(item);
              }}
              className="p-2 bg-white rounded-full hover:bg-gray-100 transition-colors"
            >
              <Edit className="h-5 w-5 text-gray-700" />
            </button>
          )}
          {onDelete && (
            <button
              onClick={(e) => {
                e.stopPropagation();
                onDelete(item.id);
              }}
              className="p-2 bg-white rounded-full hover:bg-red-50 transition-colors"
            >
              <Trash2 className="h-5 w-5 text-red-600" />
            </button>
          )}
        </div>
      </div>

      {/* Info */}
      <div className="p-3">
        <p className="text-sm font-medium text-gray-900 truncate">{displayName}</p>
        <p className="text-xs text-gray-500 capitalize">{item.season}</p>

        {/* Color swatch */}
        {item.color_hex && (
          <div className="flex gap-1 mt-2">
            <div
              className="w-4 h-4 rounded-full border border-gray-200"
              style={{ backgroundColor: item.color_hex }}
              title={item.primary_color}
            />
          </div>
        )}
      </div>
    </div>
  );
};
