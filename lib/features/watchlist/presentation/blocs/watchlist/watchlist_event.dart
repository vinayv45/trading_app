part of 'watchlist_bloc.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();
  @override
  List<Object?> get props => [];
}

class LoadWatchlists extends WatchlistEvent {}

class CreateWatchlist extends WatchlistEvent {
  final String name;
  const CreateWatchlist(this.name);
  @override
  List<Object?> get props => [name];
}

class DeleteWatchlist extends WatchlistEvent {
  final String id;
  const DeleteWatchlist(this.id);
  @override
  List<Object?> get props => [id];
}

class AddStockToWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String symbol;
  const AddStockToWatchlist(this.watchlistId, this.symbol);
  @override
  List<Object?> get props => [watchlistId, symbol];
}

class RemoveStockFromWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String symbol;
  const RemoveStockFromWatchlist(this.watchlistId, this.symbol);
  @override
  List<Object?> get props => [watchlistId, symbol];
}

class ReorderStockInWatchlist extends WatchlistEvent {
  final String watchlistId;
  final int oldIndex;
  final int newIndex;
  const ReorderStockInWatchlist(this.watchlistId, this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [watchlistId, oldIndex, newIndex];
}

class SelectWatchlist extends WatchlistEvent {
  final String id;
  const SelectWatchlist(this.id);

  @override
  List<Object?> get props => [id];
}
