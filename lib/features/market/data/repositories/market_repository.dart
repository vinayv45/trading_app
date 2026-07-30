import 'dart:async';
import 'dart:math';
import '../remote/models/response/stock_ticker.dart';

class MarketRepository {
  static const List<String> availableStocks = [
    'RELIANCE',
    'TCS',
    'INFY',
    'HDFCBANK',
    'ICICIBANK',
    'SBIN',
    'ITC',
    'LT',
    'BHARTIARTL',
    'AXISBANK',
  ];

  final Map<String, double> _basePrices = {
    'RELIANCE': 2950.00,
    'TCS': 3880.00,
    'INFY': 1520.00,
    'HDFCBANK': 1440.00,
    'ICICIBANK': 1080.00,
    'SBIN': 740.00,
    'ITC': 430.00,
    'LT': 3620.00,
    'BHARTIARTL': 1210.00,
    'AXISBANK': 1050.00,
  };

  final Map<String, StockTicker> _currentTickers = {};
  final StreamController<StockTicker> _tickerStreamController =
      StreamController<StockTicker>.broadcast();

  Timer? _timer;
  int _intervalMs = 200;

  MarketRepository() {
    for (var symbol in availableStocks) {
      final base = _basePrices[symbol]!;
      _currentTickers[symbol] = StockTicker(
        symbol: symbol,
        ltp: base,
        change: 0.0,
        changePercent: 0.0,
        isUp: true,
      );
    }
    startFeed();
  }

  Stream<StockTicker> get priceStream => _tickerStreamController.stream;
  Map<String, StockTicker> get currentPrices =>
      Map.unmodifiable(_currentTickers);

  void startFeed({int intervalMs = 200}) {
    _intervalMs = intervalMs;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _intervalMs), (_) {
      _emitRandomTick();
    });
  }

  void setSpeed(int intervalMs) {
    startFeed(intervalMs: intervalMs);
  }

  void _emitRandomTick() {
    final random = Random();

    final count = random.nextInt(3) + 1;
    for (int i = 0; i < count; i++) {
      final symbol = availableStocks[random.nextInt(availableStocks.length)];
      final current = _currentTickers[symbol]!;

      final deltaPercent = (random.nextDouble() * 1.2 - 0.6) / 100.0;
      final delta = current.ltp * deltaPercent;
      final newLtp = double.parse((current.ltp + delta).toStringAsFixed(2));

      final base = _basePrices[symbol]!;
      final totalChange = double.parse((newLtp - base).toStringAsFixed(2));
      final totalChangePercent = double.parse(
        ((totalChange / base) * 100).toStringAsFixed(2),
      );

      final updated = StockTicker(
        symbol: symbol,
        ltp: newLtp,
        change: totalChange,
        changePercent: totalChangePercent,
        isUp: newLtp >= current.ltp,
      );

      _currentTickers[symbol] = updated;
      _tickerStreamController.add(updated);
    }
  }

  void dispose() {
    _timer?.cancel();
    _tickerStreamController.close();
  }
}
