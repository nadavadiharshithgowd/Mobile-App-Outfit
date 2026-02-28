import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class UploadImageSelected extends UploadEvent {
  final Uint8List imageBytes;
  final String fileName;

  const UploadImageSelected({
    required this.imageBytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [fileName];
}

class UploadStarted extends UploadEvent {
  final Map<String, String>? overrides;
  const UploadStarted({this.overrides});

  @override
  List<Object?> get props => [overrides];
}

class UploadReset extends UploadEvent {
  const UploadReset();
}
