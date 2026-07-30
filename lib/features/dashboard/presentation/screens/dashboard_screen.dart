import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/dashboard/presentation/blocs/dashboard_bloc.dart';
import '../../../watchlist/presentation/screens/watchlist_screen.dart';
import '../../../market/presentation/screens/live_prices_screen.dart';
import '../../../portfolio/presentation/screens/holdings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final List<Widget> _screens = const [
    WatchlistScreen(),
    LivePricesScreen(),
    HoldingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(index: state.currentIndex, children: _screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: state.currentIndex,
            onTap: (index) {
              context.read<DashboardBloc>().add(
                CurrentDashboardScreenChangedEvent(currentIndex: index),
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark_outline),
                activeIcon: Icon(Icons.bookmark),
                label: 'Watchlists',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart),
                label: 'Live Markets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet),
                label: 'Holdings',
              ),
            ],
          ),
        );
      },
    );
  }
}
