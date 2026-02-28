import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import '../../data/models/tryon_result_model.dart';

abstract class TryOnState extends Equatable {
  const TryOnState();

  @override
  List<Object?> get props => [];
}

class TryOnInitial extends TryOnState {
  const TryOnInitial();
}

class TryOnReady extends TryOnState {
  final Uint8List? personImageBytes;
  final String? personImageS3Key;
  final String? garmentItemId;
  final String? garmentImageUrl;
  final String? garmentName;
  final List<TryOnResultModel> history;

  const TryOnReady({
    this.personImageBytes,
    this.personImageS3Key,
    this.garmentItemId,
    this.garmentImageUrl,
    this.garmentName,
    this.history = const [],
  });

  bool get canGenerate =>
      personImageS3Key != null && garmentItemId != null;

  @override
  List<Object?> get props => [
        personImageS3Key,
        garmentItemId,
        garmentImageUrl,
        garmentName,
        history,
      ];

  TryOnReady copyWith({
    Uint8List? personImageBytes,
    String? personImageS3Key,
    String? garmentItemId,
    String? garmentImageUrl,
    String? garmentName,
    List<TryOnResultModel>? history,
  }) {
    return TryOnReady(
      personImageBytes: personImageBytes ?? this.personImageBytes,
      personImageS3Key: personImageS3Key ?? this.personImageS3Key,
      garmentItemId: garmentItemId ?? this.garmentItemId,
      garmentImageUrl: garmentImageUrl ?? this.garmentImageUrl,
      garmentName: garmentName ?? this.garmentName,
      history: history ?? this.history,
    );
  }
}

class TryOnProcessing extends TryOnState {
  final String tryOnId;
  final int progress;
  final String step;

  const TryOnProcessing({
    required this.tryOnId,
    this.progress = 0,
    this.step = 'Preparing...',
  });

  @override
  List<Object?> get props => [tryOnId, progress, step];
}

class TryOnCompleted extends TryOnState {
  final String tryOnId;
  final String resultImageUrl;
  final Uint8List? personImageBytes;

  const TryOnCompleted({
    required this.tryOnId,
    required this.resultImageUrl,
    this.personImageBytes,
  });

  @override
  List<Object?> get props => [tryOnId, resultImageUrl];
}

class TryOnError extends TryOnState {
  final String message;
  const TryOnError(this.message);

  @override
  List<Object?> get props => [message];
}
