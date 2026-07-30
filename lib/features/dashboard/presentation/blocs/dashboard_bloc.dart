import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'dashboard_event.dart';
part './dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardState()) {
    _onRegisterEvents();
  }

  void _onRegisterEvents() {
    on<CurrentDashboardScreenChangedEvent>(
      _handleCurrentDashboardScreenChangedEvent,
    );
  }

  FutureOr<void> _handleCurrentDashboardScreenChangedEvent(
    CurrentDashboardScreenChangedEvent event,
    Emitter<DashboardState> emit,
  ) {
    emit(state.copyWith(currentIndex: event.currentIndex));
  }
}
