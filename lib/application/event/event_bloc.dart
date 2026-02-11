import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

/// BLoC الأحداث — إدارة CRUD والبحث مع تجميع بالتواريخ
class EventBloc extends Bloc<EventBlocEvent, EventState> {
  final EventRepository _repository;

  // نحتفظ بالنطاق الحالي لإعادة التحميل بعد العمليات
  DateTime? _currentStart;
  DateTime? _currentEnd;

  EventBloc(this._repository) : super(EventInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<LoadEventsForDate>(_onLoadEventsForDate);
    on<AddEvent>(_onAddEvent);
    on<UpdateEvent>(_onUpdateEvent);
    on<DeleteEvent>(_onDeleteEvent);
    on<SearchEvents>(_onSearchEvents);
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      _currentStart = event.start;
      _currentEnd = event.end;
      final events = await _repository.getEventsForRange(
        event.start,
        event.end,
      );
      emit(EventLoaded(
        events: events,
        eventsByDate: _groupByDate(events),
      ));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onLoadEventsForDate(
    LoadEventsForDate event,
    Emitter<EventState> emit,
  ) async {
    emit(EventLoading());
    try {
      final events = await _repository.getEventsForDate(event.date);
      emit(EventLoaded(
        events: events,
        eventsByDate: _groupByDate(events),
      ));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onAddEvent(
    AddEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _repository.addEvent(event.event);
      emit(const EventOperationSuccess('تمت إضافة الحدث بنجاح'));
      await _reloadEvents(emit);
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _repository.updateEvent(event.event);
      emit(const EventOperationSuccess('تم تحديث الحدث بنجاح'));
      await _reloadEvents(emit);
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(
    DeleteEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      await _repository.deleteEvent(event.eventId);
      emit(const EventOperationSuccess('تم حذف الحدث بنجاح'));
      await _reloadEvents(emit);
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onSearchEvents(
    SearchEvents event,
    Emitter<EventState> emit,
  ) async {
    if (event.query.isEmpty) {
      await _reloadEvents(emit);
      return;
    }
    emit(EventLoading());
    try {
      final results = await _repository.searchEvents(event.query);
      emit(EventSearchResults(results: results, query: event.query));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  /// إعادة تحميل الأحداث للنطاق الحالي
  Future<void> _reloadEvents(Emitter<EventState> emit) async {
    if (_currentStart != null && _currentEnd != null) {
      final events = await _repository.getEventsForRange(
        _currentStart!,
        _currentEnd!,
      );
      emit(EventLoaded(
        events: events,
        eventsByDate: _groupByDate(events),
      ));
    } else {
      final events = await _repository.getAllEvents();
      emit(EventLoaded(
        events: events,
        eventsByDate: _groupByDate(events),
      ));
    }
  }

  /// تجميع الأحداث حسب التاريخ (لأداء أفضل عند الرسم)
  Map<String, List<dynamic>> _groupByDate(List<dynamic> events) {
    final map = <String, List<dynamic>>{};
    for (final event in events) {
      final key =
          '${event.startTime.year}-${event.startTime.month.toString().padLeft(2, '0')}-${event.startTime.day.toString().padLeft(2, '0')}';
      map.putIfAbsent(key, () => []).add(event);
    }
    return map;
  }
}
