import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/health_repository_impl.dart';
import 'logic/health_bloc.dart';
import 'logic/health_event.dart';
import 'presentation/screens/home_screen.dart';
import 'core/services/background_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background sync service
  await BackgroundSyncService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The Cal Club Brand Color
    const Color brandColor = Color(0xFFFF5722);

    return BlocProvider(
      create: (context) {
        final bloc = HealthBloc(
          repository: HealthRepositoryImpl(),
        );
        bloc.add(const InitializeBackgroundSyncEvent());
        return bloc;
      },
      child: MaterialApp(
        title: 'The Cal Club',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: brandColor,
            primary: brandColor,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: brandColor,
            foregroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
