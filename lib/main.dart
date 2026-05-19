import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_colors.dart';
import 'user_role.dart';
import 'ekranlar/register_page.dart';
import 'ekranlar/payments_page.dart';
import 'ekranlar/profile_page.dart';
import 'ekranlar/child_detail_page.dart';
import 'ekranlar/child_list_page.dart';
import 'widgets/home_menu_card.dart';
import 'widgets/summary_card.dart';

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
    );
  }
}

class LoginPage extends StatefulWidget {
  final bool supabaseReady;

  const LoginPage({super.key, required this.supabaseReady});

  @override
  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  UserRole selectedRole = UserRole.teacher;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    emailController.text = 'ogretmen@test.com';
    passwordController.text = '123456';
  }

  void login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(role: selectedRole),
      ),
    );
  }

  void openRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }
//giriş ekranı
  @override
  Widget build(BuildContext context) {
    final roleName = selectedRole == UserRole.teacher ? 'Öğretmen' : 'Veli';

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      size: 72,
                      color: appBlue,//giriş ekranı icon
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kare Kod Eğitim Kurumlari',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.supabaseReady
                          ? 'Supabase bağlantısı hazır'
                          : 'TEST',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.supabaseReady
                            ? Colors.green
                            : const Color.fromARGB(255, 255, 115, 0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<UserRole>(
                      segments: const [
                        ButtonSegment(
                          value: UserRole.teacher,
                          label: Text('Öğretmen'),
                          icon: Icon(Icons.school),
                        ),
                        ButtonSegment(
                          value: UserRole.parent,
                          label: Text('Veli'),
                          icon: Icon(Icons.family_restroom),
                        ),
                      ],
                      selected: {selectedRole},
                      onSelectionChanged: (value) {
                        setState(() {
                          selectedRole = value.first;
                          if (selectedRole == UserRole.teacher) {
                            emailController.text = 'ogretmen@test.com';
                          } else {
                            emailController.text = 'veli@test.com';
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Şifre',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          iconSize: 23,
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },  
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: login,
                        icon: const Icon(Icons.login),
                        label: Text('$roleName olarak giriş yap'),
                      ),
                    ),
                    TextButton(
                      onPressed: openRegisterPage,
                      child: const Text('Yeni kullanıcı kaydı oluştur'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


//öğretmen veli panelleri
class HomePage extends StatelessWidget {
  final UserRole role;

  const HomePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isTeacher = role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'Öğretmen Paneli' : 'Veli Paneli'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(supabaseReady: false),
                ),
              );
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: appCardBlue,//açıklama kutusu
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: appLightBlue,
                  //açıklama kutusu içi yuvarlak
                  child: Icon(
                    isTeacher ? Icons.school : Icons.family_restroom,
                    size: 36,
                    color: appBlue,
                  //açıklama kutusu icon
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isTeacher
                        ? 'Bugün çocukların günlük raporlarını ekleyebilir ve ödeme durumlarını takip edebilirsin.'
                        : 'Çocuğunun günlük raporlarını ve ödeme bilgilerini buradan takip edebilirsin.',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              HomeMenuCard(
                title: 'Öğrenciler',
                icon: Icons.contacts_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildListPage(role: role),
                    ),
                  );
                },
              ),
              HomeMenuCard(
                title: 'Raporlar',
                icon: Icons.assignment,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildDetailPage(
                        role: role,
                        childName: 'Nazlıcan Altın',
                      ),
                    ),
                  );
                },
              ),
              HomeMenuCard(
                title: 'Ödemeler',
                icon: Icons.payments,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentsPage(),
                    ),
                  );
                },
              ),
              HomeMenuCard(
                title: 'Profil',
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(role: role),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Bugünkü Özet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const SummaryCard(
            title: 'Toplam Öğrenci',
            value: '15',
            icon: Icons.groups,
          ),
          const SummaryCard(
            title: 'Bugün Girilen Rapor',
            value: '5',
            icon: Icons.note_alt,
          ),
          const SummaryCard(
            title: 'Bekleyen Ödeme',
            value: '2',
            icon: Icons.warning_amber,
          ),
        ],
      ),
    );
  }
}