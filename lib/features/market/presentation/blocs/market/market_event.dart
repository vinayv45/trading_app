part of 'market_bloc.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();
  @override
  List<Object?> get props => [];
}

class MarketTickReceived extends MarketEvent {
  final StockTicker ticker;
  const MarketTickReceived(this.ticker);
  @override
  List<Object?> get props => [ticker];
}

class ChangeFeedSpeed extends MarketEvent {
  final int intervalMs;
  const ChangeFeedSpeed(this.intervalMs);
  @override
  List<Object?> get props => [intervalMs];
}
