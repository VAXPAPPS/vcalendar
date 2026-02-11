import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '/../../application/category/category_bloc.dart';
import '/../../application/category/category_state.dart';
import '/../../domain/entities/calendar_event.dart';
import '../../helpers/color_utils.dart';
import '../../helpers/date_utils.dart';

/// حوار إضافة/تعديل حدث كامل
class EventDialog extends StatefulWidget {
  final CalendarEvent? event; // null = إضافة جديد
  final DateTime initialDate;

  const EventDialog({
    super.key,
    this.event,
    required this.initialDate,
  });

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late String _categoryId;
  late int _colorValue;
  late RecurrenceType _recurrence;
  bool _isAllDay = false;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _descController = TextEditingController(text: event?.description ?? '');
    _startDate = event?.startTime ?? widget.initialDate;
    _startTime = event != null
        ? TimeOfDay.fromDateTime(event.startTime)
        : TimeOfDay.now();
    _endTime = event != null
        ? TimeOfDay.fromDateTime(event.endTime)
        : TimeOfDay(
            hour: (TimeOfDay.now().hour + 1) % 24,
            minute: TimeOfDay.now().minute,
          );
    _categoryId = event?.categoryId ?? 'default';
    _colorValue = event?.colorValue ?? 0xFF7AB1FF;
    _recurrence = event?.recurrence ?? RecurrenceType.none;
    _isAllDay = event?.isAllDay ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.event != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(
                    isEdit ? 'تعديل الحدث' : 'حدث جديد',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // حقل العنوان
                  _buildField(
                    controller: _titleController,
                    hint: 'عنوان الحدث',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 12),

                  // حقل الوصف
                  _buildField(
                    controller: _descController,
                    hint: 'وصف (اختياري)',
                    icon: Icons.notes,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // التاريخ
                  _SectionLabel(text: 'التاريخ والوقت'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: _InfoChip(
                      icon: Icons.calendar_today,
                      text: CalendarDateUtils.formatFullDate(_startDate),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // الوقت
                  if (!_isAllDay)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(true),
                            child: _InfoChip(
                              icon: Icons.access_time,
                              text: _startTime.format(context),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward,
                              size: 16, color: Colors.white.withOpacity(0.3)),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickTime(false),
                            child: _InfoChip(
                              icon: Icons.access_time,
                              text: _endTime.format(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // طول اليوم
                  Row(
                    children: [
                      Switch(
                        value: _isAllDay,
                        onChanged: (v) => setState(() => _isAllDay = v),
                        activeColor: const Color(0xFF4A90D9),
                      ),
                      Text(
                        'طوال اليوم',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // التصنيف
                  _SectionLabel(text: 'التصنيف'),
                  const SizedBox(height: 8),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, catState) {
                      if (catState is! CategoryLoaded) return const SizedBox();
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: catState.categories.map((cat) {
                          final isSelected = cat.id == _categoryId;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _categoryId = cat.id;
                              _colorValue = cat.colorValue;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isSelected
                                    ? ColorUtils.fromValue(cat.colorValue)
                                        .withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                                border: Border.all(
                                  color: isSelected
                                      ? ColorUtils.fromValue(cat.colorValue)
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                '${cat.icon} ${cat.name}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // اختيار اللون
                  _SectionLabel(text: 'اللون'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ColorUtils.availableColors.map((c) {
                      final isSelected = c == _colorValue;
                      return GestureDetector(
                        onTap: () => setState(() => _colorValue = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorUtils.fromValue(c),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2.5)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          ColorUtils.fromValue(c).withOpacity(0.5),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // التكرار
                  _SectionLabel(text: 'التكرار'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: RecurrenceType.values.map((r) {
                      final isSelected = r == _recurrence;
                      final labels = {
                        RecurrenceType.none: 'بدون',
                        RecurrenceType.daily: 'يومي',
                        RecurrenceType.weekly: 'أسبوعي',
                        RecurrenceType.monthly: 'شهري',
                        RecurrenceType.yearly: 'سنوي',
                      };
                      return GestureDetector(
                        onTap: () => setState(() => _recurrence = r),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected
                                ? const Color(0xFF4A90D9).withOpacity(0.3)
                                : Colors.white.withOpacity(0.05),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4A90D9)
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            labels[r]!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // أزرار الإجراء
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isEdit)
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, {'action': 'delete'}),
                          child: const Text('حذف',
                              style: TextStyle(color: Color(0xFFFF5F57))),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('إلغاء',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5))),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90D9),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isEdit ? 'حفظ التعديلات' : 'إضافة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixIcon: Icon(icon, size: 18, color: Colors.white.withOpacity(0.4)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A90D9),
              surface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  void _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A90D9),
              surface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;

    const uuid = Uuid();
    final startDateTime = _isAllDay
        ? DateTime(_startDate.year, _startDate.month, _startDate.day)
        : DateTime(_startDate.year, _startDate.month, _startDate.day,
            _startTime.hour, _startTime.minute);
    final endDateTime = _isAllDay
        ? DateTime(_startDate.year, _startDate.month, _startDate.day, 23, 59)
        : DateTime(_startDate.year, _startDate.month, _startDate.day,
            _endTime.hour, _endTime.minute);

    final event = CalendarEvent(
      id: widget.event?.id ?? uuid.v4(),
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      categoryId: _categoryId,
      colorValue: _colorValue,
      recurrence: _recurrence,
      isAllDay: _isAllDay,
    );

    Navigator.pop(context, {'action': 'save', 'event': event});
  }
}

/// عنوان قسم
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.45),
        letterSpacing: 0.3,
      ),
    );
  }
}

/// شريحة معلومات (تاريخ/وقت)
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.5)),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
