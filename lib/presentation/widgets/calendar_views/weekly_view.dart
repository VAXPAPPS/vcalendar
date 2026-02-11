import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/calendar/calendar_bloc.dart';
import '../../application/calendar/calendar_state.dart';
import '../../application/event/event_bloc.dart';
import '../../application/event/event_state.dart';
import '../../domain/entities/calendar_event.dart';
import '../helpers/date_utils.dart';
import '../helpers/color_utils.dart';

/// العرض الأسبوعي — جدول زمني بالساعات لـ 7 أيام
class WeeklyView extends StatelessWidget {
  const WeeklyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      buildWhen: (prev, curr) => prev.visibleDays != curr.visibleDays,
      builder: (context, calendarState) {
        final weekDays = calendarState.visibleDays.length == 7
            ? calendarState.visibleDays
            : CalendarState.generateWeekDays(calendarState.focusedDate);

        return BlocBuilder<EventBloc, EventState>(
          buildWhen: (prev, curr) => curr is EventLoaded,
          builder: (context, eventState) {
            final eventsByDate =
                eventState is EventLoaded ? eventState.eventsByDate : {};

            return Column(
              children: [
                // رأس الأيام
                _WeekHeader(days: weekDays, selectedDate: calendarState.selectedDate),
                const Divider(height: 1, color: Colors.white10),
                // الجدول الزمني
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عمود الساعات
                        const _TimeColumn(),
                        // أعمدة الأيام
                        ...weekDays.map((day) {
                          final key = CalendarDateUtils.dateKey(day);
                          final dayEvents =
                              (eventsByDate[key] as List<dynamic>?) ?? [];
                          return Expanded(
                            child: _DayColumn(
                              day: day,
                              events: dayEvents,
                              isToday: CalendarDateUtils.isToday(day),
                            ),
                          );
                        }),
                      ],
                    ),
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

/// رأس الأسبوع — أسماء الأيام والتواريخ
class _WeekHeader extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDate;

  const _WeekHeader({required this.days, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50, top: 8, bottom: 8),
      child: Row(
        children: days.map((day) {
          final isToday = CalendarDateUtils.isToday(day);
          return Expanded(
            child: Column(
              children: [
                Text(
                  CalendarDateUtils.weekDayNames[day.weekday - 1],
                  style: TextStyle(
                    fontSize: 11,
                    color: isToday
                        ? const Color(0xFF4A90D9)
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? const Color(0xFF4A90D9) : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
                        color: isToday ? Colors.white : Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// عمود الساعات
class _TimeColumn extends StatelessWidget {
  const _TimeColumn();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      child: Column(
        children: List.generate(24, (hour) {
          return SizedBox(
            height: 60,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 0),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.35),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// عمود يوم واحد مع الأحداث
class _DayColumn extends StatelessWidget {
  final DateTime day;
  final List<dynamic> events;
  final bool isToday;

  const _DayColumn({
    required this.day,
    required this.events,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Stack(
        children: [
          // خطوط الساعات
          Column(
            children: List.generate(24, (hour) {
              return Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.05),
                      width: 0.5,
                    ),
                  ),
                ),
              );
            }),
          ),
          // خط الوقت الحالي
          if (isToday) _CurrentTimeLine(),
          // الأحداث
          ...events.map((e) {
            final event = e as CalendarEvent;
            final top = event.startTime.hour * 60.0 +
                event.startTime.minute;
            final height = (event.endTime.difference(event.startTime).inMinutes)
                .clamp(15, 1440)
                .toDouble();

            return Positioned(
              top: top,
              left: 2,
              right: 2,
              height: height,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorUtils.fromValue(event.colorValue).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: ColorUtils.fromValue(event.colorValue),
                    width: 1,
                  ),
                ),
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// خط الوقت الحالي
class _CurrentTimeLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final top = now.hour * 60.0 + now.minute;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF5F57),
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              color: const Color(0xFFFF5F57),
            ),
          ),
        ],
      ),
    );
  }
}
