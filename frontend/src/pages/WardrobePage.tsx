import { useState } from 'react';
import { Plus } from 'lucide-react';
import { useWardrobe } from '@/hooks/useWardrobe';
import { Button } from '@/components/common/Button';
import { WardrobeGrid } from '@/components/wardrobe/WardrobeGrid';
import { UploadModal } from '@/components/wardrobe/UploadModal';
import type { WardrobeCategory, Season } from '@/types/wardrobe.types';

export const WardrobePage = () => {
  const [isUploadOpen, setIsUploadOpen] = useState(false);
  const [filters, setFilters] = useState<{ category?: WardrobeCategory; season?: Season }>({});
  
  const { items, isLoading, uploadItem, deleteItem, isUploading } = useWardrobe(filters);
  
  const handleUpload = (file: File, metadata: any) => {
    uploadItem(
      { file, metadata },
      {
        onSuccess: () => {
          setIsUploadOpen(false);
        },
      }
    );
  };
  
  const handleDelete = (id: string) => {
    if (window.confirm('Are you sure you want to delete this item?')) {
      deleteItem(id);
    }
  };
  
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">My Wardrobe</h1>
              <p className="text-gray-600 mt-1">
                {items.length} {items.length === 1 ? 'item' : 'items'}
              </p>
            </div>
            <Button onClick={() => setIsUploadOpen(true)}>
              <Plus className="h-5 w-5 mr-2" />
              Add Item
            </Button>
          </div>
        </div>
      </div>
      
      {/* Filters */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="flex gap-4 mb-6">
          <select
            value={filters.category || ''}
            onChange={(e) => setFilters({ ...filters, category: e.target.value as WardrobeCategory || undefined })}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="">All Categories</option>
            <option value="top">Tops</option>
            <option value="bottom">Bottoms</option>
            <option value="dress">Dresses</option>
            <option value="shoes">Shoes</option>
            <option value="accessory">Accessories</option>
          </select>
          
          <select
            value={filters.season || ''}
            onChange={(e) => setFilters({ ...filters, season: e.target.value as Season || undefined })}
            className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          >
            <option value="">All Seasons</option>
            <option value="spring">Spring</option>
            <option value="summer">Summer</option>
            <option value="fall">Fall</option>
            <option value="winter">Winter</option>
            <option value="all">All Seasons</option>
          </select>
        </div>
        
        {/* Grid */}
        <WardrobeGrid
          items={items}
          isLoading={isLoading}
          onDelete={handleDelete}
        />
      </div>
      
      {/* Upload Modal */}
      <UploadModal
        isOpen={isUploadOpen}
        onClose={() => setIsUploadOpen(false)}
        onUpload={handleUpload}
        isUploading={isUploading}
      />
    </div>
  );
};
