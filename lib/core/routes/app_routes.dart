import 'package:flutter/material.dart';
import 'package:spmb_app/data/models/peserta_model.dart';
import 'package:spmb_app/presentation/layouts/main_layout.dart';
import 'package:spmb_app/presentation/pages/login/login_page.dart';
import 'package:spmb_app/presentation/pages/pendaftaran/pendaftaran_page.dart';

class AppRoutes {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String pendaftaran = '/pendaftaran';
  static const String database = '/database';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const MainLayout(index: 0));

      case pendaftaran:
        // Bisa bawa argument PesertaModel untuk mode edit
        final peserta = settings.arguments as PesertaModel?;
        return MaterialPageRoute(
          builder: (_) => PendaftaranPage(peserta: peserta),
        );

      case database:
        return MaterialPageRoute(builder: (_) => const MainLayout(index: 2));

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  }
}