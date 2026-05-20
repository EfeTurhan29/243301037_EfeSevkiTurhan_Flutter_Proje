import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../user_role.dart';
import '../widgets/home_menu_card.dart';
import '../widgets/summary_card.dart';

import 'child_detail_page.dart';
import 'child_list_page.dart';
import 'payments_page.dart';
import 'profile_page.dart';

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
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: appCardBlue,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: appLightBlue,
                  child: Icon(
                    isTeacher ? Icons.school : Icons.family_restroom,
                    size: 36,
                    color: appBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isTeacher
                        ? 'Bugün çocukların günlük raporlarını ekleyebilir ve ödeme durumlarını takip edebilirsin.'
                        : 'Çocuğunun günlük raporlarını ve ödeme bilgilerini buradan takip edebilirsin.',
                    style: TextStyle(
                      fontSize: 16,
                      color: appDarkText,
                    ),
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
                title: 'Çocuklar',
                icon: Icons.child_friendly,
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
                title: 'Günlük Raporlar',
                icon: Icons.assignment,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildDetailPage(
                        role: role,
                        childId: '00000000-0000-0000-0000-000000000001',
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
                      builder: (_) => PaymentsPage(role: role),
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
          Text(
            'Bugünkü Özet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appDarkText,
            ),
          ),
          const SizedBox(height: 12),
          const SummaryCard(
            title: 'Toplam Çocuk',
            value: '5',
            icon: Icons.groups,
          ),
          const SummaryCard(
            title: 'Bugün Girilen Rapor',
            value: '3',
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