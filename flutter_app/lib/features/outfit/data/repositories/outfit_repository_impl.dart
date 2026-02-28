import '../datasources/outfit_remote_datasource.dart';
import '../models/outfit_model.dart';

class OutfitRepository {
  final OutfitRemoteDatasource _remoteDatasource;

  OutfitRepository({required OutfitRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  Future<DailyRecommendationResponse> getDailyRecommendations() {
    return _remoteDatasource.getDailyRecommendations();
  }

  Future<void> generateRecommendations() {
    return _remoteDatasource.generateRecommendations();
  }

  Future<void> acceptRecommendation(String id) {
    return _remoteDatasource.acceptRecommendation(id);
  }

  Future<void> rejectRecommendation(String id) {
    return _remoteDatasource.rejectRecommendation(id);
  }

  Future<List<OutfitModel>> getOutfitHistory({int page = 1}) {
    return _remoteDatasource.getOutfitHistory(page: page);
  }

  Future<OutfitModel> getOutfitDetail(String id) {
    return _remoteDatasource.getOutfitDetail(id);
  }

  Future<void> toggleFavorite(String id) {
    return _remoteDatasource.toggleFavorite(id);
  }

  Future<void> deleteOutfit(String id) {
    return _remoteDatasource.deleteOutfit(id);
  }
}
