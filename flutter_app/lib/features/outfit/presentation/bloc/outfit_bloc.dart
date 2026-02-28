import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/outfit_repository_impl.dart';
import 'outfit_event.dart';
import 'outfit_state.dart';

class OutfitBloc extends Bloc<OutfitEvent, OutfitState> {
  final OutfitRepository _repository;

  OutfitBloc({required OutfitRepository repository})
      : _repository = repository,
        super(const OutfitInitial()) {
    on<OutfitLoadDaily>(_onLoadDaily);
    on<OutfitGenerateNew>(_onGenerateNew);
    on<OutfitAccept>(_onAccept);
    on<OutfitReject>(_onReject);
    on<OutfitLoadHistory>(_onLoadHistory);
    on<OutfitToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadDaily(
    OutfitLoadDaily event,
    Emitter<OutfitState> emit,
  ) async {
    emit(const OutfitLoading());
    try {
      final response = await _repository.getDailyRecommendations();
      if (response.recommendations.isEmpty) {
        emit(const OutfitEmpty());
      } else {
        emit(OutfitDailyLoaded(
          date: response.date,
          recommendations: response.recommendations,
        ));
      }
    } on ApiException catch (e) {
      emit(OutfitError(e.message));
    } catch (_) {
      emit(const OutfitError('Failed to load recommendations'));
    }
  }

  Future<void> _onGenerateNew(
    OutfitGenerateNew event,
    Emitter<OutfitState> emit,
  ) async {
    emit(const OutfitLoading());
    try {
      await _repository.generateRecommendations();
      final response = await _repository.getDailyRecommendations();
      if (response.recommendations.isEmpty) {
        emit(const OutfitEmpty());
      } else {
        emit(OutfitDailyLoaded(
          date: response.date,
          recommendations: response.recommendations,
        ));
      }
    } on ApiException catch (e) {
      emit(OutfitError(e.message));
    } catch (_) {
      emit(const OutfitError('Failed to generate recommendations'));
    }
  }

  Future<void> _onAccept(
    OutfitAccept event,
    Emitter<OutfitState> emit,
  ) async {
    try {
      await _repository.acceptRecommendation(event.recommendationId);
    } catch (_) {
      // Silent fail, UI already shows acceptance
    }
  }

  Future<void> _onReject(
    OutfitReject event,
    Emitter<OutfitState> emit,
  ) async {
    try {
      await _repository.rejectRecommendation(event.recommendationId);
    } catch (_) {}
  }

  Future<void> _onLoadHistory(
    OutfitLoadHistory event,
    Emitter<OutfitState> emit,
  ) async {
    emit(const OutfitLoading());
    try {
      final outfits = await _repository.getOutfitHistory();
      emit(OutfitHistoryLoaded(outfits));
    } on ApiException catch (e) {
      emit(OutfitError(e.message));
    } catch (_) {
      emit(const OutfitError('Failed to load outfit history'));
    }
  }

  Future<void> _onToggleFavorite(
    OutfitToggleFavorite event,
    Emitter<OutfitState> emit,
  ) async {
    try {
      await _repository.toggleFavorite(event.outfitId);
    } catch (_) {}
  }
}
