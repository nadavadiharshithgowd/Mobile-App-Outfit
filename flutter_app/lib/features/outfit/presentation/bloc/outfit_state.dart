import 'package:equatable/equatable.dart';
import '../../data/models/outfit_model.dart';

abstract class OutfitState extends Equatable {
  const OutfitState();

  @override
  List<Object?> get props => [];
}

class OutfitInitial extends OutfitState {
  const OutfitInitial();
}

class OutfitLoading extends OutfitState {
  const OutfitLoading();
}

class OutfitDailyLoaded extends OutfitState {
  final String date;
  final List<RecommendationModel> recommendations;
  final int currentIndex;

  const OutfitDailyLoaded({
    required this.date,
    required this.recommendations,
    this.currentIndex = 0,
  });

  @override
  List<Object?> get props => [date, recommendations, currentIndex];

  OutfitDailyLoaded copyWith({int? currentIndex}) {
    return OutfitDailyLoaded(
      date: date,
      recommendations: recommendations,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class OutfitHistoryLoaded extends OutfitState {
  final List<OutfitModel> outfits;

  const OutfitHistoryLoaded(this.outfits);

  @override
  List<Object?> get props => [outfits];
}

class OutfitEmpty extends OutfitState {
  const OutfitEmpty();
}

class OutfitError extends OutfitState {
  final String message;
  const OutfitError(this.message);

  @override
  List<Object?> get props => [message];
}
