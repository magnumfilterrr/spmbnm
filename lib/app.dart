import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/core/routes/app_routes.dart';
import 'package:spmb_app/core/theme/app_theme.dart';
import 'package:spmb_app/data/repositories/auth_repository.dart';
import 'package:spmb_app/data/repositories/dashboard_repository.dart';
import 'package:spmb_app/data/repositories/peserta_repository.dart';
import 'package:spmb_app/logic/auth/auth_bloc.dart';
import 'package:spmb_app/logic/auth/auth_state.dart';
import 'package:spmb_app/logic/dashboard/dashboard_bloc.dart';
import 'package:spmb_app/logic/database/database_bloc.dart';
import 'package:spmb_app/logic/pendaftaran/pendaftaran_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Buat instance manual agar bisa di-share
    final pesertaRepository = PesertaRepository();
    final databaseBloc = DatabaseBloc(pesertaRepository);
    final pendaftaranBloc = PendaftaranBloc(pesertaRepository, databaseBloc);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => pesertaRepository),
        RepositoryProvider(create: (_) => DashboardRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => AuthBloc(ctx.read<AuthRepository>()),
          ),
          BlocProvider(
            create: (ctx) => DashboardBloc(ctx.read<DashboardRepository>()),
          ),
          BlocProvider.value(value: databaseBloc), // ✅ pakai .value
          BlocProvider.value(value: pendaftaranBloc), // ✅ pakai .value
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthLoggedOut) {
              AppRoutes.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
            }
          },
          child: MaterialApp(
            title: 'SPMB SMK NUURUL MUTTAQIIN',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            navigatorKey: AppRoutes.navigatorKey,
            initialRoute: AppRoutes.login,
            onGenerateRoute: AppRoutes.generateRoute,
          ),
        ),
      ),
    );
  }
}
