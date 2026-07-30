part of 'market_bloc.dart';

class MarketState extends Equatable {
  final Map<String, StockTicker> tickers;
  final String? lastUpdatedSymbol;

  const MarketState({required this.tickers, this.lastUpdatedSymbol});

  MarketState copyWith({
    Map<String, StockTicker>? tickers,
    String? lastUpdatedSymbol,
  }) {
    return MarketState(
      tickers: tickers ?? this.tickers,
      lastUpdatedSymbol: lastUpdatedSymbol ?? this.lastUpdatedSymbol,
    );
  }

  @override
  List<Object?> get props => [tickers, lastUpdatedSymbol];
}
