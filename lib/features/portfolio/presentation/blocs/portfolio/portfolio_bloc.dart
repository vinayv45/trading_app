import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/portfolio/data/repositories/storage_repository.dart' show StorageRepository;

import '../../../data/remote/models/response/holding.dart';

part 'portfolio_event.dart';
part 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final StorageRepository storageRepository;

  PortfolioBloc(this.storageRepository)
    : super(const PortfolioState(balance: 100000.0, holdings: [])) {
    on<LoadPortfolio>((event, emit) {
      final bal = storageRepository.getBalance();
      final h = storageRepository.getHoldings();
      emit(PortfolioState(balance: bal, holdings: h));
    });

    on<ChangeSortType>((event, emit) {
      emit(state.copyWith(sort: event.sort));
    });

    on<ExecuteOrderEvent>((event, emit) async {
      final currentHoldings = List<Holding>.from(state.holdings);
      double newBalance = state.balance;
      final totalTransactionVal = event.quantity * event.ltp;

      final existingIndex = currentHoldings.indexWhere(
        (h) => h.symbol == event.symbol,
      );

      if (event.isBuy) {
        newBalance -= totalTransactionVal;
        if (existingIndex >= 0) {
          final existing = currentHoldings[existingIndex];
          currentHoldings[existingIndex] = existing.copyWith(
            quantity: existing.quantity + event.quantity,
            totalCost: existing.totalCost + totalTransactionVal,
          );
        } else {
          currentHoldings.add(
            Holding(
              symbol: event.symbol,
              quantity: event.quantity,
              totalCost: totalTransactionVal,
            ),
          );
        }
      } else {
        // Sell
        newBalance += totalTransactionVal;
        if (existingIndex >= 0) {
          final existing = currentHoldings[existingIndex];
          final remainingQty = existing.quantity - event.quantity;
          if (remainingQty <= 0) {
            currentHoldings.removeAt(existingIndex);
          } else {
            // Keep existing average cost per share
            final avgCost = existing.avgPrice;
            currentHoldings[existingIndex] = existing.copyWith(
              quantity: remainingQty,
              totalCost: remainingQty * avgCost,
            );
          }
        }
      }

      await storageRepository.saveBalance(newBalance);
      await storageRepository.saveHoldings(currentHoldings);

      emit(state.copyWith(balance: newBalance, holdings: currentHoldings));
    });
  }
}
