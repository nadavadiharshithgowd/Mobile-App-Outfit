import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class TryOnEvent extends Equatable {
  const TryOnEvent();

  @override
  List<Object?> get props => [];
}

class TryOnSelectPersonImage extends TryOnEvent {
  final Uint8List imageBytes;
  final String fileName;
  final String? s3Key;

  const TryOnSelectPersonImage({
    required this.imageBytes,
    required this.fileName,
    this.s3Key,
  });

  @override
  List<Object?> get props => [fileName, s3Key];
}

class TryOnSelectGarment extends TryOnEvent {
  final String garmentItemId;
  final String? garmentImageUrl;
  final String garmentName;

  const TryOnSelectGarment({
    required this.garmentItemId,
    this.garmentImageUrl,
    required this.garmentName,
  });

  @override
  List<Object?> get props => [garmentItemId];
}

class TryOnGenerate extends TryOnEvent {
  const TryOnGenerate();
}

class TryOnPollStatus extends TryOnEvent {
  final String tryOnId;
  const TryOnPollStatus(this.tryOnId);

  @override
  List<Object?> get props => [tryOnId];
}

class TryOnLoadHistory extends TryOnEvent {
  const TryOnLoadHistory();
}

class TryOnReset extends TryOnEvent {
  const TryOnReset();
}
