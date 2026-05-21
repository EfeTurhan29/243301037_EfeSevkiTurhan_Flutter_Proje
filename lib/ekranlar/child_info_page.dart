import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_colors.dart';
import '../user_role.dart';
import '../log_service.dart';
import 'child_form_page.dart';

class ChildInfoPage extends StatefulWidget {
  final UserRole role;
  final String childId;
  final String childName;

  const ChildInfoPage({
    required this.role,
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildInfoPage> createState() => _ChildInfoPageState();
}

class _ChildInfoPageState extends State<ChildInfoPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? child;

  @override
  void initState() {
    super.initState();
    fetchChildInfo();
  }
  
    Future<void> deleteChild() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Öğrenciyi Sil'),
        content: Text(
          '${widget.childName} adlı öğrenciyi silmek istediğine emin misin? Bu öğrencinin rapor ve ödeme kayıtları da silinebilir.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Sil'),
          ),
        ],
      );
    },
  );

  if (confirm != true) {
    return;
  }

  try {
    await supabase.from('children').delete().eq('id', widget.childId);

    await LogService.addLog(
      action: 'child_delete',
      description: '${widget.childName} adlı öğrenci silindi.',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Öğrenci silindi.'),
      ),
    );

    Navigator.pop(context, true);
  } catch (error) {
    if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Öğrenci silinirken hata oluştu: $error'),
        ),
      );
    }
  } 

  Future<void> fetchChildInfo() async {
    try {
      final response = await supabase
          .from('children')
          .select(
            'id, full_name, age, classroom, height_cm, weight_kg, parent_name, parent_phone, allergy_info, note',
          )
          .eq('id', widget.childId)
          .single();

      setState(() {
        child = Map<String, dynamic>.from(response);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Öğrenci bilgileri alınırken hata oluştu: $error';
        isLoading = false;
      });
    }
  }
  

  String getValue(String key, String emptyText) {
    final value = child?[key];

    if (value == null || value.toString().trim().isEmpty) {
      return emptyText;
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.childName)),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.childName)),
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

    final fullName = getValue('full_name', 'İsimsiz Öğrenci');
    final age = getValue('age', '-');
    final classroom = getValue('classroom', 'Sınıf bilgisi yok');
    final height = getValue('height_cm', '-');
    final weight = getValue('weight_kg', '-');
    final parentName = getValue('parent_name', 'Veli bilgisi yok');
    final parentPhone = getValue('parent_phone', 'Telefon bilgisi yok');
    final allergyInfo = getValue('allergy_info', 'Alerji bilgisi yok');
    final note = getValue('note', 'Not bilgisi yok');

    return Scaffold(
      appBar: AppBar(title: Text(fullName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: appLightBlue,
                    child: Icon(
                      Icons.face,
                      size: 42,
                      color: appBlue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: appDarkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classroom,
                          style: TextStyle(color: appDarkText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InfoCard(
            icon: Icons.cake,
            title: 'Yaş',
            value: '$age yaş',
          ),
          InfoCard(
            icon: Icons.height,
            title: 'Boy',
            value: '$height cm',
          ),
          InfoCard(
            icon: Icons.monitor_weight,
            title: 'Kilo',
            value: '$weight kg',
          ),
          InfoCard(
            icon: Icons.family_restroom,
            title: 'Veli',
            value: parentName,
          ),
          InfoCard(
            icon: Icons.phone,
            title: 'Veli Telefon',
            value: parentPhone,
          ),
          InfoCard(
            icon: Icons.health_and_safety,
            title: 'Alerji Bilgisi',
            value: allergyInfo,
          ),
          InfoCard(
            icon: Icons.note_alt,
            title: 'Genel Not',
            value: note,
          ),
          if (widget.role == UserRole.teacher) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChildFormPage(
                      existingChild: child,
                    ),
                  ),
                );

                if (result == true) {
                  fetchChildInfo();
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Öğrenci Bilgilerini Düzenle'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: deleteChild,
              icon: const Icon(Icons.delete),
              label: const Text('Öğrenciyi Sil'),
            ),
          ],
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: appBlue),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}