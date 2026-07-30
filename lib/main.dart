import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/features/dashboard/presentation/blocs/dashboard_bloc.dart';

import 'features/market/data/repositories/market_repository.dart';
import 'features/portfolio/data/repositories/storage_repository.dart';
import 'features/market/presentation/blocs/market/market_bloc.dart';
import 'features/portfolio/presentation/blocs/portfolio/portfolio_bloc.dart';
import 'features/watchlist/presentation/blocs/watchlist/watchlist_bloc.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final storageRepository = StorageRepository(prefs);
  final marketRepository = MarketRepository();

  runApp(
    MyApp(
      storageRepository: storageRepository,
      marketRepository: marketRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final StorageRepository storageRepository;
  final MarketRepository marketRepository;

  const MyApp({
    super.key,
    required this.storageRepository,
    required this.marketRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: storageRepository),
        RepositoryProvider.value(value: marketRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => MarketBloc(marketRepository)),
          BlocProvider(
            create: (_) =>
                WatchlistBloc(storageRepository)..add(LoadWatchlists()),
          ),
          BlocProvider(
            create: (_) =>
                PortfolioBloc(storageRepository)..add(LoadPortfolio()),
          ),
          BlocProvider(create: (_) => DashboardBloc()),
        ],
        child: MaterialApp(
          title: '021 Trading App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Colors.blueAccent,
              unselectedItemColor: Colors.grey,
            ),
          ),
          home: const DashboardScreen(),
        ),
      ),
    );
  }
}
