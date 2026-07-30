part of 'portfolio_bloc.dart';

class PortfolioState extends Equatable {
  final double balance;
  final List<Holding> holdings;
  final PortfolioSort sort;

  const PortfolioState({
    required this.balance,
    required this.holdings,
    this.sort = PortfolioSort.pnl,
  });

  PortfolioState copyWith({
    double? balance,
    List<Holding>? holdings,
    PortfolioSort? sort,
  }) {
    return PortfolioState(
      balance: balance ?? this.balance,
      holdings: holdings ?? this.holdings,
      sort: sort ?? this.sort,
    );
  }

  @override
  List<Object?> get props => [balance, holdings, sort];
}
