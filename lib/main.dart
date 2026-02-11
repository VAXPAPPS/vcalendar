import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:venom/core/venom_layout.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';
import 'core/colors/vaxp_colors.dart';
import 'infrastructure/di/injection.dart';
import 'application/calendar/calendar_bloc.dart';
import 'application/event/event_bloc.dart';
import 'application/category/category_bloc.dart';
import 'presentation/screens/calendar_screen.dart';

Future<void> main() async {
  // Initialize Flutter bindings first
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Venom Config System
  await VenomConfig().init();

  // Initialize VaxpColors listeners
  VaxpColors.init();

  // Initialize Dependency Injection (Hive + repositories)
  await setupDependencies();

  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VaxpCalendarApp());
}

class VaxpCalendarApp extends StatelessWidget {
  const VaxpCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CalendarBloc>(
          create: (_) => getIt<CalendarBloc>(),
        ),
        BlocProvider<EventBloc>(
          create: (_) => getIt<EventBloc>(),
        ),
        BlocProvider<CategoryBloc>(
          create: (_) => getIt<CategoryBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vaxp Calendar',
        home: const _CalendarHome(),
      ),
    );
  }
}

class _CalendarHome extends StatelessWidget {
  const _CalendarHome();

  @override
  Widget build(BuildContext context) {
    return VenomScaffold(
      title: "Vaxp Calendar",
      body: const CalendarScreen(),
    );
  }
}
