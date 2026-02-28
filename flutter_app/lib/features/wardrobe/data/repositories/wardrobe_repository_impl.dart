import '../datasources/wardrobe_remote_datasource.dart';
import '../models/wardrobe_item_model.dart';

class WardrobeRepository {
  final WardrobeRemoteDatasource _remoteDatasource;

  WardrobeRepository({required WardrobeRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  Future<WardrobeListResponse> getItems({
    String? category,
    int page = 1,
    int pageSize = 20,
  }) {
    return _remoteDatasource.getWardrobeItems(
      category: category,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<WardrobeItemModel> getItem(String id) {
    return _remoteDatasource.getWardrobeItem(id);
  }

  Future<WardrobeItemModel> updateItem(
    String id,
    Map<String, dynamic> data,
  ) {
    return _remoteDatasource.updateWardrobeItem(id, data);
  }

  Future<void> deleteItem(String id) {
    return _remoteDatasource.deleteWardrobeItem(id);
  }

  Future<Map<String, int>> getCategories() {
    return _remoteDatasource.getCategories();
  }
}
