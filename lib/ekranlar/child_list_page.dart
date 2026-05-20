import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_colors.dart';
import '../user_role.dart';
import 'child_info_page.dart';

class ChildListPage extends StatefulWidget {
  final UserRole role;

  const ChildListPage({super.key, required this.role});

  @override
  State<ChildListPage> createState() => _ChildListPageState();
}

class _ChildListPageState extends State<ChildListPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> children = [];

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    try {
      final response = await supabase
          .from('children')
          .select('id, full_name, age, classroom')
          .order('full_name', ascending: true);

      List<Map<String, dynamic>> loadedChildren =
          List<Map<String, dynamic>>.from(response);

      // Veli rolündeyse örnek olarak sadece Nazlıcan Altın görünsün.
      if (widget.role == UserRole.parent) {
        loadedChildren = loadedChildren
            .where((child) => child['full_name'] == 'Nazlıcan Altın')
            .toList();
      }

      setState(() {
        children = loadedChildren;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Çocuk listesi alınırken hata oluştu: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Öğrenci Listesi')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Öğrenci Listesi')),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Öğrenci Listesi')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final childName = child['full_name'] ?? 'İsimsiz Öğrenci';
          final classroom = child['classroom'] ?? 'Sınıf bilgisi yok';
          final age = child['age']?.toString() ?? '-';

          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: appLightBlue,
                child: Icon(Icons.face, color: appBlue),
              ),
              title: Text(childName),
              subtitle: Text('$classroom | Yaş: $age'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChildInfoPage(
                      childId: child['id'],
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