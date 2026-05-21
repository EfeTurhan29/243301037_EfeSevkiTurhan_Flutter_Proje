import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../user_role.dart';

class ProfilePage extends StatefulWidget {
  final UserRole role;

  const ProfilePage({super.key, required this.role});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          errorMessage = 'Aktif kullanıcı bulunamadı.';
          isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('profiles')
          .select('full_name, email, role, created_at')
          .eq('id', user.id)
          .limit(1);

      final rows = List<Map<String, dynamic>>.from(response);

      setState(() {
        profile = rows.isNotEmpty
            ? rows.first
            : {
                'full_name': 'Profil bulunamadı',
                'email': user.email ?? 'E-posta yok',
                'role': widget.role.name,
              };
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Profil bilgileri alınırken hata oluştu: $error';
        isLoading = false;
      });
    }
  }

  String getRoleText(String? role) {
    if (role == 'teacher') {
      return 'Öğretmen / Yönetici';
    }

    return 'Veli';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false);

    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final fullName = profile?['full_name']?.toString() ?? 'Ad bilgisi yok';
    final email = profile?['email']?.toString() ?? 'E-posta bilgisi yok';
    final role = profile?['role']?.toString() ?? widget.role.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: appLightBlue,
                    child: Icon(
                      role == 'teacher'
                          ? Icons.school
                          : Icons.family_restroom,
                      size: 44,
                      color: appBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: appDarkText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.email, color: appBlue),
              title: const Text('E-posta'),
              subtitle: Text(email),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.verified_user, color: appBlue),
              title: const Text('Rol'),
              subtitle: Text(getRoleText(role)),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.storage, color: appBlue),
              title: const Text('Veri Saklama'),
              subtitle: const Text('Supabase veritabanı ile bağlantı kuruldu.'),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}