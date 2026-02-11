import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../application/calendar/calendar_bloc.dart';
import '../../../application/calendar/calendar_state.dart';
import '../../../application/event/event_bloc.dart';
import '../../../application/event/event_state.dart';
import '../../../domain/entities/calendar_event.dart';
import '../../helpers/color_utils.dart';
import '../../helpers/date_utils.dart';


/// العرض اليومي — جدول زمني مفصل لـ 24 ساعة
class DailyView extends StatelessWidget {
  const DailyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, calendarState) {
        return BlocBuilder<EventBloc, EventState>(
          buildWhen: (prev, curr) => curr is EventLoaded,
          builder: (context, eventState) {
            final eventsByDate =
                eventState is EventLoaded ? eventState.eventsByDate : {};
            final key = CalendarDateUtils.dateKey(calendarState.focusedDate);
            final dayEvents = (eventsByDate[key] as List<dynamic>?) ?? [];

            return Column(
              children: [
                // عنوان اليوم
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    CalendarDateUtils.formatDayTitle(calendarState.focusedDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
                // الجدول الزمني
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // عمود الساعات
                        SizedBox(
                          width: 60,
                          child: Column(
                            children: List.generate(24, (hour) {
                              return SizedBox(
                                height: 70,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Text(
                                      '${hour.toString().padLeft(2, '0')}:00',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.35),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // منطقة الأحداث
                        Expanded(
                          child: Stack(
                            children: [
                              // خطوط الساعات الأفقية
                              Column(
                                children: List.generate(24, (hour) {
                                  return Container(
                                    height: 70,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.white.withOpacity(0.06),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              // خط الوقت الحالي
                              if (CalendarDateUtils.isToday(
                                  calendarState.focusedDate))
                                Builder(
                                  builder: (context) {
                                    final now = DateTime.now();
                                    final top =
                                        now.hour * 70.0 + (now.minute * 70 / 60);
                                    return Positioned(
                                      top: top,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFFF5F57),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              height: 2,
                                              color: const Color(0xFFFF5F57),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              // الأحداث
                              ...dayEvents.map((e) {
                                final event = e as CalendarEvent;
                                final top = event.startTime.hour * 70.0 +
                                    (event.startTime.minute * 70 / 60);
                                final duration = event.endTime
                                    .difference(event.startTime)
                                    .inMinutes;
                                final height =
                                    (duration * 70 / 60).clamp(25.0, 1680.0);

                                return Positioned(
                                  top: top,
                                  left: 4,
                                  right: 16,
                                  height: height,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorUtils.fromValue(
                                              event.colorValue)
                                          .withOpacity(0.85),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: ColorUtils.fromValue(
                                            event.colorValue),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ColorUtils.fromValue(
                                                  event.colorValue)
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (height > 40)
                                          Text(
                                            '${CalendarDateUtils.formatTime(event.startTime)} - ${CalendarDateUtils.formatTime(event.endTime)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                          ),
                                        if (event.description.isNotEmpty &&
                                            height > 60)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Text(
                                              event.description,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
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
