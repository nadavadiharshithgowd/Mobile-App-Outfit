import { WardrobeItemCard } from './WardrobeItemCard';
import { LoadingSpinner } from '@/components/common/LoadingSpinner';
import type { WardrobeItem } from '@/types/wardrobe.types';

interface WardrobeGridProps {
  items: WardrobeItem[];
  isLoading?: boolean;
  onView?: (item: WardrobeItem) => void;
  onEdit?: (item: WardrobeItem) => void;
  onDelete?: (id: string) => void;
  onSelect?: (item: WardrobeItem) => void;
  selectedItems?: string[];
}

export const WardrobeGrid = ({
  items,
  isLoading,
  onView,
  onEdit,
  onDelete,
  onSelect,
  selectedItems = [],
}: WardrobeGridProps) => {
  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }
  
  if (items.length === 0) {
    return (
      <div className="text-center py-12">
        <p className="text-lg text-gray-600 mb-2">No items in your wardrobe yet</p>
        <p className="text-sm text-gray-500">Upload your first clothing item to get started</p>
      </div>
    );
  }
  
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4">
      {items.map((item) => (
        <WardrobeItemCard
          key={item.id}
          item={item}
          onView={onView}
          onEdit={onEdit}
          onDelete={onDelete}
          onSelect={onSelect}
          isSelected={selectedItems.includes(item.id)}
        />
      ))}
    </div>
  );
};
