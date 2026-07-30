import 'dart:convert';
import 'package:equatable/equatable.dart';

class Holding extends Equatable {
  final String symbol;
  final int quantity;
  final double totalCost;

  const Holding({
    required this.symbol,
    required this.quantity,
    required this.totalCost,
  });

  double get avgPrice => quantity > 0 ? totalCost / quantity : 0.0;

  Holding copyWith({String? symbol, int? quantity, double? totalCost}) {
    return Holding(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      totalCost: totalCost ?? this.totalCost,
    );
  }

  Map<String, dynamic> toMap() => {
    'symbol': symbol,
    'quantity': quantity,
    'totalCost': totalCost,
  };

  factory Holding.fromMap(Map<String, dynamic> map) {
    return Holding(
      symbol: map['symbol'],
      quantity: map['quantity'],
      totalCost: (map['totalCost'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Holding.fromJson(String source) =>
      Holding.fromMap(json.decode(source));

  @override
  List<Object?> get props => [symbol, quantity, totalCost];
}
