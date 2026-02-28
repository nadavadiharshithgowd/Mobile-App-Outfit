import '../datasources/tryon_remote_datasource.dart';
import '../models/tryon_result_model.dart';

class TryOnRepository {
  final TryOnRemoteDatasource _remoteDatasource;

  TryOnRepository({required TryOnRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  Future<TryOnResultModel> submitTryOn({
    required String personImageS3,
    required String garmentItemId,
  }) {
    return _remoteDatasource.submitTryOn(
      personImageS3: personImageS3,
      garmentItemId: garmentItemId,
    );
  }

  Future<TryOnResultModel> getTryOnResult(String id) {
    return _remoteDatasource.getTryOnResult(id);
  }

  Future<List<TryOnResultModel>> getTryOnHistory({int page = 1}) {
    return _remoteDatasource.getTryOnHistory(page: page);
  }

  Future<void> deleteTryOnResult(String id) {
    return _remoteDatasource.deleteTryOnResult(id);
  }
}
