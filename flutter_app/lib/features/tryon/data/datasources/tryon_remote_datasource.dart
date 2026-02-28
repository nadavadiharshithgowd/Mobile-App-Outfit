import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/tryon_result_model.dart';

class TryOnRemoteDatasource {
  final ApiClient _apiClient;

  TryOnRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<TryOnResultModel> submitTryOn({
    required String personImageS3,
    required String garmentItemId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.tryOn,
      data: {
        'person_image_s3': personImageS3,
        'garment_item_id': garmentItemId,
      },
    );
    return TryOnResultModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<TryOnResultModel> getTryOnResult(String id) async {
    final response = await _apiClient.get(ApiEndpoints.tryOnDetail(id));
    return TryOnResultModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<List<TryOnResultModel>> getTryOnHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.tryOn,
      queryParameters: {'page': page, 'page_size': pageSize},
    );
    final data = response.data as Map<String, dynamic>;
    return (data['results'] as List<dynamic>)
        .map((e) => TryOnResultModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteTryOnResult(String id) async {
    await _apiClient.delete(ApiEndpoints.tryOnDetail(id));
  }
}
