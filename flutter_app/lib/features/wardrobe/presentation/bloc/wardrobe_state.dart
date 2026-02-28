import 'package:equatable/equatable.dart';
import '../../data/models/wardrobe_item_model.dart';

abstract class WardrobeState extends Equatable {
  const WardrobeState();

  @override
  List<Object?> get props => [];
}

class WardrobeInitial extends WardrobeState {
  const WardrobeInitial();
}

class WardrobeLoading extends WardrobeState {
  const WardrobeLoading();
}

class WardrobeLoaded extends WardrobeState {
  final List<WardrobeItemModel> items;
  final int totalCount;
  final bool hasMore;
  final String? activeCategory;
  final bool isLoadingMore;

  const WardrobeLoaded({
    required this.items,
    required this.totalCount,
    required this.hasMore,
    this.activeCategory,
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        items,
        totalCount,
        hasMore,
        activeCategory,
        isLoadingMore,
      ];

  WardrobeLoaded copyWith({
    List<WardrobeItemModel>? items,
    int? totalCount,
    bool? hasMore,
    String? activeCategory,
    bool? isLoadingMore,
  }) {
    return WardrobeLoaded(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      activeCategory: activeCategory ?? this.activeCategory,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class WardrobeError extends WardrobeState {
  final String message;
  const WardrobeError(this.message);

  @override
  List<Object?> get props => [message];
}
