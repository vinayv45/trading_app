import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/market/data/remote/models/response/stock_ticker.dart';
import '../../features/market/presentation/blocs/market/market_bloc.dart';

class TickerTile extends StatefulWidget {
  final String symbol;
  final VoidCallback onTap;
  final Widget? trailingIcon;

  const TickerTile({
    super.key,
    required this.symbol,
    required this.onTap,
    this.trailingIcon,
  });

  @override
  State<TickerTile> createState() => _TickerTileState();
}

class _TickerTileState extends State<TickerTile> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MarketBloc, MarketState>(
      listenWhen: (prev, curr) =>
          curr.lastUpdatedSymbol == widget.symbol &&
          prev.tickers[widget.symbol] != curr.tickers[widget.symbol],
      listener: (context, state) {
        final ticker = state.tickers[widget.symbol];
        if (ticker != null) {}
      },
      child: BlocBuilder<MarketBloc, MarketState>(
        buildWhen: (prev, curr) =>
            prev.tickers[widget.symbol] != curr.tickers[widget.symbol],
        builder: (context, state) {
          final StockTicker stock = state.tickers[widget.symbol]!;
          final isPositive = stock.change >= 0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),

            child: ListTile(
              onTap: widget.onTap,
              title: Text(
                stock.symbol,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isPositive ? 'Bullish' : 'Bearish',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontSize: 11,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${stock.ltp.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${stock.change.toStringAsFixed(2)} (${stock.changePercent.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    widget.trailingIcon!,
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
