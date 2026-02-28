import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { wardrobeAPI } from '@/api/wardrobe';
import type { WardrobeFilters, WardrobeItemMetadata } from '@/types/wardrobe.types';

export const useWardrobe = (filters?: WardrobeFilters) => {
  const queryClient = useQueryClient();
  
  const { data, isLoading, error } = useQuery({
    queryKey: ['wardrobe', filters],
    queryFn: async () => {
      const response = await wardrobeAPI.getItems(filters);
      return response.data;
    },
  });
  
  const uploadMutation = useMutation({
    mutationFn: ({ file, metadata }: { file: File; metadata: WardrobeItemMetadata }) =>
      wardrobeAPI.uploadItem(file, metadata),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['wardrobe'] });
    },
  });
  
  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<any> }) =>
      wardrobeAPI.updateItem(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['wardrobe'] });
    },
  });
  
  const deleteMutation = useMutation({
    mutationFn: (id: string) => wardrobeAPI.deleteItem(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['wardrobe'] });
    },
  });
  
  return {
    items: data?.results || [],
    total: data?.count || 0,
    isLoading,
    error,
    uploadItem: uploadMutation.mutate,
    updateItem: updateMutation.mutate,
    deleteItem: deleteMutation.mutate,
    isUploading: uploadMutation.isPending,
    isUpdating: updateMutation.isPending,
    isDeleting: deleteMutation.isPending,
  };
};

export const useWardrobeItem = (id: string) => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['wardrobe', id],
    queryFn: async () => {
      const response = await wardrobeAPI.getItem(id);
      return response.data;
    },
    enabled: !!id,
  });
  
  return { item: data, isLoading, error };
};

export const useSimilarItems = (id: string, limit?: number) => {
  const { data, isLoading, error } = useQuery({
    queryKey: ['wardrobe', id, 'similar', limit],
    queryFn: async () => {
      const response = await wardrobeAPI.getSimilar(id, limit);
      return response.data;
    },
    enabled: !!id,
  });
  
  return { items: data || [], isLoading, error };
};
