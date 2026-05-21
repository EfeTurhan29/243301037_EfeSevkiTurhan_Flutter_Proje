import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'user_role.dart';
import 'ekranlar/login_page.dart';
import 'ekranlar/home_page.dart';

const String supabaseUrl = 'https://utxceomaqoyhcpiystbx.supabase.co';
const String supabaseAnonKey = 'sb_publishable_maYnnYQdUW0Tz0GJ85yZiA_FB4wsJpf';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

   final bool supabaseReady =
    supabaseUrl.startsWith('https://') &&
    supabaseAnonKey != 'sb_publishable_' &&
    supabaseAnonKey.isNotEmpty;

  if (supabaseReady) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  runApp(KresApp(supabaseReady: supabaseReady));
}

class KresApp extends StatefulWidget {
  final bool supabaseReady;

  const KresApp({super.key, required this.supabaseReady});

  @override
  State<KresApp> createState() => _KresAppState();
}

class _KresAppState extends State<KresApp> {
  bool isCheckingSession = true;
  UserRole? currentRole;

  @override
  void initState() {
    super.initState();
    checkCurrentSession();
  }

  Future<void> checkCurrentSession() async {
  if (!widget.supabaseReady) {
    setState(() {
      isCheckingSession = false;
    });
    return;
  }

  final prefs = await SharedPreferences.getInstance();
  final rememberMe = prefs.getBool('remember_me') ?? false;

  final session = Supabase.instance.client.auth.currentSession;

  if (session == null) {
    setState(() {
      currentRole = null;
      isCheckingSession = false;
    });
    return;
  }

  if (!rememberMe) {
    await Supabase.instance.client.auth.signOut();

    setState(() {
      currentRole = null;
      isCheckingSession = false;
    });
    return;
  }

  final user = session.user;

  try {
    final profile = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    final roleText = profile['role']?.toString() ?? 'parent';

    setState(() {
      currentRole =
          roleText == 'teacher' ? UserRole.teacher : UserRole.parent;
      isCheckingSession = false;
    });
  } catch (error) {
    await Supabase.instance.client.auth.signOut();

    setState(() {
      currentRole = null;
      isCheckingSession = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kreş Rapor ve Ödeme Sistemi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: appBlue,
        scaffoldBackgroundColor: appBackground,
        useMaterial3: true,
      ),
      home: isCheckingSession
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : currentRole != null
              ? HomePage(role: currentRole!)
              : LoginPage(supabaseReady: widget.supabaseReady),
      routes: {
        '/login': (context) => LoginPage(supabaseReady: widget.supabaseReady),
      },
    );
  }
}