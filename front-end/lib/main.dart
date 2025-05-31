import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'services/connectivity_service.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/config/app_config.dart';
import 'core/network/api_service.dart' as core;
import 'data/datasources/student_service.dart' as data;
import 'data/repositories/student_repository_impl.dart';
import 'domain/repositories/student_repository.dart';
import 'presentation/bloc/student/student_bloc.dart';
import 'presentation/bloc/student/student_event.dart';
import 'presentation/pages/student_list_page.dart';

void main() {
  setupDependencies();
  runApp(const MyApp());
}

void setupDependencies() {
  final getIt = GetIt.instance;

  // Core
  getIt.registerLazySingleton<core.ApiService>(
      () => core.ApiService(baseUrl: AppConfig.apiBaseUrl));

  // Data
  getIt.registerLazySingleton<data.StudentService>(
    () => data.StudentService(getIt<core.ApiService>()),
  );

  // Repositories
  getIt.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(getIt<data.StudentService>()),
  );

  // BLoCs
  getIt.registerFactory<StudentBloc>(
    () => StudentBloc(getIt<StudentRepository>()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => GetIt.instance<StudentBloc>()..add(LoadStudents()),
        child: const StudentListPage(),
      ),
    );
  }
}

class _ErrorHandlingWidget extends StatelessWidget {
  final Widget child;

  const _ErrorHandlingWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    final connectivityService =
        Provider.of<ConnectivityService>(context, listen: false);
    return StreamBuilder<NetworkStatus>(
      stream: connectivityService.status,
      builder: (context, snapshot) {
        final status = snapshot.data;
        final bool showNotification = snapshot.hasData &&
            status != null &&
            (status == NetworkStatus.offline ||
                status == NetworkStatus.serverUnavailable);

        return Stack(
          children: [
            child,
            // Only show a notification when there's a connection issue
            if (showNotification)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  color: status == NetworkStatus.offline
                      ? Colors.red.shade700
                      : Colors.orange.shade700,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          status == NetworkStatus.offline
                              ? Icons.signal_wifi_off
                              : Icons.cloud_off,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            status == NetworkStatus.offline
                                ? 'Pas de connexion internet'
                                : 'Serveur indisponible',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: () {
                            connectivityService.checkApiAvailability();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
