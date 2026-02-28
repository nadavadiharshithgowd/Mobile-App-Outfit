import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/outfit_model.dart';

class OutfitRemoteDatasource {
  final ApiClient _apiClient;

  OutfitRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<DailyRecommendationResponse> getDailyRecommendations() async {
    final response = await _apiClient.get(ApiEndpoints.dailyRecommendation);
    return DailyRecommendationResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> generateRecommendations() async {
    await _apiClient.post(ApiEndpoints.generateRecommendation);
  }

  Future<void> acceptRecommendation(String id) async {
    await _apiClient.post(ApiEndpoints.acceptRecommendation(id));
  }

  Future<void> rejectRecommendation(String id) async {
    await _apiClient.post(ApiEndpoints.rejectRecommendation(id));
  }

  Future<List<OutfitModel>> getOutfitHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.outfits,
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final data = response.data as Map<String, dynamic>;
    return (data['results'] as List<dynamic>)
        .map((e) => OutfitModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OutfitModel> getOutfitDetail(String id) async {
    final response = await _apiClient.get(ApiEndpoints.outfitDetail(id));
    return OutfitModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> toggleFavorite(String id) async {
    await _apiClient.post(ApiEndpoints.outfitFavorite(id));
  }

  Future<void> deleteOutfit(String id) async {
    await _apiClient.delete(ApiEndpoints.outfitDetail(id));
  }
}
