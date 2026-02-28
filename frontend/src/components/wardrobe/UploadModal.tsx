import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Modal } from '@/components/common/Modal';
import { Button } from '@/components/common/Button';
import { ImageUploadZone } from './ImageUploadZone';
import type { WardrobeCategory, Season } from '@/types/wardrobe.types';

interface UploadModalProps {
  isOpen: boolean;
  onClose: () => void;
  onUpload: (file: File, metadata: any) => void;
  isUploading?: boolean;
}

interface UploadFormData {
  name: string;
  category: WardrobeCategory;
  brand: string;
  season: Season;
}

export const UploadModal = ({ isOpen, onClose, onUpload, isUploading }: UploadModalProps) => {
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string>('');
  
  const { register, handleSubmit, reset } = useForm<UploadFormData>({
    defaultValues: {
      season: 'all',
    },
  });
  
  const handleFileSelect = (selectedFile: File, previewUrl: string) => {
    setFile(selectedFile);
    setPreview(previewUrl);
  };
  
  const handleClear = () => {
    setFile(null);
    setPreview('');
  };
  
  const onSubmit = (data: UploadFormData) => {
    if (!file) return;
    
    onUpload(file, {
      name: data.name || undefined,
      category: data.category || undefined,
      brand: data.brand || undefined,
      season: data.season,
    });
    
    // Reset form
    reset();
    handleClear();
  };
  
  const handleClose = () => {
    reset();
    handleClear();
    onClose();
  };
  
  return (
    <Modal isOpen={isOpen} onClose={handleClose} title="Upload Clothing Item" size="lg">
      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        <ImageUploadZone
          onFileSelect={handleFileSelect}
          onClear={handleClear}
          preview={preview}
        />
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Name (Optional)
          </label>
          <input
            type="text"
            {...register('name')}
            placeholder="e.g., Blue Slim Jeans"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Category
            </label>
            <select
              {...register('category')}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="">Auto-detect</option>
              <option value="top">Top</option>
              <option value="bottom">Bottom</option>
              <option value="dress">Dress</option>
              <option value="outerwear">Outerwear</option>
              <option value="shoes">Shoes</option>
              <option value="accessory">Accessory</option>
            </select>
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Season
            </label>
            <select
              {...register('season')}
              className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            >
              <option value="all">All Seasons</option>
              <option value="spring">Spring</option>
              <option value="summer">Summer</option>
              <option value="fall">Fall</option>
              <option value="winter">Winter</option>
            </select>
          </div>
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Brand (Optional)
          </label>
          <input
            type="text"
            {...register('brand')}
            placeholder="e.g., Nike, Zara, H&M"
            className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
          />
        </div>
        
        <div className="flex gap-3">
          <Button
            type="button"
            variant="outline"
            onClick={handleClose}
            className="flex-1"
          >
            Cancel
          </Button>
          <Button
            type="submit"
            className="flex-1"
            disabled={!file}
            isLoading={isUploading}
          >
            Upload
          </Button>
        </div>
      </form>
    </Modal>
  );
};
