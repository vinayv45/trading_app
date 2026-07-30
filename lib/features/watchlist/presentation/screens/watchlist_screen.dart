import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../market/data/repositories/market_repository.dart';
import '../blocs/watchlist/watchlist_bloc.dart';
import '../../../market/presentation/screens/trade_ticket_screen.dart';
import '../../../../core/widgets/ticker_tile.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateWatchlistDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state.watchlists.isEmpty) {
            return const Center(child: Text('No watchlists. Create one!'));
          }

          final activeWl = state.activeWatchlist;
          if (activeWl == null) return const SizedBox();

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.watchlists.length,
                  itemBuilder: (context, index) {
                    final wl = state.watchlists[index];
                    final isSelected = wl.id == state.selectedWatchlistId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(wl.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            context.read<WatchlistBloc>().add(
                              SelectWatchlist(wl.id),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${activeWl.symbols.length} Stocks',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Stock'),
                      onPressed: () =>
                          _showAddStockPicker(context, activeWl.id),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: activeWl.symbols.isEmpty
                    ? const Center(child: Text('This watchlist is empty.'))
                    : ReorderableListView.builder(
                        itemCount: activeWl.symbols.length,
                        onReorder: (oldIndex, newIndex) {
                          context.read<WatchlistBloc>().add(
                            ReorderStockInWatchlist(
                              activeWl.id,
                              oldIndex,
                              newIndex,
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          final symbol = activeWl.symbols[index];
                          return Dismissible(
                            key: ValueKey('${activeWl.id}_$symbol'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (_) {
                              context.read<WatchlistBloc>().add(
                                RemoveStockFromWatchlist(activeWl.id, symbol),
                              );
                            },
                            child: TickerTile(
                              key: ValueKey(symbol),
                              symbol: symbol,
                              trailingIcon: const Icon(
                                Icons.drag_handle,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TradeTicketScreen(symbol: symbol),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCreateWatchlistDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Watchlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Watchlist Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<WatchlistBloc>().add(
                  CreateWatchlist(controller.text.trim()),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddStockPicker(BuildContext context, String watchlistId) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Stock to Watchlist',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: MarketRepository.availableStocks.length,
                itemBuilder: (context, index) {
                  final symbol = MarketRepository.availableStocks[index];
                  return ListTile(
                    title: Text(symbol),
                    trailing: const Icon(Icons.add_circle_outline),
                    onTap: () {
                      context.read<WatchlistBloc>().add(
                        AddStockToWatchlist(watchlistId, symbol),
                      );
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
