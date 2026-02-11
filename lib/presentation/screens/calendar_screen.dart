import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vcalendar/presentation/widgets/calendar_views/daily_view.dart';
import 'package:vcalendar/presentation/widgets/calendar_views/monthly_view.dart';
import 'package:vcalendar/presentation/widgets/calendar_views/weekly_view.dart';
import 'package:vcalendar/presentation/widgets/event/event_dialog.dart';
import 'package:vcalendar/presentation/widgets/sidebar/calendar_sidebar.dart';
import '../../application/calendar/calendar_bloc.dart';
import '../../application/calendar/calendar_event.dart';
import '../../application/calendar/calendar_state.dart';
import '../../application/event/event_bloc.dart';
import '../../application/event/event_event.dart';
import '../../application/event/event_state.dart';
import '../../application/category/category_bloc.dart';
import '../../application/category/category_event.dart';
import '../helpers/date_utils.dart';


/// الشاشة الرئيسية للتقويم
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل التصنيفات والأحداث عند البدء
    context.read<CategoryBloc>().add(LoadCategories());
    _loadEventsForCurrentView();
  }

  void _loadEventsForCurrentView() {
    final calState = context.read<CalendarBloc>().state;
    final focusedDate = calState.focusedDate;

    // تحميل أحداث الشهر الحالي
    final firstDay = DateTime(focusedDate.year, focusedDate.month, 1);
    final lastDay = DateTime(focusedDate.year, focusedDate.month + 1, 0);
    context
        .read<EventBloc>()
        .add(LoadEvents(start: firstDay, end: lastDay));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalendarBloc, CalendarState>(
      listenWhen: (prev, curr) =>
          prev.focusedDate.month != curr.focusedDate.month ||
          prev.focusedDate.year != curr.focusedDate.year,
      listener: (context, state) {
        _loadEventsForCurrentView();
      },
      child: BlocListener<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF28C840),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: Row(
          children: [
            // الشريط الجانبي
            const CalendarSidebar(),
            // المحتوى الرئيسي
            Expanded(
              child: Column(
                children: [
                  // شريط الأدوات العلوي
                  _CalendarToolbar(
                    onAddEvent: () => _showEventDialog(context),
                  ),
                  // العرض الحالي
                  Expanded(
                    child: BlocBuilder<CalendarBloc, CalendarState>(
                      buildWhen: (prev, curr) =>
                          prev.viewType != curr.viewType,
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildCurrentView(state.viewType),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView(CalendarViewType viewType) {
    switch (viewType) {
      case CalendarViewType.monthly:
        return const MonthlyView(key: ValueKey('monthly'));
      case CalendarViewType.weekly:
        return const WeeklyView(key: ValueKey('weekly'));
      case CalendarViewType.daily:
        return const DailyView(key: ValueKey('daily'));
    }
  }

  void _showEventDialog(BuildContext context) {
    final calState = context.read<CalendarBloc>().state;
    showDialog(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CategoryBloc>()),
        ],
        child: EventDialog(initialDate: calState.selectedDate),
      ),
    ).then((result) {
      if (result != null && result is Map) {
        if (result['action'] == 'save') {
          context.read<EventBloc>().add(AddEvent(result['event']));
        }
      }
    });
  }
}

/// شريط الأدوات العلوي
class _CalendarToolbar extends StatelessWidget {
  final VoidCallback onAddEvent;

  const _CalendarToolbar({required this.onAddEvent});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarBloc, CalendarState>(
      builder: (context, state) {
        String title;
        switch (state.viewType) {
          case CalendarViewType.monthly:
            title = CalendarDateUtils.formatMonthYear(state.focusedDate);
            break;
          case CalendarViewType.weekly:
            title = CalendarDateUtils.formatWeekRange(state.focusedDate);
            break;
          case CalendarViewType.daily:
            title = CalendarDateUtils.formatDayTitle(state.focusedDate);
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // عنوان العرض الحالي
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              // أزرار التنقل
              _ToolbarBtn(
                icon: Icons.chevron_left,
                onTap: () =>
                    context.read<CalendarBloc>().add(NavigatePrevious()),
              ),
              const SizedBox(width: 4),
              _ToolbarBtn(
                icon: Icons.chevron_right,
                onTap: () =>
                    context.read<CalendarBloc>().add(NavigateNext()),
              ),
              const Spacer(),
              // مبدل العروض
              _ViewSwitcher(currentView: state.viewType),
              const SizedBox(width: 12),
              // زر إضافة حدث
              GestureDetector(
                onTap: onAddEvent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90D9).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 18, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        'New Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// زر في شريط الأدوات
class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.white.withOpacity(0.7)),
      ),
    );
  }
}

/// مبدل العروض (شهري/أسبوعي/يومي)
class _ViewSwitcher extends StatelessWidget {
  final CalendarViewType currentView;
  const _ViewSwitcher({required this.currentView});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CalendarViewType.values.map((view) {
          final isActive = view == currentView;
          final labels = {
            CalendarViewType.monthly: 'Month',
            CalendarViewType.weekly: 'Week',
            CalendarViewType.daily: 'Day',
          };
          return GestureDetector(
            onTap: () =>
                context.read<CalendarBloc>().add(ChangeViewType(view)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF4A90D9).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isActive
                    ? Border.all(
                        color: const Color(0xFF4A90D9).withOpacity(0.3))
                    : null,
              ),
              child: Text(
                labels[view]!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
