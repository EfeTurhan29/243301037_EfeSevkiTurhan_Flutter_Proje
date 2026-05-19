import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../user_role.dart';
import 'report_form_page.dart';


class ChildDetailPage extends StatelessWidget {
  final UserRole role;
  final String childName;

  const ChildDetailPage({
    super.key,
    required this.role,
    required this.childName,
  });
//rapor sayfası
  @override
  Widget build(BuildContext context) {
    final isTeacher = role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(title: Text(childName)),
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportFormPage(childName: childName),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Rapor Ekle'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: appBlue),
              //rapor ekranı ünlem icon
              title: Text(childName),
              subtitle: const Text('Yaş: 5 | Sınıf: Papatyalar'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Günlük Rapor',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const ReportInfoCard(
            title: 'Yemek Durumu',
            value: 'Öğle yemeğini büyük ölçüde yedi.',
            icon: Icons.restaurant,
          ),
          const ReportInfoCard(
            title: 'Uyku Durumu',
            value: '1 saat uyudu.',
            icon: Icons.bedtime,
          ),
          const ReportInfoCard(
            title: 'Ruh Hali',
            value: 'Gün içinde neşeli ve uyumluydu.',
            icon: Icons.mood,
          ),
          const ReportInfoCard(
            title: 'Etkinlik Notu',
            value: 'Boyama ve hikaye etkinliğine katıldı.',
            icon: Icons.palette,
          ),
          const ReportInfoCard(
            title: 'Öğrencilerle İlişkileri',
            value: 'Bugün içine kapanıkdı , sosyalleşmek istemedi.',
            icon: Icons.forum,
          )
        ],
      ),
    );
  }
}

class ReportInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ReportInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: appBlue),
        //günlük rapor iconlar
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}