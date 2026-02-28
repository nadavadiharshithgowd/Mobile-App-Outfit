import { Check, X, Star, Sparkles } from 'lucide-react';
import { cn } from '@/utils/cn';
import type { Outfit } from '@/types/outfit.types';

interface RecommendationCardProps {
  outfit: Outfit;
  rank: number;
  score: number;
  onAccept?: (id: string) => void;
  onReject?: (id: string) => void;
  isAccepting?: boolean;
  isRejecting?: boolean;
}

const occasionColors: Record<string, string> = {
  casual: 'bg-blue-50 border-blue-200',
  formal: 'bg-purple-50 border-purple-200',
  business: 'bg-gray-50 border-gray-200',
  sport: 'bg-green-50 border-green-200',
  party: 'bg-pink-50 border-pink-200',
};

const rankBadge = (rank: number) => {
  if (rank === 1) return { label: '#1 Pick', class: 'bg-amber-100 text-amber-700' };
  if (rank === 2) return { label: '#2 Pick', class: 'bg-gray-100 text-gray-600' };
  return { label: `#${rank} Pick`, class: 'bg-gray-50 text-gray-500' };
};

export const RecommendationCard = ({
  outfit,
  rank,
  score,
  onAccept,
  onReject,
  isAccepting,
  isRejecting,
}: RecommendationCardProps) => {
  const displayScore = Math.round(score * 100);
  const badge = rankBadge(rank);

  return (
    <div
      className={cn(
        'relative rounded-2xl border-2 p-5 transition-all hover:shadow-md',
        occasionColors[outfit.occasion] || 'bg-white border-gray-200'
      )}
    >
      {/* Rank badge */}
      <div className="absolute -top-3 left-5">
        <span className={cn('px-3 py-1 text-xs font-bold rounded-full shadow-sm', badge.class)}>
          {badge.label}
        </span>
      </div>

      <div className="mt-2">
        {/* Outfit name + occasion */}
        <div className="flex items-start justify-between mb-3">
          <div>
            <h3 className="font-semibold text-gray-900 text-lg">{outfit.name}</h3>
            <p className="text-sm text-gray-500 capitalize">{outfit.occasion}</p>
          </div>
          <div className="flex items-center gap-1 bg-white rounded-xl px-2.5 py-1.5 shadow-sm">
            <Sparkles className="h-4 w-4 text-amber-500" />
            <span className="text-sm font-bold text-gray-800">{displayScore}%</span>
          </div>
        </div>

        {/* Score breakdown */}
        <div className="space-y-1.5 mb-4">
          <ScoreBar
            label="Compatibility"
            value={outfit.compatibility_score}
            color="bg-primary-400"
          />
          {outfit.color_harmony_score != null && (
            <ScoreBar label="Color Harmony" value={outfit.color_harmony_score} color="bg-pink-400" />
          )}
          {outfit.style_rules_score != null && (
            <ScoreBar label="Style Rules" value={outfit.style_rules_score} color="bg-purple-400" />
          )}
        </div>

        {/* Pieces */}
        <p className="text-xs text-gray-500 mb-4">
          <Star className="inline h-3 w-3 mr-1" />
          {outfit.items?.length || 0} piece outfit
        </p>

        {/* Actions */}
        {(onAccept || onReject) && (
          <div className="flex gap-3">
            {onReject && (
              <button
                onClick={() => onReject(outfit.id)}
                disabled={isRejecting}
                className="flex-1 flex items-center justify-center gap-2 py-2 px-4 rounded-xl border-2 border-gray-300 text-gray-600 font-medium text-sm hover:border-red-300 hover:text-red-600 hover:bg-red-50 transition-all disabled:opacity-50"
              >
                <X className="h-4 w-4" />
                Skip
              </button>
            )}
            {onAccept && (
              <button
                onClick={() => onAccept(outfit.id)}
                disabled={isAccepting}
                className="flex-1 flex items-center justify-center gap-2 py-2 px-4 rounded-xl bg-primary-600 text-white font-medium text-sm hover:bg-primary-700 transition-colors disabled:opacity-50"
              >
                <Check className="h-4 w-4" />
                Wear This
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

const ScoreBar = ({
  label,
  value,
  color,
}: {
  label: string;
  value: number;
  color: string;
}) => (
  <div className="flex items-center gap-2">
    <span className="text-xs text-gray-500 w-28 shrink-0">{label}</span>
    <div className="flex-1 h-1.5 bg-white rounded-full overflow-hidden">
      <div
        className={cn('h-full rounded-full', color)}
        style={{ width: `${Math.round(value * 100)}%` }}
      />
    </div>
    <span className="text-xs font-medium text-gray-600 w-8 text-right">
      {Math.round(value * 100)}%
    </span>
  </div>
);
