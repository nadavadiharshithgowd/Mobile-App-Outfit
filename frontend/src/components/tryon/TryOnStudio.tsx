import { useState, useRef } from 'react';
import { Upload, User, Shirt, ChevronRight } from 'lucide-react';
import { useDropzone } from 'react-dropzone';
import { useWardrobe } from '@/hooks/useWardrobe';
import { WardrobeItemCard } from '@/components/wardrobe/WardrobeItemCard';
import { Button } from '@/components/common/Button';
import { cn } from '@/utils/cn';
import type { WardrobeItem } from '@/types/wardrobe.types';

interface TryOnStudioProps {
  onSubmit: (personImage: File, garmentItemId: string) => void;
  isSubmitting?: boolean;
}

type Step = 1 | 2 | 3;

export const TryOnStudio = ({ onSubmit, isSubmitting }: TryOnStudioProps) => {
  const [step, setStep] = useState<Step>(1);
  const [personImage, setPersonImage] = useState<File | null>(null);
  const [personPreview, setPersonPreview] = useState<string | null>(null);
  const [selectedGarment, setSelectedGarment] = useState<WardrobeItem | null>(null);

  const { items, isLoading } = useWardrobe();

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    accept: { 'image/*': ['.jpg', '.jpeg', '.png', '.webp'] },
    maxFiles: 1,
    maxSize: 10 * 1024 * 1024,
    onDrop: (accepted) => {
      if (accepted[0]) {
        setPersonImage(accepted[0]);
        setPersonPreview(URL.createObjectURL(accepted[0]));
        setStep(2);
      }
    },
  });

  const handleGarmentSelect = (item: WardrobeItem) => {
    setSelectedGarment(item);
    setStep(3);
  };

  const handleSubmit = () => {
    if (!personImage || !selectedGarment) return;
    onSubmit(personImage, selectedGarment.id);
  };

  const steps = [
    { n: 1, label: 'Upload Photo', icon: User },
    { n: 2, label: 'Pick Garment', icon: Shirt },
    { n: 3, label: 'Try On', icon: ChevronRight },
  ];

  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
      {/* Step indicator */}
      <div className="flex border-b">
        {steps.map(({ n, label, icon: Icon }) => (
          <button
            key={n}
            onClick={() => n < step && setStep(n as Step)}
            className={cn(
              'flex-1 flex items-center justify-center gap-2 py-4 text-sm font-medium transition-colors',
              step === n
                ? 'bg-primary-50 text-primary-700 border-b-2 border-primary-500'
                : step > n
                ? 'text-green-600 hover:bg-gray-50 cursor-pointer'
                : 'text-gray-400 cursor-default'
            )}
          >
            <div
              className={cn(
                'w-6 h-6 rounded-full flex items-center justify-center text-xs font-bold',
                step === n
                  ? 'bg-primary-500 text-white'
                  : step > n
                  ? 'bg-green-500 text-white'
                  : 'bg-gray-200 text-gray-500'
              )}
            >
              {step > n ? '✓' : n}
            </div>
            <span className="hidden sm:inline">{label}</span>
          </button>
        ))}
      </div>

      <div className="p-6">
        {/* Step 1: Upload person photo */}
        {step === 1 && (
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-1">Upload Your Photo</h3>
            <p className="text-sm text-gray-500 mb-6">
              Use a full-body photo with a plain background for best results.
            </p>
            <div
              {...getRootProps()}
              className={cn(
                'border-2 border-dashed rounded-2xl p-12 text-center cursor-pointer transition-all',
                isDragActive
                  ? 'border-primary-500 bg-primary-50'
                  : 'border-gray-200 hover:border-primary-300 hover:bg-gray-50'
              )}
            >
              <input {...getInputProps()} />
              <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Upload className="h-8 w-8 text-primary-500" />
              </div>
              <p className="font-medium text-gray-700 mb-1">
                {isDragActive ? 'Drop your photo here' : 'Drag & drop or click to upload'}
              </p>
              <p className="text-sm text-gray-400">JPG, PNG, WEBP · Max 10 MB</p>
            </div>
          </div>
        )}

        {/* Step 2: Select garment */}
        {step === 2 && (
          <div>
            <div className="flex items-center gap-4 mb-6">
              {personPreview && (
                <img
                  src={personPreview}
                  alt="Your photo"
                  className="w-16 h-16 rounded-xl object-cover border-2 border-primary-200"
                />
              )}
              <div>
                <h3 className="text-lg font-semibold text-gray-900">Select a Garment</h3>
                <p className="text-sm text-gray-500">Choose what you want to try on</p>
              </div>
            </div>

            {isLoading ? (
              <div className="grid grid-cols-3 sm:grid-cols-4 gap-3">
                {Array.from({ length: 8 }).map((_, i) => (
                  <div key={i} className="aspect-square bg-gray-100 rounded-xl animate-pulse" />
                ))}
              </div>
            ) : items.length === 0 ? (
              <div className="text-center py-12 text-gray-400">
                <Shirt className="h-12 w-12 mx-auto mb-3 opacity-30" />
                <p className="font-medium">No wardrobe items yet</p>
                <p className="text-sm">Add clothes to your wardrobe first</p>
              </div>
            ) : (
              <div className="grid grid-cols-3 sm:grid-cols-4 gap-3 max-h-80 overflow-y-auto pr-1">
                {items.map((item) => (
                  <WardrobeItemCard
                    key={item.id}
                    item={item}
                    onSelect={handleGarmentSelect}
                    isSelected={selectedGarment?.id === item.id}
                  />
                ))}
              </div>
            )}
          </div>
        )}

        {/* Step 3: Confirm & submit */}
        {step === 3 && (
          <div>
            <h3 className="text-lg font-semibold text-gray-900 mb-6">Ready to Try On</h3>
            <div className="flex gap-6 mb-8">
              {personPreview && (
                <div className="flex-1">
                  <p className="text-xs font-medium text-gray-500 mb-2 uppercase tracking-wide">
                    Your Photo
                  </p>
                  <img
                    src={personPreview}
                    alt="Your photo"
                    className="w-full aspect-[3/4] object-cover rounded-2xl border border-gray-200"
                  />
                </div>
              )}
              {selectedGarment && (
                <div className="flex-1">
                  <p className="text-xs font-medium text-gray-500 mb-2 uppercase tracking-wide">
                    Selected Garment
                  </p>
                  <img
                    src={
                      selectedGarment.images?.find((i) => i.image_type === 'thumbnail')?.url ||
                      selectedGarment.images?.find((i) => i.image_type === 'cropped')?.url ||
                      selectedGarment.images?.find((i) => i.image_type === 'original')?.url ||
                      undefined
                    }
                    alt="Garment"
                    className="w-full aspect-[3/4] object-cover rounded-2xl border border-gray-200"
                  />
                  <p className="mt-2 text-sm text-center text-gray-600">
                    {selectedGarment.name || selectedGarment.brand || selectedGarment.category}
                  </p>
                </div>
              )}
            </div>

            <div className="flex gap-3">
              <Button
                variant="outline"
                onClick={() => setStep(2)}
                className="flex-1"
              >
                Change Garment
              </Button>
              <Button
                onClick={handleSubmit}
                disabled={isSubmitting}
                isLoading={isSubmitting}
                className="flex-1"
              >
                Start Try-On
              </Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
