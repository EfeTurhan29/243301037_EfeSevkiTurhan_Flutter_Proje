import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../user_role.dart';
import 'home_page.dart';
import 'register_page.dart';

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
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );
  }

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
                    Icon(
                      Icons.qr_code_2,
                      size: 72,
                      color: appBlue,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Kare Kod Eğitim Kurumları',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: appDarkText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.supabaseReady
                          ? 'Supabase bağlantısı hazır'
                          : 'Tasarım modu: Supabase bilgileri sonra eklenecek',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.supabaseReady
                            ? appGreen
                            : appOrange,
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
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        suffixIcon: IconButton(
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
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