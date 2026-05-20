import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../user_role.dart';

class ProfilePage extends StatelessWidget {
  final UserRole role;

  const ProfilePage({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final isTeacher = role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: appLightBlue,
            child: Icon(
              isTeacher ? Icons.school : Icons.family_restroom,
              size: 52,
              color: appBlue,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(isTeacher ? 'Öğretmen Kullanıcı' : 'Veli Kullanıcı'),
              subtitle: Text(isTeacher ? 'ogretmen@test.com' : 'veli@test.com'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Rol'),
              subtitle: Text(isTeacher ? 'Öğretmen / Yönetici' : 'Veli'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage),
              title: const Text('Veri Saklama'),
              subtitle: const Text('Supabase veritabanı ile bağlantı kurulacak'),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
              
            },
            icon: const Icon(Icons.logout),
            label: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}