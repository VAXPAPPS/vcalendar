import 'package:flutter_bloc/flutter_bloc.dart';
import 'calendar_event.dart';
import 'calendar_state.dart';

/// BLoC التقويم — يدير التنقل بين التواريخ وتبديل العروض
class CalendarBloc extends Bloc<CalendarBlocEvent, CalendarState> {
  CalendarBloc() : super(CalendarState.initial()) {
    on<NavigateNext>(_onNavigateNext);
    on<NavigatePrevious>(_onNavigatePrevious);
    on<NavigateToDate>(_onNavigateToDate);
    on<NavigateToToday>(_onNavigateToToday);
    on<ChangeViewType>(_onChangeViewType);
    on<SelectDate>(_onSelectDate);
  }

  void _onNavigateNext(NavigateNext event, Emitter<CalendarState> emit) {
    DateTime newDate;
    switch (state.viewType) {
      case CalendarViewType.monthly:
        newDate = DateTime(
          state.focusedDate.year,
          state.focusedDate.month + 1,
          1,
        );
        break;
      case CalendarViewType.weekly:
        newDate = state.focusedDate.add(const Duration(days: 7));
        break;
      case CalendarViewType.daily:
        newDate = state.focusedDate.add(const Duration(days: 1));
        break;
    }
    _emitNewDate(emit, newDate);
  }

  void _onNavigatePrevious(
    NavigatePrevious event,
    Emitter<CalendarState> emit,
  ) {
    DateTime newDate;
    switch (state.viewType) {
      case CalendarViewType.monthly:
        newDate = DateTime(
          state.focusedDate.year,
          state.focusedDate.month - 1,
          1,
        );
        break;
      case CalendarViewType.weekly:
        newDate = state.focusedDate.subtract(const Duration(days: 7));
        break;
      case CalendarViewType.daily:
        newDate = state.focusedDate.subtract(const Duration(days: 1));
        break;
    }
    _emitNewDate(emit, newDate);
  }

  void _onNavigateToDate(NavigateToDate event, Emitter<CalendarState> emit) {
    _emitNewDate(emit, event.date);
  }

  void _onNavigateToToday(
    NavigateToToday event,
    Emitter<CalendarState> emit,
  ) {
    _emitNewDate(emit, DateTime.now());
  }

  void _onChangeViewType(ChangeViewType event, Emitter<CalendarState> emit) {
    emit(state.copyWith(viewType: event.viewType));
    _emitNewDate(emit, state.focusedDate, viewType: event.viewType);
  }

  void _onSelectDate(SelectDate event, Emitter<CalendarState> emit) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _emitNewDate(
    Emitter<CalendarState> emit,
    DateTime date, {
    CalendarViewType? viewType,
  }) {
    final type = viewType ?? state.viewType;
    List<DateTime> visibleDays;

    switch (type) {
      case CalendarViewType.monthly:
        visibleDays = CalendarState.generateMonthDays(date);
        break;
      case CalendarViewType.weekly:
        visibleDays = CalendarState.generateWeekDays(date);
        break;
      case CalendarViewType.daily:
        visibleDays = [DateTime(date.year, date.month, date.day)];
        break;
    }

    emit(
      state.copyWith(
        focusedDate: date,
        visibleDays: visibleDays,
        viewType: type,
      ),
    );
  }
}
