part of 'portfolio_bloc.dart';

abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();
  @override
  List<Object?> get props => [];
}

class LoadPortfolio extends PortfolioEvent {}

class ExecuteOrderEvent extends PortfolioEvent {
  final String symbol;
  final int quantity;
  final double ltp;
  final bool isBuy;

  const ExecuteOrderEvent({
    required this.symbol,
    required this.quantity,
    required this.ltp,
    required this.isBuy,
  });

  @override
  List<Object?> get props => [symbol, quantity, ltp, isBuy];
}

enum PortfolioSort { pnl, symbol, value }

class ChangeSortType extends PortfolioEvent {
  final PortfolioSort sort;
  const ChangeSortType(this.sort);
  @override
  List<Object?> get props => [sort];
}
