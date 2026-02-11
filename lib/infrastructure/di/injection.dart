import 'package:get_it/get_it.dart';
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/category_repository.dart';
import '../../application/calendar/calendar_bloc.dart';
import '../../application/event/event_bloc.dart';
import '../../application/category/category_bloc.dart';

final getIt = GetIt.instance;

/// تهيئة حقن التبعيات
Future<void> setupDependencies() async {
  // === Data Sources ===
  final localDataSource = LocalDataSource();
  await localDataSource.init();
  getIt.registerSingleton<LocalDataSource>(localDataSource);

  // === Repositories ===
  getIt.registerSingleton<EventRepository>(
    EventRepositoryImpl(localDataSource),
  );
  getIt.registerSingleton<CategoryRepository>(
    CategoryRepositoryImpl(localDataSource),
  );

  // تهيئة التصنيفات الافتراضية
  await getIt<CategoryRepository>().initDefaults();

  // === BLoCs ===
  getIt.registerFactory<CalendarBloc>(() => CalendarBloc());
  getIt.registerFactory<EventBloc>(
    () => EventBloc(getIt<EventRepository>()),
  );
  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(getIt<CategoryRepository>()),
  );
}
