import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/remote/models/response/stock_ticker.dart';
import '../../../data/repositories/market_repository.dart';

part 'market_event.dart';
part 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  final MarketRepository _marketRepository;
  StreamSubscription<StockTicker>? _subscription;

  MarketBloc(this._marketRepository)
    : super(MarketState(tickers: _marketRepository.currentPrices)) {
    on<MarketTickReceived>((event, emit) {
      final updatedMap = Map<String, StockTicker>.from(state.tickers);
      updatedMap[event.ticker.symbol] = event.ticker;
      emit(
        MarketState(
          tickers: updatedMap,
          lastUpdatedSymbol: event.ticker.symbol,
        ),
      );
    });

    on<ChangeFeedSpeed>((event, emit) {
      _marketRepository.setSpeed(event.intervalMs);
    });

    _subscription = _marketRepository.priceStream.listen((ticker) {
      add(MarketTickReceived(ticker));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
