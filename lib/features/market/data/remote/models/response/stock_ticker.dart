import 'package:equatable/equatable.dart';

class StockTicker extends Equatable {
  final String symbol;
  final double ltp;
  final double change;
  final double changePercent;
  final bool isUp;

  const StockTicker({
    required this.symbol,
    required this.ltp,
    required this.change,
    required this.changePercent,
    required this.isUp,
  });

  StockTicker copyWith({
    String? symbol,
    double? ltp,
    double? change,
    double? changePercent,
    bool? isUp,
  }) {
    return StockTicker(
      symbol: symbol ?? this.symbol,
      ltp: ltp ?? this.ltp,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      isUp: isUp ?? this.isUp,
    );
  }

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'ltp': ltp,
    'change': change,
    'changePercent': changePercent,
    'isUp': isUp,
  };

  factory StockTicker.fromJson(Map<String, dynamic> json) {
    return StockTicker(
      symbol: json['symbol'],
      ltp: (json['ltp'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
      changePercent: (json['changePercent'] as num).toDouble(),
      isUp: json['isUp'] ?? true,
    );
  }

  

  @override
  List<Object?> get props => [symbol, ltp, change, changePercent, isUp];
}
