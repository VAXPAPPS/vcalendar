import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '/../../application/calendar/calendar_bloc.dart';
import '/../../application/calendar/calendar_event.dart';
import '/../../application/calendar/calendar_state.dart';
import '/../../application/category/category_bloc.dart';
import '/../../application/event/event_bloc.dart';
import '/../../application/event/event_event.dart';
import '/../../application/event/event_state.dart';
import '/../../domain/entities/calendar_event.dart';
import './../../helpers/date_utils.dart';
import '../../helpers/color_utils.dart';
import '../event/event_dialog.dart';

/// العرض الشهري — شبكة 7×6 مع الأحداث
class MonthlyView extends StatelessWidget {
  const MonthlyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      buildWhen: (prev, curr) =>
          prev.visibleDays != curr.visibleDays ||
          prev.selectedDate != curr.selectedDate,
      builder: (context, calendarState) {
        return BlocBuilder<EventBloc, EventState>(
          buildWhen: (prev, curr) => curr is EventLoaded,
          builder: (context, eventState) {
            final eventsByDate = eventState is EventLoaded
                ? eventState.eventsByDate
                : {};

            return Column(
              children: [
                // رأس أيام الأسبوع
                const _WeekDayHeader(),
                const SizedBox(height: 4),
                // شبكة الأيام
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                    itemCount: calendarState.visibleDays.length,
                    itemBuilder: (context, index) {
                      final day = calendarState.visibleDays[index];
                      final key = CalendarDateUtils.dateKey(day);
                      final dayEvents =
                          (eventsByDate[key] as List<CalendarEvent>?) ?? [];
                      final isCurrentMonth = CalendarDateUtils.isCurrentMonth(
                        day,
                        calendarState.focusedDate,
                      );
                      final isToday = CalendarDateUtils.isToday(day);
                      final isSelected = CalendarDateUtils.isSameDay(
                        day,
                        calendarState.selectedDate,
                      );

                      return _DayCell(
                        day: day,
                        events: dayEvents,
                        isCurrentMonth: isCurrentMonth,
                        isToday: isToday,
                        isSelected: isSelected,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// رأس أيام الأسبوع
class _WeekDayHeader extends StatelessWidget {
  const _WeekDayHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: CalendarDateUtils.weekDayNames.map((name) {
          return Expanded(
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// خلية اليوم الواحد
class _DayCell extends StatelessWidget {
  final DateTime day;
  final List<CalendarEvent> events;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;

  const _DayCell({
    required this.day,
    required this.events,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<CalendarBloc>().add(SelectDate(day));
      },
      onDoubleTap: () {
        _showAddEventDialog(context, day);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? Colors.white.withValues(alpha: 0.12)
              : isToday
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.transparent,
          border: isToday
              ? Border.all(color: const Color(0xFF4A90D9), width: 1.5)
              : isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رقم اليوم
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday
                        ? const Color(0xFF4A90D9)
                        : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
                        color: isToday
                            ? Colors.white
                            : isCurrentMonth
                            ? Colors.white.withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                ),
              ),
              // أحداث اليوم
              if (events.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxRows = (constraints.maxHeight / 20)
                            .floor()
                            .clamp(1, 3);
                        final hasMore = events.length > maxRows;
                        final visibleCount = hasMore
                            ? (maxRows - 1).clamp(1, maxRows)
                            : maxRows;
                        final visibleEvents = events.take(visibleCount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...visibleEvents.map(
                              (event) => _MonthEventChip(event: event),
                            ),
                            if (hasMore)
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: Text(
                                  '+${events.length - visibleCount} more',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (_) => _QuickAddEventDialog(date: date),
    ).then((event) {
      if (event != null && context.mounted) {
        context.read<EventBloc>().add(AddEvent(event));
      }
    });
  }
}

/// شريحة مصغرة تعرض اسم الحدث داخل العرض الشهري
class _MonthEventChip extends StatelessWidget {
  final CalendarEvent event;

  const _MonthEventChip({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromValue(event.colorValue);
    final label = event.isAllDay
        ? event.title
        : '${CalendarDateUtils.formatTime(event.startTime)} ${event.title}';

    return Tooltip(
      message: event.title,
      waitDuration: const Duration(milliseconds: 350),
      child: GestureDetector(
        onTap: () => _showEventDialog(context),
        child: Container(
          height: 18,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(5),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.5,
                height: 1,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDialog(BuildContext context) {
    final categoryBloc = context.read<CategoryBloc>();
    final eventBloc = context.read<EventBloc>();

    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: categoryBloc,
        child: EventDialog(event: event, initialDate: event.startTime),
      ),
    ).then((result) {
      if (!context.mounted || result == null || result is! Map) return;

      if (result['action'] == 'save') {
        eventBloc.add(UpdateEvent(result['event']));
      } else if (result['action'] == 'delete') {
        eventBloc.add(DeleteEvent(event.id));
      }
    });
  }
}

/// حوار إضافة حدث سريع بتصميم زجاجي
class _QuickAddEventDialog extends StatefulWidget {
  final DateTime date;
  const _QuickAddEventDialog({required this.date});

  @override
  State<_QuickAddEventDialog> createState() => _QuickAddEventDialogState();
}

class _QuickAddEventDialogState extends State<_QuickAddEventDialog> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Event - ${CalendarDateUtils.formatFullDate(widget.date)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Event title...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.07),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90D9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_titleController.text.trim().isNotEmpty) {
      const uuid = Uuid();
      final now = DateTime.now();
      final event = CalendarEvent(
        id: uuid.v4(),
        title: _titleController.text.trim(),
        startTime: DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          now.hour,
          now.minute,
        ),
        endTime: DateTime(
          widget.date.year,
          widget.date.month,
          widget.date.day,
          now.hour + 1,
          now.minute,
        ),
      );
      Navigator.pop(context, event);
    }
  }
}
