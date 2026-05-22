import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../user_role.dart';
import '../log_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  final bool supabaseReady;

  const LoginPage({super.key, required this.supabaseReady});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoading = false;
  bool rememberMe = true;

  @override
  void initState() {
    super.initState();

    // Test için istersen buraya son oluşturduğun kullanıcıyı yazabilirsin.
    emailController.text = '';
    passwordController.text = '';
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta ve şifre boş bırakılamaz.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;

      if (user == null) {
        throw 'Kullanıcı bulunamadı.';
      }

      final profile = await supabase
          .from('profiles')
          .select('id, full_name, email, role')
          .eq('id', user.id)
          .single();

      final roleText = profile['role']?.toString() ?? 'parent';

      final userRole =
          roleText == 'teacher' ? UserRole.teacher : UserRole.parent;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);

      await LogService.addLog(
        action: 'login',
        description: '$email adresli kullanıcı giriş yaptı.',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(role: userRole),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş yapılırken hata oluştu: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
  final email = emailController.text.trim();

  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şifre sıfırlama için e-posta adresini yazmalısın.'),
      ),
    );
    return;
  }

  try {
    await supabase.auth.resetPasswordForEmail(email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Şifre sıfırlama bağlantısı e-posta adresine gönderildi.'),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Şifre sıfırlama işlemi başarısız: $error'),
      ),
    );
  }
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
                        color: widget.supabaseReady ? appGreen : appOrange,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
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
                    
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? true;
                            });
                          },
                        ),
                        const Expanded(
                      child: Text(
                        'Beni hatırla',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: resetPassword,
                    child: const Text(
                    'Şifremi unuttum',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
                    
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: isLoading ? null : login,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login),
                        label: Text(
                          isLoading ? 'Giriş yapılıyor...' : 'Giriş Yap',
                        ),
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