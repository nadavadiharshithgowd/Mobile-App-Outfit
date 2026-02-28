import { useCallback, useState } from 'react';
import { useDropzone } from 'react-dropzone';
import { Upload, X } from 'lucide-react';
import { validateImageFile, createImagePreview } from '@/utils/imageUtils';
import { Button } from '@/components/common/Button';
import { cn } from '@/utils/cn';

interface ImageUploadZoneProps {
  onFileSelect: (file: File, preview: string) => void;
  onClear?: () => void;
  preview?: string;
}

export const ImageUploadZone = ({ onFileSelect, onClear, preview }: ImageUploadZoneProps) => {
  const [error, setError] = useState('');
  
  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    setError('');
    
    if (acceptedFiles.length === 0) return;
    
    const file = acceptedFiles[0];
    const validation = validateImageFile(file);
    
    if (!validation.valid) {
      setError(validation.error || 'Invalid file');
      return;
    }
    
    try {
      const previewUrl = await createImagePreview(file);
      onFileSelect(file, previewUrl);
    } catch (err) {
      setError('Failed to load image preview');
    }
  }, [onFileSelect]);
  
  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'image/*': ['.jpeg', '.jpg', '.png', '.webp'],
    },
    maxFiles: 1,
    multiple: false,
  });
  
  if (preview) {
    return (
      <div className="relative">
        <img
          src={preview}
          alt="Preview"
          className="w-full h-64 object-cover rounded-lg"
        />
        {onClear && (
          <button
            onClick={onClear}
            className="absolute top-2 right-2 p-2 bg-white rounded-full shadow-lg hover:bg-gray-100 transition-colors"
          >
            <X className="h-5 w-5 text-gray-600" />
          </button>
        )}
      </div>
    );
  }
  
  return (
    <div>
      <div
        {...getRootProps()}
        className={cn(
          'border-2 border-dashed rounded-lg p-8 text-center cursor-pointer transition-colors',
          isDragActive ? 'border-primary-500 bg-primary-50' : 'border-gray-300 hover:border-primary-400',
          error && 'border-red-500'
        )}
      >
        <input {...getInputProps()} />
        <Upload className="h-12 w-12 mx-auto mb-4 text-gray-400" />
        <p className="text-lg font-medium text-gray-700 mb-2">
          {isDragActive ? 'Drop the image here' : 'Drag & drop an image'}
        </p>
        <p className="text-sm text-gray-500 mb-4">
          or click to browse
        </p>
        <p className="text-xs text-gray-400">
          Supports: JPEG, PNG, WebP (max 10MB)
        </p>
      </div>
      
      {error && (
        <p className="mt-2 text-sm text-red-600">{error}</p>
      )}
    </div>
  );
};
