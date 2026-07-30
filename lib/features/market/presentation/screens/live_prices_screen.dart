import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/market_repository.dart';
import '../blocs/market/market_bloc.dart';
import 'trade_ticket_screen.dart';
import '../../../../core/widgets/ticker_tile.dart';

class LivePricesScreen extends StatefulWidget {
  const LivePricesScreen({super.key});

  @override
  State<LivePricesScreen> createState() => _LivePricesScreenState();
}

class _LivePricesScreenState extends State<LivePricesScreen> {
  int _selectedSpeedMs = 200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Market Feed'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.speed),
            tooltip: 'Configurable Tick Rate',
            onSelected: (ms) {
              setState(() => _selectedSpeedMs = ms);
              context.read<MarketBloc>().add(ChangeFeedSpeed(ms));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 500,
                child: Text('Normal (2 ticks/sec)'),
              ),
              const PopupMenuItem(
                value: 200,
                child: Text('Fast (5 ticks/sec)'),
              ),
              const PopupMenuItem(
                value: 20,
                child: Text('Stress Test (50+ ticks/sec)'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.bolt, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Feed Speed: ${_selectedSpeedMs}ms / tick cycle',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: MarketRepository.availableStocks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final symbol = MarketRepository.availableStocks[index];
                return TickerTile(
                  key: ValueKey('live_$symbol'),
                  symbol: symbol,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TradeTicketScreen(symbol: symbol),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
