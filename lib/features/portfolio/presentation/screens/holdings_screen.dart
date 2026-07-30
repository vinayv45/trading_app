import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/remote/models/response/holding.dart';
import '../../../market/presentation/blocs/market/market_bloc.dart';
import '../blocs/portfolio/portfolio_bloc.dart';
import '../../../market/presentation/screens/trade_ticket_screen.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio & Holdings'),
        actions: [
          PopupMenuButton<PortfolioSort>(
            icon: const Icon(Icons.sort),
            onSelected: (sort) {
              context.read<PortfolioBloc>().add(ChangeSortType(sort));
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: PortfolioSort.pnl,
                child: Text('Sort by P&L'),
              ),
              PopupMenuItem(
                value: PortfolioSort.symbol,
                child: Text('Sort by Symbol'),
              ),
              PopupMenuItem(
                value: PortfolioSort.value,
                child: Text('Sort by Value'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<PortfolioBloc, PortfolioState>(
        builder: (context, portfolioState) {
          return BlocBuilder<MarketBloc, MarketState>(
            builder: (context, marketState) {
              final holdings = List<Holding>.from(portfolioState.holdings);

              if (holdings.isEmpty) {
                return const Center(
                  child: Text('No active holdings. Buy stocks to get started!'),
                );
              }

              double totalInvested = 0.0;
              double totalCurrentVal = 0.0;

              for (var h in holdings) {
                final ltp = marketState.tickers[h.symbol]?.ltp ?? h.avgPrice;
                totalInvested += h.totalCost;
                totalCurrentVal += (h.quantity * ltp);
              }

              final totalPnl = totalCurrentVal - totalInvested;
              final totalPnlPercent = totalInvested > 0
                  ? (totalPnl / totalInvested) * 100
                  : 0.0;

              holdings.sort((a, b) {
                final ltpA = marketState.tickers[a.symbol]?.ltp ?? a.avgPrice;
                final ltpB = marketState.tickers[b.symbol]?.ltp ?? b.avgPrice;

                if (portfolioState.sort == PortfolioSort.pnl) {
                  final pnlA = (a.quantity * ltpA) - a.totalCost;
                  final pnlB = (b.quantity * ltpB) - b.totalCost;
                  return pnlB.compareTo(pnlA);
                } else if (portfolioState.sort == PortfolioSort.value) {
                  return (b.quantity * ltpB).compareTo(a.quantity * ltpA);
                } else {
                  return a.symbol.compareTo(b.symbol);
                }
              });

              return Column(
                children: [
                  Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Invested',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalInvested.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Current Value',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '₹${totalCurrentVal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total P&L',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${totalPnl >= 0 ? '+' : ''}₹${totalPnl.toStringAsFixed(2)} (${totalPnlPercent.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: totalPnl >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemCount: holdings.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final holding = holdings[index];
                        final ltp =
                            marketState.tickers[holding.symbol]?.ltp ??
                            holding.avgPrice;
                        final currentVal = holding.quantity * ltp;
                        final pnl = currentVal - holding.totalCost;
                        final pnlPct = holding.totalCost > 0
                            ? (pnl / holding.totalCost) * 100
                            : 0.0;

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TradeTicketScreen(symbol: holding.symbol),
                              ),
                            );
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                holding.symbol,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('₹${ltp.toStringAsFixed(2)}'),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Qty: ${holding.quantity} • Avg: ₹${holding.avgPrice.toStringAsFixed(2)}',
                              ),
                              Text(
                                '${pnl >= 0 ? '+' : ''}₹${pnl.toStringAsFixed(2)} (${pnlPct.toStringAsFixed(2)}%)',
                                style: TextStyle(
                                  color: pnl >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
