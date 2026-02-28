class TryOnResultModel {
  final String id;
  final String personImageS3;
  final String? garmentItemId;
  final String? resultImageUrl;
  final String status;
  final String? errorMessage;
  final int? processingTimeMs;
  final DateTime createdAt;
  final DateTime? completedAt;

  const TryOnResultModel({
    required this.id,
    required this.personImageS3,
    this.garmentItemId,
    this.resultImageUrl,
    required this.status,
    this.errorMessage,
    this.processingTimeMs,
    required this.createdAt,
    this.completedAt,
  });

  factory TryOnResultModel.fromJson(Map<String, dynamic> json) {
    return TryOnResultModel(
      id: json['id'] as String,
      personImageS3: json['person_image_s3'] as String,
      garmentItemId: json['garment_item_id'] as String?,
      resultImageUrl: json['result_image_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      errorMessage: json['error_message'] as String?,
      processingTimeMs: json['processing_time_ms'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

class TryOnStatusUpdate {
  final String status;
  final int progress;
  final String? step;
  final String? resultUrl;

  const TryOnStatusUpdate({
    required this.status,
    required this.progress,
    this.step,
    this.resultUrl,
  });

  factory TryOnStatusUpdate.fromJson(Map<String, dynamic> json) {
    return TryOnStatusUpdate(
      status: json['status'] as String,
      progress: json['progress'] as int,
      step: json['step'] as String?,
      resultUrl: json['result_url'] as String?,
    );
  }
}
