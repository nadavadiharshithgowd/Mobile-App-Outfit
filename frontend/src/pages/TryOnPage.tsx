import { useState, useEffect, useRef } from 'react';
import { Download, Trash2, Wand2, Clock } from 'lucide-react';
import { useTryOn, useTryOnStatus } from '@/hooks/useTryOn';
import { TryOnStudio } from '@/components/tryon/TryOnStudio';
import { ProcessingStatus } from '@/components/tryon/ProcessingStatus';
import { LoadingSpinner } from '@/components/common/LoadingSpinner';
import { useToast } from '@/components/common/Toast';
import { cn } from '@/utils/cn';
import type { TryOnResult } from '@/types/tryon.types';

export const TryOnPage = () => {
  const [activeTryOnId, setActiveTryOnId] = useState<string | null>(null);
  const [resultImage, setResultImage] = useState<string | null>(null);
  // Incrementing this key unmounts+remounts TryOnStudio, resetting it to step 1
  const [studioKey, setStudioKey] = useState(0);
  // Track the last try-on ID that produced a completion so we only reset once
  const completedIdRef = useRef<string | null>(null);

  const { history, isLoading, createTryOnAsync, deleteTryOn, isCreating, isDeleting } = useTryOn();
  const { status, isConnected } = useTryOnStatus(activeTryOnId);

  const { success, error, info } = useToast();

  // When polling/WebSocket signals completion, update result and reset studio.
  // Done in useEffect (not during render) so the key change reliably remounts
  // TryOnStudio. The ref prevents re-running when polling refreshes the
  // pre-signed URL (same try-on, different URL string each call).
  useEffect(() => {
    if (
      status?.status === 'completed' &&
      status.result_url &&
      activeTryOnId &&
      completedIdRef.current !== activeTryOnId
    ) {
      completedIdRef.current = activeTryOnId;
      setResultImage(status.result_url);
      setStudioKey((k) => k + 1);
    }
  }, [status?.status, status?.result_url, activeTryOnId]);

  const handleSubmit = async (personImage: File, garmentItemId: string) => {
    try {
      setResultImage(null);
      const res = await createTryOnAsync({ personImage, garmentItemId });
      setActiveTryOnId(res.data.id);
      info('Try-on started! Processing your look…');
    } catch {
      error('Failed to start try-on. Please try again.');
    }
  };

  const handleHistoryView = (item: TryOnResult) => {
    setActiveTryOnId(item.id);
    setResultImage(item.result_image_url ?? null);
    // Mark as already-completed so the useEffect doesn't re-reset on next poll
    completedIdRef.current = item.id;
    // Reset studio to step 1 so it doesn't show the old person/garment preview
    setStudioKey((k) => k + 1);
  };

  const handleDelete = (id: string) => {
    if (!window.confirm('Delete this try-on?')) return;
    deleteTryOn(id, {
      onSuccess: () => {
        success('Try-on deleted.');
        if (activeTryOnId === id) {
          setActiveTryOnId(null);
          setResultImage(null);
        }
      },
      onError: () => error('Failed to delete.'),
    });
  };

  const handleDownload = (url: string) => {
    const a = document.createElement('a');
    a.href = url;
    a.download = `tryon-${Date.now()}.jpg`;
    a.click();
  };

  const isProcessing =
    activeTryOnId &&
    status?.status !== 'completed' &&
    status?.status !== 'failed';

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-2">
            <Wand2 className="h-7 w-7 text-purple-500" />
            Virtual Try-On
          </h1>
          <p className="text-gray-500 mt-1">
            Upload a photo and pick a garment to see how it looks
          </p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Left: Studio */}
          <div className="lg:col-span-2 space-y-6">
            <TryOnStudio key={studioKey} onSubmit={handleSubmit} isSubmitting={isCreating} />

            {/* Processing status */}
            {activeTryOnId && status && (
              <ProcessingStatus status={status} isConnected={isConnected} />
            )}

            {/* Result */}
            {resultImage && (
              <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
                <div className="flex items-center justify-between p-5 border-b">
                  <h3 className="font-semibold text-gray-900">Your Try-On Result</h3>
                  <button
                    onClick={() => handleDownload(resultImage)}
                    className="flex items-center gap-2 px-3 py-1.5 rounded-lg bg-gray-50 hover:bg-gray-100 text-sm text-gray-600 transition-colors"
                  >
                    <Download className="h-4 w-4" />
                    Download
                  </button>
                </div>
                <img
                  src={resultImage}
                  alt="Try-on result"
                  className="w-full max-h-[600px] object-contain"
                />
              </div>
            )}
          </div>

          {/* Right: History */}
          <div>
            <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden">
              <div className="p-5 border-b flex items-center gap-2">
                <Clock className="h-4 w-4 text-gray-400" />
                <h3 className="font-semibold text-gray-900">
                  History
                  {history.length > 0 && (
                    <span className="ml-2 text-xs font-normal text-gray-400">
                      ({history.length})
                    </span>
                  )}
                </h3>
              </div>

              {isLoading ? (
                <div className="flex justify-center py-8">
                  <LoadingSpinner />
                </div>
              ) : history.length === 0 ? (
                <div className="text-center py-10 text-gray-400 px-4">
                  <Wand2 className="h-10 w-10 mx-auto mb-3 opacity-20" />
                  <p className="text-sm">No try-ons yet</p>
                </div>
              ) : (
                <div className="divide-y divide-gray-50">
                  {history.map((item: TryOnResult) => (
                    <HistoryItem
                      key={item.id}
                      item={item}
                      isActive={activeTryOnId === item.id}
                      onView={() => handleHistoryView(item)}
                      onDelete={() => handleDelete(item.id)}
                    />
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const statusConfig = {
  pending: { label: 'Queued', color: 'bg-yellow-100 text-yellow-700' },
  processing: { label: 'Processing', color: 'bg-blue-100 text-blue-700' },
  completed: { label: 'Done', color: 'bg-green-100 text-green-700' },
  failed: { label: 'Failed', color: 'bg-red-100 text-red-700' },
};

const HistoryItem = ({
  item,
  isActive,
  onView,
  onDelete,
}: {
  item: TryOnResult;
  isActive: boolean;
  onView: () => void;
  onDelete: () => void;
}) => {
  const cfg = statusConfig[item.status];
  return (
    <div
      className={cn(
        'flex items-center gap-3 p-4 cursor-pointer hover:bg-gray-50 transition-colors group',
        isActive && 'bg-primary-50'
      )}
      onClick={onView}
    >
      {/* Thumbnail */}
      <div className="w-12 h-12 rounded-xl overflow-hidden bg-gray-100 shrink-0">
        {item.result_image_url ? (
          <img
            src={item.result_image_url}
            alt="Result"
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center">
            <Wand2 className="h-5 w-5 text-gray-300" />
          </div>
        )}
      </div>

      {/* Info */}
      <div className="flex-1 min-w-0">
        <span className={cn('text-xs font-medium px-2 py-0.5 rounded-full', cfg.color)}>
          {cfg.label}
        </span>
        <p className="text-xs text-gray-400 mt-1">
          {new Date(item.created_at).toLocaleDateString('en-US', {
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
          })}
        </p>
      </div>

      {/* Delete */}
      <button
        onClick={(e) => {
          e.stopPropagation();
          onDelete();
        }}
        className="opacity-0 group-hover:opacity-100 p-1.5 rounded-lg hover:bg-red-50 transition-all"
      >
        <Trash2 className="h-3.5 w-3.5 text-red-400" />
      </button>
    </div>
  );
};
