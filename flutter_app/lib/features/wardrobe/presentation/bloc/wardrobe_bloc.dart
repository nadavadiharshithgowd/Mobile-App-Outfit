import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../data/repositories/wardrobe_repository_impl.dart';
import 'wardrobe_event.dart';
import 'wardrobe_state.dart';

class WardrobeBloc extends Bloc<WardrobeEvent, WardrobeState> {
  final WardrobeRepository _repository;
  int _currentPage = 1;
  static const _pageSize = 20;

  WardrobeBloc({required WardrobeRepository repository})
      : _repository = repository,
        super(const WardrobeInitial()) {
    on<WardrobeLoadItems>(_onLoadItems);
    on<WardrobeLoadMore>(_onLoadMore);
    on<WardrobeFilterCategory>(_onFilterCategory);
    on<WardrobeDeleteItem>(_onDeleteItem);
    on<WardrobeUpdateItem>(_onUpdateItem);
  }

  Future<void> _onLoadItems(
    WardrobeLoadItems event,
    Emitter<WardrobeState> emit,
  ) async {
    if (event.refresh) {
      _currentPage = 1;
    } else {
      emit(const WardrobeLoading());
    }

    try {
      final response = await _repository.getItems(
        category: event.category,
        page: 1,
        pageSize: _pageSize,
      );
      _currentPage = 1;

      emit(WardrobeLoaded(
        items: response.results,
        totalCount: response.count,
        hasMore: response.hasMore,
        activeCategory: event.category,
      ));
    } on ApiException catch (e) {
      emit(WardrobeError(e.message));
    } catch (_) {
      emit(const WardrobeError('Failed to load wardrobe'));
    }
  }

  Future<void> _onLoadMore(
    WardrobeLoadMore event,
    Emitter<WardrobeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WardrobeLoaded || !currentState.hasMore) return;
    if (currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      _currentPage++;
      final response = await _repository.getItems(
        category: currentState.activeCategory,
        page: _currentPage,
        pageSize: _pageSize,
      );

      emit(WardrobeLoaded(
        items: [...currentState.items, ...response.results],
        totalCount: response.count,
        hasMore: response.hasMore,
        activeCategory: currentState.activeCategory,
      ));
    } on ApiException catch (_) {
      _currentPage--;
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onFilterCategory(
    WardrobeFilterCategory event,
    Emitter<WardrobeState> emit,
  ) async {
    add(WardrobeLoadItems(category: event.category));
  }

  Future<void> _onDeleteItem(
    WardrobeDeleteItem event,
    Emitter<WardrobeState> emit,
  ) async {
    try {
      await _repository.deleteItem(event.itemId);
      final currentState = state;
      if (currentState is WardrobeLoaded) {
        final updatedItems =
            currentState.items.where((i) => i.id != event.itemId).toList();
        emit(currentState.copyWith(
          items: updatedItems,
          totalCount: currentState.totalCount - 1,
        ));
      }
    } on ApiException catch (_) {
      // Keep current state, show error via snackbar
    }
  }

  Future<void> _onUpdateItem(
    WardrobeUpdateItem event,
    Emitter<WardrobeState> emit,
  ) async {
    try {
      final updated = await _repository.updateItem(event.itemId, event.data);
      final currentState = state;
      if (currentState is WardrobeLoaded) {
        final updatedItems = currentState.items.map((item) {
          return item.id == event.itemId ? updated : item;
        }).toList();
        emit(currentState.copyWith(items: updatedItems));
      }
    } on ApiException catch (_) {
      // Keep current state
    }
  }
}
