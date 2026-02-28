import 'package:equatable/equatable.dart';

abstract class WardrobeEvent extends Equatable {
  const WardrobeEvent();

  @override
  List<Object?> get props => [];
}

class WardrobeLoadItems extends WardrobeEvent {
  final String? category;
  final bool refresh;

  const WardrobeLoadItems({this.category, this.refresh = false});

  @override
  List<Object?> get props => [category, refresh];
}

class WardrobeLoadMore extends WardrobeEvent {
  const WardrobeLoadMore();
}

class WardrobeFilterCategory extends WardrobeEvent {
  final String? category;
  const WardrobeFilterCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class WardrobeDeleteItem extends WardrobeEvent {
  final String itemId;
  const WardrobeDeleteItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class WardrobeUpdateItem extends WardrobeEvent {
  final String itemId;
  final Map<String, dynamic> data;
  const WardrobeUpdateItem({required this.itemId, required this.data});

  @override
  List<Object?> get props => [itemId, data];
}
