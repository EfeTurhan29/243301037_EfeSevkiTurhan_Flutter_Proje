import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChildFormPage extends StatefulWidget {
  final Map<String, dynamic>? existingChild;

  const ChildFormPage({
    super.key,
    this.existingChild,
  });

  @override
  State<ChildFormPage> createState() => _ChildFormPageState();
}

class _ChildFormPageState extends State<ChildFormPage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final classroomController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final parentNameController = TextEditingController();
  final parentPhoneController = TextEditingController();
  final allergyController = TextEditingController();
  final noteController = TextEditingController();

  bool isSaving = false;

  bool get isEditMode => widget.existingChild != null;

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final child = widget.existingChild!;

      nameController.text = child['full_name']?.toString() ?? '';
      ageController.text = child['age']?.toString() ?? '';
      classroomController.text = child['classroom']?.toString() ?? '';
      heightController.text = child['height_cm']?.toString() ?? '';
      weightController.text = child['weight_kg']?.toString() ?? '';
      parentNameController.text = child['parent_name']?.toString() ?? '';
      parentPhoneController.text = child['parent_phone']?.toString() ?? '';
      allergyController.text = child['allergy_info']?.toString() ?? '';
      noteController.text = child['note']?.toString() ?? '';
    }
  }

  String getTurkishMonthName(int month) {
  const months = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  return months[month - 1];
}

Map<String, dynamic> createPaymentData(String childId, DateTime monthDate) {
  final dueDate = DateTime(monthDate.year, monthDate.month + 1, 0);

  return {
    'child_id': childId,
    'month': '${getTurkishMonthName(monthDate.month)} ${monthDate.year}',
    'amount': 6000,
    'status': 'Bekliyor',
    'payment_date': null,
    'due_date': dueDate.toIso8601String().substring(0, 10),
  };
}

Future<void> createDefaultPaymentsForChild(String childId) async {
  final now = DateTime.now();

  final currentMonth = DateTime(now.year, now.month, 1);
  final nextMonth = DateTime(now.year, now.month + 1, 1);

  await supabase.from('payments').insert([
    createPaymentData(childId, currentMonth),
    createPaymentData(childId, nextMonth),
  ]);
}
  
  Future<void> saveChild() async {
    if (nameController.text.trim().isEmpty ||
        ageController.text.trim().isEmpty ||
        classroomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad soyad, yaş ve sınıf alanları boş bırakılamaz.'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    final childData = {
      'full_name': nameController.text.trim(),
      'age': int.tryParse(ageController.text.trim()),
      'classroom': classroomController.text.trim(),
      'height_cm': int.tryParse(heightController.text.trim()),
      'weight_kg': double.tryParse(
        weightController.text.trim().replaceAll(',', '.'),
      ),
      'parent_name': parentNameController.text.trim(),
      'parent_phone': parentPhoneController.text.trim(),
      'allergy_info': allergyController.text.trim(),
      'note': noteController.text.trim(),
    };

    try {
      if (isEditMode) {
        await supabase
            .from('children')
            .update(childData)
            .eq('id', widget.existingChild!['id']);
      } else {
        final insertedChild = await supabase
            .from('children')
            .insert(childData)
            .select('id')
            .single();

      final childId = insertedChild['id'];

      await createDefaultPaymentsForChild(childId);
    }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Öğrenci bilgileri güncellendi.'
                : 'Öğrenci başarıyla eklendi.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem sırasında hata oluştu: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Öğrenci Düzenle' : 'Öğrenci Ekle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Öğrenci Ad Soyad',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Yaş',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.cake),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: classroomController,
            decoration: const InputDecoration(
              labelText: 'Sınıf',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.class_),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Boy cm',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.height),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Kilo kg',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.monitor_weight),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: parentNameController,
            decoration: const InputDecoration(
              labelText: 'Veli Ad Soyad',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.family_restroom),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: parentPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Veli Telefon',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: allergyController,
            decoration: const InputDecoration(
              labelText: 'Alerji Bilgisi',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.health_and_safety),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: noteController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Genel Not',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note_alt),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: isSaving ? null : saveChild,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              isSaving
                  ? 'Kaydediliyor...'
                  : isEditMode
                      ? 'Bilgileri Güncelle'
                      : 'Öğrenciyi Kaydet',
            ),
          ),
        ],
      ),
    );
  }
}