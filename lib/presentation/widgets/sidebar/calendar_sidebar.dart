import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/../../application/calendar/calendar_bloc.dart';
import '/../../application/calendar/calendar_event.dart';
import '/../../application/calendar/calendar_state.dart';
import '/../../application/category/category_bloc.dart';
import '/../../application/category/category_state.dart';
import '../../helpers/date_utils.dart';
import '../../helpers/color_utils.dart';

/// الشريط الجانبي — تقويم مصغر + تصنيفات
class CalendarSidebar extends StatelessWidget {
  const CalendarSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.06), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // زر "اليوم"
          _TodayButton(),
          const SizedBox(height: 20),
          // التقويم المصغر
          const _MiniCalendar(),
          const SizedBox(height: 24),
          // التصنيفات
          const _CategorySection(),
        ],
      ),
    );
  }
}

/// زر العودة لليوم
class _TodayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return GestureDetector(
      onTap: () {
        context.read<CalendarBloc>().add(NavigateToToday());
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF4A90D9).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${now.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      CalendarDateUtils.formatMonthYear(now),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11,
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
}

/// التقويم المصغر
class _MiniCalendar extends StatelessWidget {
  const _MiniCalendar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        final firstDay = DateTime(state.focusedDate.year, state.focusedDate.month, 1);
        final lastDay = DateTime(state.focusedDate.year, state.focusedDate.month + 1, 0);
        int startWeekday = firstDay.weekday - 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس الشهر مع أزرار التنقل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CalendarDateUtils.formatMonthYear(state.focusedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    _MiniNavButton(
                      icon: Icons.chevron_left,
                      onTap: () => context.read<CalendarBloc>().add(NavigatePrevious()),
                    ),
                    _MiniNavButton(
                      icon: Icons.chevron_right,
                      onTap: () => context.read<CalendarBloc>().add(NavigateNext()),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // أسماء الأيام
            Row(
              children: CalendarDateUtils.weekDayNames.map((n) {
                return Expanded(
                  child: Center(
                    child: Text(
                      n[0],
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            // شبكة الأيام
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + lastDay.day,
              itemBuilder: (context, index) {
                if (index < startWeekday) {
                  return const SizedBox();
                }
                final dayNum = index - startWeekday + 1;
                final date = DateTime(state.focusedDate.year, state.focusedDate.month, dayNum);
                final isToday = CalendarDateUtils.isToday(date);
                final isSelected = CalendarDateUtils.isSameDay(date, state.selectedDate);

                return GestureDetector(
                  onTap: () {
                    context.read<CalendarBloc>().add(SelectDate(date));
                    context.read<CalendarBloc>().add(NavigateToDate(date));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isToday
                          ? const Color(0xFF4A90D9)
                          : isSelected
                              ? Colors.white.withOpacity(0.1)
                              : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
                          color: isToday
                              ? Colors.white
                              : Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// زر تنقل مصغر
class _MiniNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.white.withOpacity(0.6)),
      ),
    );
  }
}

/// قسم التصنيفات
class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is! CategoryLoaded) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            ...state.categories.map((cat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorUtils.fromValue(cat.colorValue),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${cat.icon} ${cat.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
