import { Loader2, CheckCircle, XCircle, Clock } from 'lucide-react';
import { cn } from '@/utils/cn';
import type { TryOnStatusUpdate } from '@/types/tryon.types';

interface ProcessingStatusProps {
  status: TryOnStatusUpdate | null;
  isConnected?: boolean;
}

const STEPS = [
  { id: 'pending', label: 'Queued', description: 'Your request is in the queue' },
  { id: 'processing', label: 'Processing', description: 'AI is generating your try-on' },
  { id: 'completed', label: 'Complete', description: 'Your result is ready!' },
];

export const ProcessingStatus = ({ status, isConnected }: ProcessingStatusProps) => {
  if (!status) return null;

  const currentStepIdx = STEPS.findIndex((s) => s.id === status.status);
  const isFailed = status.status === 'failed';

  const progress = status.progress_percent ?? (
    status.status === 'pending' ? 10
    : status.status === 'processing' ? 60
    : status.status === 'completed' ? 100
    : 0
  );

  return (
    <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
      {/* Connection indicator */}
      {!isConnected && status.status !== 'completed' && status.status !== 'failed' && (
        <div className="flex items-center gap-2 mb-4 text-xs text-amber-600 bg-amber-50 px-3 py-2 rounded-lg">
          <Clock className="h-3.5 w-3.5" />
          Polling for updates...
        </div>
      )}

      {isFailed ? (
        <div className="flex items-center gap-3 text-red-600">
          <XCircle className="h-8 w-8 shrink-0" />
          <div>
            <p className="font-semibold">Processing Failed</p>
            <p className="text-sm text-red-500 mt-0.5">
              {status.error_message || 'Something went wrong. Please try again.'}
            </p>
          </div>
        </div>
      ) : (
        <>
          {/* Progress bar */}
          <div className="mb-6">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-gray-700">
                {status.status === 'completed' ? 'Done!' : 'Processing...'}
              </span>
              <span className="text-sm font-bold text-primary-600">{progress}%</span>
            </div>
            <div className="h-2.5 bg-gray-100 rounded-full overflow-hidden">
              <div
                className="h-full bg-gradient-to-r from-primary-400 to-primary-600 rounded-full transition-all duration-700"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>

          {/* Steps */}
          <div className="space-y-3">
            {STEPS.map((step, idx) => {
              const isDone = idx < currentStepIdx || status.status === 'completed';
              const isActive = idx === currentStepIdx && status.status !== 'completed';

              return (
                <div key={step.id} className="flex items-center gap-3">
                  <div
                    className={cn(
                      'w-8 h-8 rounded-full flex items-center justify-center shrink-0 transition-all',
                      isDone
                        ? 'bg-green-100 text-green-600'
                        : isActive
                        ? 'bg-primary-100 text-primary-600'
                        : 'bg-gray-100 text-gray-400'
                    )}
                  >
                    {isDone ? (
                      <CheckCircle className="h-4 w-4" />
                    ) : isActive ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <span className="text-xs font-bold">{idx + 1}</span>
                    )}
                  </div>
                  <div>
                    <p
                      className={cn(
                        'text-sm font-medium',
                        isDone
                          ? 'text-green-700'
                          : isActive
                          ? 'text-primary-700'
                          : 'text-gray-400'
                      )}
                    >
                      {step.label}
                    </p>
                    {isActive && (
                      <p className="text-xs text-gray-500">{step.description}</p>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        </>
      )}
    </div>
  );
};
