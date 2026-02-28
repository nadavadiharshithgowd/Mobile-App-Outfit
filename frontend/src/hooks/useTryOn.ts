import { useState, useEffect, useRef } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { tryonAPI } from '@/api/tryon';
import { TryOnWebSocket } from '@/api/websocket';
import type { TryOnStatusUpdate } from '@/types/tryon.types';

export const useTryOn = () => {
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['tryon', 'history'],
    queryFn: async () => {
      const response = await tryonAPI.getTryOnHistory();
      return response.data;
    },
  });

  const createMutation = useMutation({
    mutationFn: ({ personImage, garmentItemId }: { personImage: File; garmentItemId: string }) =>
      tryonAPI.createTryOn(personImage, garmentItemId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tryon'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => tryonAPI.deleteTryOn(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['tryon'] });
    },
  });

  return {
    history: data?.results || [],
    total: data?.count || 0,
    isLoading,
    createTryOn: createMutation.mutate,
    createTryOnAsync: createMutation.mutateAsync,
    deleteTryOn: deleteMutation.mutate,
    isCreating: createMutation.isPending,
    isDeleting: deleteMutation.isPending,
    lastCreated: createMutation.data?.data,
  };
};

export const useTryOnStatus = (tryonId: string | null) => {
  const [status, setStatus] = useState<TryOnStatusUpdate | null>(null);
  const [isConnected, setIsConnected] = useState(false);
  const wsRef = useRef<TryOnWebSocket | null>(null);
  const pollRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const queryClient = useQueryClient();

  useEffect(() => {
    if (!tryonId) {
      setStatus(null);
      setIsConnected(false);
      return;
    }

    wsRef.current = new TryOnWebSocket();

    const startPolling = () => {
      if (pollRef.current) return;
      pollRef.current = setInterval(async () => {
        try {
          const response = await tryonAPI.getTryOnResult(tryonId);
          const result = response.data;
          setStatus({
            status: result.status,
            result_url: result.result_image_url,
            error_message: result.error_message,
          });
          if (result.status === 'completed' || result.status === 'failed') {
            clearInterval(pollRef.current!);
            pollRef.current = null;
            queryClient.invalidateQueries({ queryKey: ['tryon'] });
          }
        } catch {
          clearInterval(pollRef.current!);
          pollRef.current = null;
        }
      }, 3000);
    };

    wsRef.current.connect(
      tryonId,
      (update: TryOnStatusUpdate) => {
        setStatus(update);
        setIsConnected(true);
        if (update.status === 'completed' || update.status === 'failed') {
          queryClient.invalidateQueries({ queryKey: ['tryon'] });
        }
      },
      () => {
        setIsConnected(false);
        startPolling();
      }
    );

    return () => {
      wsRef.current?.disconnect();
      if (pollRef.current) {
        clearInterval(pollRef.current);
        pollRef.current = null;
      }
    };
  }, [tryonId, queryClient]);

  return { status, isConnected };
};
