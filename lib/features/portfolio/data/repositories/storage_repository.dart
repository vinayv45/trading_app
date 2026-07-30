import 'package:shared_preferences/shared_preferences.dart';
import '../../../watchlist/data/remote/response/watchlist.dart';
import '../remote/models/response/holding.dart';

class StorageRepository {
  static const _keyWatchlists = 'key_watchlists_v1';
  static const _keyHoldings = 'key_holdings_v1';
  static const _keyBalance = 'key_balance_v1';

  final SharedPreferences prefs;

  StorageRepository(this.prefs);

  double getBalance() {
    return prefs.getDouble(_keyBalance) ?? 100000.0;
  }

  Future<void> saveBalance(double balance) async {
    await prefs.setDouble(_keyBalance, balance);
  }

  List<Watchlist> getWatchlists() {
    final rawList = prefs.getStringList(_keyWatchlists);
    if (rawList == null || rawList.isEmpty) {
      return [
        const Watchlist(
          id: '1',
          name: 'Main Watchlist',
          symbols: ['RELIANCE', 'TCS', 'INFY', 'HDFCBANK'],
        ),
      ];
    }
    return rawList.map((e) => Watchlist.fromJson(e)).toList();
  }

  Future<void> saveWatchlists(List<Watchlist> watchlists) async {
    final rawList = watchlists.map((w) => w.toJson()).toList();
    await prefs.setStringList(_keyWatchlists, rawList);
  }

  List<Holding> getHoldings() {
    final rawList = prefs.getStringList(_keyHoldings);
    if (rawList == null) return [];
    return rawList.map((e) => Holding.fromJson(e)).toList();
  }

  Future<void> saveHoldings(List<Holding> holdings) async {
    final rawList = holdings.map((h) => h.toJson()).toList();
    await prefs.setStringList(_keyHoldings, rawList);
  }
}
