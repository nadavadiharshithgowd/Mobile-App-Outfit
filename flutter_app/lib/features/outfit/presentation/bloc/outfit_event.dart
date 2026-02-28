import 'package:equatable/equatable.dart';

abstract class OutfitEvent extends Equatable {
  const OutfitEvent();

  @override
  List<Object?> get props => [];
}

class OutfitLoadDaily extends OutfitEvent {
  const OutfitLoadDaily();
}

class OutfitGenerateNew extends OutfitEvent {
  const OutfitGenerateNew();
}

class OutfitAccept extends OutfitEvent {
  final String recommendationId;
  const OutfitAccept(this.recommendationId);

  @override
  List<Object?> get props => [recommendationId];
}

class OutfitReject extends OutfitEvent {
  final String recommendationId;
  const OutfitReject(this.recommendationId);

  @override
  List<Object?> get props => [recommendationId];
}

class OutfitLoadHistory extends OutfitEvent {
  const OutfitLoadHistory();
}

class OutfitToggleFavorite extends OutfitEvent {
  final String outfitId;
  const OutfitToggleFavorite(this.outfitId);

  @override
  List<Object?> get props => [outfitId];
}
