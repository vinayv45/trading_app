part of 'watchlist_bloc.dart';

class WatchlistState extends Equatable {
  final List<Watchlist> watchlists;
  final String selectedWatchlistId;

  const WatchlistState({
    required this.watchlists,
    required this.selectedWatchlistId,
  });

  Watchlist? get activeWatchlist {
    if (watchlists.isEmpty) return null;
    return watchlists.firstWhere(
      (w) => w.id == selectedWatchlistId,
      orElse: () => watchlists.first,
    );
  }

  WatchlistState copyWith({
    List<Watchlist>? watchlists,
    String? selectedWatchlistId,
  }) {
    return WatchlistState(
      watchlists: watchlists ?? this.watchlists,
      selectedWatchlistId: selectedWatchlistId ?? this.selectedWatchlistId,
    );
  }

  @override
  List<Object?> get props => [watchlists, selectedWatchlistId];
}
