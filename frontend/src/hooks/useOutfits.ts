import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { outfitsAPI } from '@/api/outfits';
import type { CreateOutfitRequest, OutfitFilters, RecommendationParams } from '@/types/outfit.types';

export const useOutfits = (filters?: OutfitFilters) => {
  const queryClient = useQueryClient();

  const { data, isLoading, error } = useQuery({
    queryKey: ['outfits', filters],
    queryFn: async () => {
      const response = await outfitsAPI.getOutfits(filters);
      return response.data;
    },
  });

  const createMutation = useMutation({
    mutationFn: (data: CreateOutfitRequest) => outfitsAPI.createOutfit(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['outfits'] });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => outfitsAPI.deleteOutfit(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['outfits'] });
    },
  });

  const toggleFavoriteMutation = useMutation({
    mutationFn: ({ id, is_favorite }: { id: string; is_favorite: boolean }) =>
      outfitsAPI.toggleFavorite(id, is_favorite),
    onMutate: async ({ id, is_favorite }) => {
      await queryClient.cancelQueries({ queryKey: ['outfits'] });
      const previous = queryClient.getQueryData(['outfits', filters]);
      queryClient.setQueryData(['outfits', filters], (old: any) => ({
        ...old,
        results: old?.results?.map((o: any) =>
          o.id === id ? { ...o, is_favorite } : o
        ),
      }));
      return { previous };
    },
    onError: (_err, _vars, ctx) => {
      queryClient.setQueryData(['outfits', filters], ctx?.previous);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['outfits'] });
    },
  });

  return {
    outfits: data?.results || [],
    total: data?.count || 0,
    isLoading,
    error,
    createOutfit: createMutation.mutate,
    deleteOutfit: deleteMutation.mutate,
    toggleFavorite: toggleFavoriteMutation.mutate,
    isCreating: createMutation.isPending,
    isDeleting: deleteMutation.isPending,
  };
};

export const useRecommendations = () => {
  const queryClient = useQueryClient();

  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['recommendations', 'daily'],
    queryFn: async () => {
      const response = await outfitsAPI.getDailyRecommendations();
      return response.data;
    },
    staleTime: 12 * 60 * 60 * 1000,
  });

  const generateMutation = useMutation({
    mutationFn: (params: RecommendationParams) => outfitsAPI.generateRecommendations(params),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['recommendations'] });
    },
  });

  const acceptMutation = useMutation({
    mutationFn: (id: string) => outfitsAPI.acceptRecommendation(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['recommendations'] });
      queryClient.invalidateQueries({ queryKey: ['outfits'] });
    },
  });

  const rejectMutation = useMutation({
    mutationFn: (id: string) => outfitsAPI.rejectRecommendation(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['recommendations'] });
    },
  });

  return {
    recommendation: data,
    outfits: (data as any)?.outfits || [],
    isLoading,
    error,
    refetch,
    generate: generateMutation.mutate,
    accept: acceptMutation.mutate,
    reject: rejectMutation.mutate,
    isGenerating: generateMutation.isPending,
    isAccepting: acceptMutation.isPending,
    isRejecting: rejectMutation.isPending,
    generatedOutfits: generateMutation.data?.data?.recommendations || [],
  };
};
