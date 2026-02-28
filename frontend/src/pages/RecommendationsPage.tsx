import { useState } from 'react';
import { Sparkles, RefreshCw, Sliders } from 'lucide-react';
import { useRecommendations } from '@/hooks/useOutfits';
import { RecommendationCard } from '@/components/outfits/RecommendationCard';
import { Button } from '@/components/common/Button';
import { LoadingSpinner } from '@/components/common/LoadingSpinner';
import { useToast } from '@/components/common/Toast';
import type { Occasion } from '@/types/outfit.types';
import type { Season } from '@/types/wardrobe.types';

const OCCASIONS: { value: Occasion | ''; label: string }[] = [
  { value: '', label: 'Any occasion' },
  { value: 'casual', label: 'Casual' },
  { value: 'formal', label: 'Formal' },
  { value: 'business', label: 'Business' },
  { value: 'sport', label: 'Sport' },
  { value: 'party', label: 'Party' },
];

const SEASONS: { value: Season | ''; label: string }[] = [
  { value: '', label: 'Any season' },
  { value: 'spring', label: 'Spring' },
  { value: 'summer', label: 'Summer' },
  { value: 'fall', label: 'Fall' },
  { value: 'winter', label: 'Winter' },
];

export const RecommendationsPage = () => {
  const [showFilters, setShowFilters] = useState(false);
  const [occasion, setOccasion] = useState<Occasion | ''>('');
  const [season, setSeason] = useState<Season | ''>('');

  const { recommendation, outfits, isLoading, generate, accept, reject, isGenerating, isAccepting, isRejecting, generatedOutfits, refetch } =
    useRecommendations();

  const { success, error, info } = useToast();

  const displayOutfits = generatedOutfits.length > 0 ? generatedOutfits : outfits;

  const handleGenerate = () => {
    generate(
      {
        occasion: occasion || undefined,
        season: season || undefined,
        num_outfits: 5,
      },
      {
        onSuccess: () => info('New recommendations generated!'),
        onError: () => error('Failed to generate recommendations. Add more items to your wardrobe.'),
      }
    );
  };

  const handleAccept = (id: string) => {
    accept(id, {
      onSuccess: () => success('Outfit saved to your wardrobe!'),
      onError: () => error('Failed to accept outfit.'),
    });
  };

  const handleReject = (id: string) => {
    reject(id, {
      onSuccess: () => info('Outfit skipped.'),
      onError: () => error('Failed to skip outfit.'),
    });
  };

  const today = new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
  });

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-2">
                <Sparkles className="h-7 w-7 text-amber-400" />
                Today's Picks
              </h1>
              <p className="text-gray-500 mt-1">{today}</p>
            </div>
            <div className="flex items-center gap-3">
              <button
                onClick={() => setShowFilters((v) => !v)}
                className="flex items-center gap-2 px-4 py-2 rounded-xl border border-gray-200 text-sm text-gray-600 hover:bg-gray-50 transition-colors"
              >
                <Sliders className="h-4 w-4" />
                Filters
              </button>
              <Button onClick={handleGenerate} isLoading={isGenerating}>
                <RefreshCw className="h-4 w-4 mr-2" />
                Generate
              </Button>
            </div>
          </div>

          {/* Filters */}
          {showFilters && (
            <div className="mt-5 pt-5 border-t grid grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">
                  Occasion
                </label>
                <div className="flex flex-wrap gap-2">
                  {OCCASIONS.map((o) => (
                    <button
                      key={o.value}
                      onClick={() => setOccasion(o.value)}
                      className={`px-3 py-1 rounded-full text-sm border transition-all ${
                        occasion === o.value
                          ? 'border-primary-500 bg-primary-50 text-primary-700 font-medium'
                          : 'border-gray-200 text-gray-500 hover:border-gray-300'
                      }`}
                    >
                      {o.label}
                    </button>
                  ))}
                </div>
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase mb-2">
                  Season
                </label>
                <div className="flex flex-wrap gap-2">
                  {SEASONS.map((s) => (
                    <button
                      key={s.value}
                      onClick={() => setSeason(s.value)}
                      className={`px-3 py-1 rounded-full text-sm border transition-all ${
                        season === s.value
                          ? 'border-primary-500 bg-primary-50 text-primary-700 font-medium'
                          : 'border-gray-200 text-gray-500 hover:border-gray-300'
                      }`}
                    >
                      {s.label}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Body */}
      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {isLoading || isGenerating ? (
          <div className="flex flex-col items-center justify-center py-24 gap-4">
            <LoadingSpinner size="lg" />
            <p className="text-gray-500 text-sm animate-pulse">
              {isGenerating ? 'AI is crafting your outfits…' : 'Loading recommendations…'}
            </p>
          </div>
        ) : displayOutfits.length === 0 ? (
          <div className="text-center py-24">
            <div className="w-20 h-20 bg-amber-50 rounded-full flex items-center justify-center mx-auto mb-4">
              <Sparkles className="h-10 w-10 text-amber-300" />
            </div>
            <h3 className="text-lg font-semibold text-gray-700 mb-2">No recommendations yet</h3>
            <p className="text-gray-400 mb-6 max-w-sm mx-auto">
              Click <strong>Generate</strong> to get AI-powered outfit suggestions based on your wardrobe.
            </p>
            <Button onClick={handleGenerate} isLoading={isGenerating}>
              <Sparkles className="h-4 w-4 mr-2" />
              Generate Outfits
            </Button>
          </div>
        ) : (
          <>
            {recommendation && (
              <p className="text-xs text-gray-400 mb-4">
                Generated:{' '}
                {new Date(recommendation.generated_at).toLocaleString('en-US', {
                  month: 'short',
                  day: 'numeric',
                  hour: '2-digit',
                  minute: '2-digit',
                })}
              </p>
            )}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
              {displayOutfits.map((outfit: any, idx: number) => (
                <RecommendationCard
                  key={outfit.id}
                  outfit={outfit}
                  rank={idx + 1}
                  score={outfit.compatibility_score || 0}
                  onAccept={handleAccept}
                  onReject={handleReject}
                  isAccepting={isAccepting}
                  isRejecting={isRejecting}
                />
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
};
