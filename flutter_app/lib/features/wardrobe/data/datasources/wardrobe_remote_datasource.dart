import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/wardrobe_item_model.dart';

class WardrobeRemoteDatasource {
  final ApiClient _apiClient;

  WardrobeRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<WardrobeListResponse> getWardrobeItems({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (category != null && category != 'all') {
      queryParams['category'] = category;
    }

    final response = await _apiClient.get(
      ApiEndpoints.wardrobe,
      queryParameters: queryParams,
    );

    return WardrobeListResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<WardrobeItemModel> getWardrobeItem(String id) async {
    final response = await _apiClient.get(ApiEndpoints.wardrobeItem(id));
    return WardrobeItemModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<WardrobeItemModel> updateWardrobeItem(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch(
      ApiEndpoints.wardrobeItem(id),
      data: data,
    );
    return WardrobeItemModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> deleteWardrobeItem(String id) async {
    await _apiClient.delete(ApiEndpoints.wardrobeItem(id));
  }

  Future<Map<String, int>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.wardrobeCategories);
    final data = response.data as Map<String, dynamic>;
    return data.map((key, value) => MapEntry(key, value as int));
  }
}

class WardrobeListResponse {
  final int count;
  final String? next;
  final List<WardrobeItemModel> results;

  WardrobeListResponse({
    required this.count,
    this.next,
    required this.results,
  });

  factory WardrobeListResponse.fromJson(Map<String, dynamic> json) {
    return WardrobeListResponse(
      count: json['count'] as int,
      next: json['next'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) =>
              WardrobeItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasMore => next != null;
}
