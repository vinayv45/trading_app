part of './dashboard_bloc.dart';

class DashboardState extends Equatable {
  final int currentIndex;

  const DashboardState({this.currentIndex = 0});

  @override
  List<Object?> get props => [currentIndex];

  DashboardState copyWith({int? currentIndex}) {
    return DashboardState(currentIndex: currentIndex ?? this.currentIndex);
  }
}
