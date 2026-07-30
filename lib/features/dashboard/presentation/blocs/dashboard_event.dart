part of './dashboard_bloc.dart';

abstract class DashboardEvent {}

class CurrentDashboardScreenChangedEvent extends DashboardEvent {
  final int currentIndex;
  CurrentDashboardScreenChangedEvent({required this.currentIndex});
}
