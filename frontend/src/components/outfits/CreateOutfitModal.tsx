import { useState } from 'react';
import { X, Plus, Check } from 'lucide-react';
import { useWardrobe } from '@/hooks/useWardrobe';
import { WardrobeItemCard } from '@/components/wardrobe/WardrobeItemCard';
import { Button } from '@/components/common/Button';
import { Input } from '@/components/common/Input';
import type { WardrobeItem } from '@/types/wardrobe.types';
import type { CreateOutfitRequest, Occasion } from '@/types/outfit.types';

interface CreateOutfitModalProps {
  isOpen: boolean;
  onClose: () => void;
  onCreate: (data: CreateOutfitRequest) => void;
  isCreating?: boolean;
}

const OCCASIONS: { value: Occasion; label: string }[] = [
  { value: 'casual', label: 'Casual' },
  { value: 'formal', label: 'Formal' },
  { value: 'business', label: 'Business' },
  { value: 'sport', label: 'Sport' },
  { value: 'party', label: 'Party' },
  { value: 'date', label: 'Date' },
  { value: 'work', label: 'Work' },
];

export const CreateOutfitModal = ({
  isOpen,
  onClose,
  onCreate,
  isCreating,
}: CreateOutfitModalProps) => {
  const [name, setName] = useState('');
  const [occasion, setOccasion] = useState<Occasion>('casual');
  const [selectedIds, setSelectedIds] = useState<string[]>([]);

  const { items, isLoading } = useWardrobe();

  if (!isOpen) return null;

  const toggleItem = (item: WardrobeItem) => {
    setSelectedIds((prev) =>
      prev.includes(item.id) ? prev.filter((id) => id !== item.id) : [...prev, item.id]
    );
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || selectedIds.length === 0) return;
    onCreate({ name: name.trim(), occasion, item_ids: selectedIds });
    setName('');
    setOccasion('casual');
    setSelectedIds([]);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm" onClick={onClose} />
      <div className="relative bg-white rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b">
          <h2 className="text-xl font-bold text-gray-900">Create New Outfit</h2>
          <button
            onClick={onClose}
            className="p-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <X className="h-5 w-5 text-gray-500" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col flex-1 overflow-hidden">
          {/* Form fields */}
          <div className="p-6 space-y-4 border-b">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Outfit Name
              </label>
              <Input
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. Summer Brunch Look"
                required
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Occasion
              </label>
              <div className="flex flex-wrap gap-2">
                {OCCASIONS.map((o) => (
                  <button
                    key={o.value}
                    type="button"
                    onClick={() => setOccasion(o.value)}
                    className={`px-4 py-1.5 rounded-full text-sm font-medium border-2 transition-all ${
                      occasion === o.value
                        ? 'border-primary-500 bg-primary-50 text-primary-700'
                        : 'border-gray-200 text-gray-600 hover:border-gray-300'
                    }`}
                  >
                    {o.label}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* Wardrobe items */}
          <div className="flex-1 overflow-y-auto p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-sm font-semibold text-gray-700">
                Select Items ({selectedIds.length} selected)
              </h3>
              {selectedIds.length > 0 && (
                <button
                  type="button"
                  onClick={() => setSelectedIds([])}
                  className="text-xs text-gray-500 hover:text-gray-700"
                >
                  Clear all
                </button>
              )}
            </div>

            {isLoading ? (
              <div className="grid grid-cols-3 sm:grid-cols-4 gap-3">
                {Array.from({ length: 8 }).map((_, i) => (
                  <div key={i} className="aspect-square bg-gray-100 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : items.length === 0 ? (
              <div className="text-center py-12 text-gray-400">
                <p>No wardrobe items yet.</p>
                <p className="text-sm">Add items to your wardrobe first.</p>
              </div>
            ) : (
              <div className="grid grid-cols-3 sm:grid-cols-4 gap-3">
                {items.map((item) => (
                  <div key={item.id} className="relative">
                    <WardrobeItemCard
                      item={item}
                      onSelect={toggleItem}
                      isSelected={selectedIds.includes(item.id)}
                    />
                    {selectedIds.includes(item.id) && (
                      <div className="absolute top-2 left-2 bg-primary-500 rounded-full p-0.5">
                        <Check className="h-3 w-3 text-white" />
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Footer */}
          <div className="p-6 border-t flex items-center justify-between">
            <p className="text-sm text-gray-500">
              {selectedIds.length === 0
                ? 'Select at least 1 item'
                : `${selectedIds.length} item${selectedIds.length > 1 ? 's' : ''} selected`}
            </p>
            <div className="flex gap-3">
              <Button type="button" variant="outline" onClick={onClose}>
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={!name.trim() || selectedIds.length === 0 || isCreating}
                isLoading={isCreating}
              >
                <Plus className="h-4 w-4 mr-2" />
                Create Outfit
              </Button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};
