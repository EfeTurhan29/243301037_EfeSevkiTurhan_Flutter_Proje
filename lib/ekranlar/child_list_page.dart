import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../user_role.dart';
import 'child_detail_page.dart';

class ChildListPage extends StatelessWidget {
  final UserRole role;

  const ChildListPage({super.key, required this.role});

  final List<String> children = const [
    'Nazlıcan Altın',
    'Efe Şevki',
    'Metehan Turhan',
    'Seyit Eren',
    'Mehmet Emin',
  ];

  @override
  Widget build(BuildContext context) {
    final visibleChildren =
        role == UserRole.parent ? ['Nazlıcan Altın'] : children;

    return Scaffold(
      appBar: AppBar(title: const Text('öğrenci Listesi')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: visibleChildren.length,
        itemBuilder: (context, index) {
          final childName = visibleChildren[index];

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: appLightBlue,
                child: Icon(Icons.face, color: appBlue,),
              ),
              title: Text(childName),
              subtitle: const Text('Papatyalar sınıfı'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChildDetailPage(
                      role: role,
                      childName: childName,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}