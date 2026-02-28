import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class UploadState extends Equatable {
  const UploadState();

  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadState {
  const UploadInitial();
}

class UploadImageReady extends UploadState {
  final Uint8List imageBytes;
  final String fileName;

  const UploadImageReady({
    required this.imageBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [fileName];
}

class UploadInProgress extends UploadState {
  final double progress;
  final String message;

  const UploadInProgress({
    required this.progress,
    this.message = 'Uploading...',
  });

  @override
  List<Object?> get props => [progress, message];
}

class UploadProcessing extends UploadState {
  final String itemId;

  const UploadProcessing({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class UploadSuccess extends UploadState {
  final String itemId;

  const UploadSuccess({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}

class UploadError extends UploadState {
  final String message;
  const UploadError(this.message);

  @override
  List<Object?> get props => [message];
}
