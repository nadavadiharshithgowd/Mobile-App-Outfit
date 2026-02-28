import { useState } from 'react';
import { Plus, Heart, LayoutGrid, List } from 'lucide-react';
import { useOutfits } from '@/hooks/useOutfits';
import { OutfitCard } from '@/components/outfits/OutfitCard';
import { CreateOutfitModal } from '@/components/outfits/CreateOutfitModal';
import { Button } from '@/components/common/Button';
import { LoadingSpinner } from '@/components/common/LoadingSpinner';
import { useToast } from '@/components/common/Toast';
import { cn } from '@/utils/cn';

export const OutfitsPage = () => {
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [showFavOnly, setShowFavOnly] = useState(false);

  const { outfits, total, isLoading, createOutfit, deleteOutfit, toggleFavorite, isCreating } =
    useOutfits(showFavOnly ? { is_favorite: true } : undefined);

  const { success, error } = useToast();

  const handleCreate = (data: any) => {
    createOutfit(data, {
      onSuccess: () => {
        success('Outfit created!');
        setIsCreateOpen(false);
      },
      onError: () => error('Failed to create outfit.'),
    });
  };

  const handleDelete = (id: string) => {
    if (!window.confirm('Delete this outfit?')) return;
    deleteOutfit(id, {
      onSuccess: () => success('Outfit deleted.'),
      onError: () => error('Failed to delete outfit.'),
    });
  };

  const handleToggleFav = (id: string, current: boolean) => {
    toggleFavorite(
      { id, is_favorite: !current },
      {
        onSuccess: () => success(current ? 'Removed from favourites.' : 'Added to favourites!'),
        onError: () => error('Failed to update favourite.'),
      }
    );
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Page header */}
      <div className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">My Outfits</h1>
              <p className="text-gray-500 mt-1">
                {total} outfit{total !== 1 ? 's' : ''}
                {showFavOnly && ' · Favourites only'}
              </p>
            </div>
            <div className="flex items-center gap-3">
              <button
                onClick={() => setShowFavOnly((v) => !v)}
                className={cn(
                  'flex items-center gap-2 px-4 py-2 rounded-xl border-2 text-sm font-medium transition-all',
                  showFavOnly
                    ? 'border-rose-300 bg-rose-50 text-rose-600'
                    : 'border-gray-200 text-gray-600 hover:border-rose-200'
                )}
              >
                <Heart className={cn('h-4 w-4', showFavOnly && 'fill-rose-500 text-rose-500')} />
                Favourites
              </button>
              <Button onClick={() => setIsCreateOpen(true)}>
                <Plus className="h-5 w-5 mr-2" />
                New Outfit
              </Button>
            </div>
          </div>
        </div>
      </div>

      {/* Body */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {isLoading ? (
          <div className="flex items-center justify-center py-24">
            <LoadingSpinner size="lg" />
          </div>
        ) : outfits.length === 0 ? (
          <div className="text-center py-24">
            <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <LayoutGrid className="h-10 w-10 text-gray-300" />
            </div>
            <h3 className="text-lg font-semibold text-gray-700 mb-1">
              {showFavOnly ? 'No favourite outfits yet' : 'No outfits yet'}
            </h3>
            <p className="text-gray-400 mb-6">
              {showFavOnly
                ? 'Heart an outfit to save it here.'
                : 'Create your first outfit from your wardrobe.'}
            </p>
            {!showFavOnly && (
              <Button onClick={() => setIsCreateOpen(true)}>
                <Plus className="h-5 w-5 mr-2" />
                Create Outfit
              </Button>
            )}
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
            {outfits.map((outfit) => (
              <OutfitCard
                key={outfit.id}
                outfit={outfit}
                onToggleFavorite={handleToggleFav}
                onDelete={handleDelete}
              />
            ))}
          </div>
        )}
      </div>

      <CreateOutfitModal
        isOpen={isCreateOpen}
        onClose={() => setIsCreateOpen(false)}
        onCreate={handleCreate}
        isCreating={isCreating}
      />
    </div>
  );
};
