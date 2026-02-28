import 'dart:typed_data';
import 'package:mime/mime.dart';
import '../network/api_client.dart';
import '../constants/api_endpoints.dart';

class S3UploadUtil {
  final ApiClient _apiClient;

  S3UploadUtil({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<S3UploadResult> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String uploadType,
    Map<String, String>? overrides,
    void Function(double progress)? onProgress,
  }) async {
    final contentType =
        lookupMimeType(fileName) ?? 'application/octet-stream';

    // Step 1: Get presigned URL from backend
    final presignedResponse = await _apiClient.post(
      ApiEndpoints.presignedUrl,
      data: {
        'file_name': fileName,
        'content_type': contentType,
        'upload_type': uploadType,
      },
    );

    final presignedUrl = presignedResponse.data['presigned_url'] as String;
    final s3Key = presignedResponse.data['s3_key'] as String;

    // Step 2: Upload directly to S3
    await _apiClient.uploadToPresignedUrl(
      presignedUrl,
      fileBytes,
      contentType,
      onSendProgress: (sent, total) {
        if (onProgress != null && total > 0) {
          onProgress(sent / total);
        }
      },
    );

    // Step 3: Confirm upload with backend
    final confirmResponse = await _apiClient.post(
      ApiEndpoints.confirmUpload,
      data: {
        's3_key': s3Key,
        'upload_type': uploadType,
        if (overrides != null) ...overrides,
      },
    );

    return S3UploadResult(
      s3Key: s3Key,
      itemId: confirmResponse.data['wardrobe_item_id'] as String?,
      status: confirmResponse.data['status'] as String? ?? 'processing',
    );
  }
}

class S3UploadResult {
  final String s3Key;
  final String? itemId;
  final String status;

  S3UploadResult({
    required this.s3Key,
    this.itemId,
    required this.status,
  });
}
