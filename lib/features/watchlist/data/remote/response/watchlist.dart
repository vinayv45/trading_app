import 'dart:convert';
import 'package:equatable/equatable.dart';

class Watchlist extends Equatable {
  final String id;
  final String name;
  final List<String> symbols;

  const Watchlist({
    required this.id,
    required this.name,
    required this.symbols,
  });

  Watchlist copyWith({String? id, String? name, List<String>? symbols}) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      symbols: symbols ?? this.symbols,
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'symbols': symbols};

  factory Watchlist.fromMap(Map<String, dynamic> map) {
    return Watchlist(
      id: map['id'],
      name: map['name'],
      symbols: List<String>.from(map['symbols']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Watchlist.fromJson(String source) =>
      Watchlist.fromMap(json.decode(source));

  @override
  List<Object?> get props => [id, name, symbols];
}
