import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/utils/s3_upload_util.dart';
import '../../data/repositories/tryon_repository_impl.dart';
import 'tryon_event.dart';
import 'tryon_state.dart';

class TryOnBloc extends Bloc<TryOnEvent, TryOnState> {
  final TryOnRepository _repository;
  final S3UploadUtil _uploadUtil;
  Timer? _pollTimer;

  TryOnBloc({
    required TryOnRepository repository,
    required S3UploadUtil uploadUtil,
  })  : _repository = repository,
        _uploadUtil = uploadUtil,
        super(const TryOnInitial()) {
    on<TryOnSelectPersonImage>(_onSelectPersonImage);
    on<TryOnSelectGarment>(_onSelectGarment);
    on<TryOnGenerate>(_onGenerate);
    on<TryOnPollStatus>(_onPollStatus);
    on<TryOnLoadHistory>(_onLoadHistory);
    on<TryOnReset>(_onReset);
  }

  Future<void> _onSelectPersonImage(
    TryOnSelectPersonImage event,
    Emitter<TryOnState> emit,
  ) async {
    String? s3Key = event.s3Key;

    // If no s3Key, upload the person image first
    if (s3Key == null) {
      try {
        final result = await _uploadUtil.uploadFile(
          fileBytes: event.imageBytes,
          fileName: event.fileName,
          uploadType: 'tryon_person',
        );
        s3Key = result.s3Key;
      } catch (e) {
        emit(TryOnError('Failed to upload photo: ${e.toString()}'));
        return;
      }
    }

    final currentState = state;
    if (currentState is TryOnReady) {
      emit(currentState.copyWith(
        personImageBytes: event.imageBytes,
        personImageS3Key: s3Key,
      ));
    } else {
      emit(TryOnReady(
        personImageBytes: event.imageBytes,
        personImageS3Key: s3Key,
      ));
    }
  }

  Future<void> _onSelectGarment(
    TryOnSelectGarment event,
    Emitter<TryOnState> emit,
  ) async {
    final currentState = state;
    if (currentState is TryOnReady) {
      emit(currentState.copyWith(
        garmentItemId: event.garmentItemId,
        garmentImageUrl: event.garmentImageUrl,
        garmentName: event.garmentName,
      ));
    } else {
      emit(TryOnReady(
        garmentItemId: event.garmentItemId,
        garmentImageUrl: event.garmentImageUrl,
        garmentName: event.garmentName,
      ));
    }
  }

  Future<void> _onGenerate(
    TryOnGenerate event,
    Emitter<TryOnState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TryOnReady || !currentState.canGenerate) return;

    try {
      final result = await _repository.submitTryOn(
        personImageS3: currentState.personImageS3Key!,
        garmentItemId: currentState.garmentItemId!,
      );

      emit(TryOnProcessing(
        tryOnId: result.id,
        progress: 0,
        step: 'Starting...',
      ));

      // Start polling for status
      _startPolling(result.id);
    } on ApiException catch (e) {
      emit(TryOnError(e.message));
    } catch (e) {
      emit(TryOnError('Failed to start try-on: ${e.toString()}'));
    }
  }

  void _startPolling(String tryOnId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      add(TryOnPollStatus(tryOnId));
    });
  }

  Future<void> _onPollStatus(
    TryOnPollStatus event,
    Emitter<TryOnState> emit,
  ) async {
    try {
      final result = await _repository.getTryOnResult(event.tryOnId);

      if (result.isCompleted && result.resultImageUrl != null) {
        _pollTimer?.cancel();
        final previousState = state;
        emit(TryOnCompleted(
          tryOnId: result.id,
          resultImageUrl: result.resultImageUrl!,
          personImageBytes: previousState is TryOnReady
              ? previousState.personImageBytes
              : null,
        ));
      } else if (result.isFailed) {
        _pollTimer?.cancel();
        emit(TryOnError(result.errorMessage ?? 'Try-on processing failed'));
      } else {
        // Still processing - update progress
        emit(TryOnProcessing(
          tryOnId: event.tryOnId,
          progress: 50, // Approximate since we're polling
          step: 'Processing...',
        ));
      }
    } catch (_) {
      // Silent retry on poll failure
    }
  }

  Future<void> _onLoadHistory(
    TryOnLoadHistory event,
    Emitter<TryOnState> emit,
  ) async {
    try {
      final history = await _repository.getTryOnHistory();
      final currentState = state;
      if (currentState is TryOnReady) {
        emit(currentState.copyWith(history: history));
      } else {
        emit(TryOnReady(history: history));
      }
    } catch (_) {
      // Silent fail for history load
    }
  }

  void _onReset(TryOnReset event, Emitter<TryOnState> emit) {
    _pollTimer?.cancel();
    emit(const TryOnReady());
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
