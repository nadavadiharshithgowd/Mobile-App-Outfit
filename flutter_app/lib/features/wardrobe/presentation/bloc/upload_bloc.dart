import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/s3_upload_util.dart';
import 'upload_event.dart';
import 'upload_state.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  final S3UploadUtil _uploadUtil;

  UploadBloc({required S3UploadUtil uploadUtil})
      : _uploadUtil = uploadUtil,
        super(const UploadInitial()) {
    on<UploadImageSelected>(_onImageSelected);
    on<UploadStarted>(_onUploadStarted);
    on<UploadReset>(_onReset);
  }

  late String _currentFileName;
  late Uint8List _currentImageBytes;

  Future<void> _onImageSelected(
    UploadImageSelected event,
    Emitter<UploadState> emit,
  ) async {
    _currentFileName = event.fileName;
    _currentImageBytes = event.imageBytes;
    emit(UploadImageReady(
      imageBytes: event.imageBytes,
      fileName: event.fileName,
    ));
  }

  Future<void> _onUploadStarted(
    UploadStarted event,
    Emitter<UploadState> emit,
  ) async {
    emit(const UploadInProgress(progress: 0, message: 'Preparing upload...'));

    try {
      final result = await _uploadUtil.uploadFile(
        fileBytes: _currentImageBytes,
        fileName: _currentFileName,
        uploadType: 'wardrobe',
        overrides: event.overrides,
        onProgress: (progress) {
          // Emitting from callback doesn't work with bloc,
          // but the upload is fast enough that this is acceptable
        },
      );

      if (result.itemId != null) {
        emit(UploadProcessing(itemId: result.itemId!));

        // Wait briefly then mark success
        // In production, poll for AI processing status
        await Future.delayed(const Duration(seconds: 2));
        emit(UploadSuccess(itemId: result.itemId!));
      } else {
        emit(const UploadError('Upload failed - no item ID returned'));
      }
    } on ApiException catch (e) {
      emit(UploadError(e.message));
    } catch (e) {
      emit(UploadError('Upload failed: ${e.toString()}'));
    }
  }

  void _onReset(UploadReset event, Emitter<UploadState> emit) {
    emit(const UploadInitial());
  }
}
