import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/remote/response/watchlist.dart';
import '../../../../portfolio/data/repositories/storage_repository.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final StorageRepository storageRepository;

  WatchlistBloc(this.storageRepository)
    : super(const WatchlistState(watchlists: [], selectedWatchlistId: '')) {
    on<LoadWatchlists>((event, emit) {
      final list = storageRepository.getWatchlists();
      final initialId = list.isNotEmpty ? list.first.id : '';
      emit(WatchlistState(watchlists: list, selectedWatchlistId: initialId));
    });

    on<SelectWatchlist>((event, emit) {
      emit(state.copyWith(selectedWatchlistId: event.id));
    });

    on<CreateWatchlist>((event, emit) async {
      final newWl = Watchlist(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        symbols: const [],
      );
      final updated = List<Watchlist>.from(state.watchlists)..add(newWl);
      await storageRepository.saveWatchlists(updated);
      emit(state.copyWith(watchlists: updated, selectedWatchlistId: newWl.id));
    });

    on<DeleteWatchlist>((event, emit) async {
      final updated = state.watchlists.where((w) => w.id != event.id).toList();
      await storageRepository.saveWatchlists(updated);
      final nextId = updated.isNotEmpty ? updated.first.id : '';
      emit(state.copyWith(watchlists: updated, selectedWatchlistId: nextId));
    });

    on<AddStockToWatchlist>((event, emit) async {
      final updated = state.watchlists.map((w) {
        if (w.id == event.watchlistId) {
          if (!w.symbols.contains(event.symbol)) {
            return w.copyWith(symbols: List.from(w.symbols)..add(event.symbol));
          }
        }
        return w;
      }).toList();
      await storageRepository.saveWatchlists(updated);
      emit(state.copyWith(watchlists: updated));
    });

    on<RemoveStockFromWatchlist>((event, emit) async {
      final updated = state.watchlists.map((w) {
        if (w.id == event.watchlistId) {
          return w.copyWith(
            symbols: w.symbols.where((s) => s != event.symbol).toList(),
          );
        }
        return w;
      }).toList();
      await storageRepository.saveWatchlists(updated);
      emit(state.copyWith(watchlists: updated));
    });

    on<ReorderStockInWatchlist>((event, emit) async {
      final updated = state.watchlists.map((w) {
        if (w.id == event.watchlistId) {
          final list = List<String>.from(w.symbols);
          var oldIdx = event.oldIndex;
          var newIdx = event.newIndex;
          if (newIdx > oldIdx) newIdx -= 1;
          final item = list.removeAt(oldIdx);
          list.insert(newIdx, item);
          return w.copyWith(symbols: list);
        }
        return w;
      }).toList();
      await storageRepository.saveWatchlists(updated);
      emit(state.copyWith(watchlists: updated));
    });
  }
}
