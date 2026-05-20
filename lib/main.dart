import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'ekranlar/login_page.dart';

const String supabaseUrl = 'SUPABASE_URL';
const String supabaseAnonKey = 'SUPABASE_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool supabaseReady =
      supabaseUrl.startsWith('https://') && supabaseAnonKey.startsWith('ey');

  if (supabaseReady) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  runApp(KresApp(supabaseReady: supabaseReady));
}

class KresApp extends StatelessWidget {
  final bool supabaseReady;

  const KresApp({super.key, required this.supabaseReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kreş Rapor ve Ödeme Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: appBlue,//giriş ekranı
        scaffoldBackgroundColor: appBackground,
        useMaterial3: true,
      ),
      home: LoginPage(supabaseReady: supabaseReady),
      routes: {
        '/login': (context) => LoginPage(supabaseReady: supabaseReady),
      },
    );
  }
}
