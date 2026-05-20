import 'package:flutter/material.dart';

class ReportFormPage extends StatefulWidget {
  final String childId;
  final String childName;

  const ReportFormPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<ReportFormPage> createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final foodController = TextEditingController();
  final sleepController = TextEditingController();
  final moodController = TextEditingController();
  final activityController = TextEditingController();
  final relationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    foodController.text = 'Yemeğini düzenli yedi.';
    sleepController.text = '1 saat uyudu.';
    moodController.text = 'Neşeli ve sakin.';
    activityController.text = 'Boyama etkinliğine katıldı.';
    relationController.text = 'Arkadaşlarıyla uyumlu iletişim kurdu.';
  }

  void saveReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Günlük rapor kaydedildi. Sonraki adımda Supabase’e gönderilecek.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.childName} Rapor Ekle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: foodController,
            decoration: const InputDecoration(
              labelText: 'Yemek Durumu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: sleepController,
            decoration: const InputDecoration(
              labelText: 'Uyku Durumu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: moodController,
            decoration: const InputDecoration(
              labelText: 'Ruh Hali',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: activityController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Etkinlik Notu',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: relationController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Öğrencilerle İlişkileri',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: saveReport,
            icon: const Icon(Icons.save),
            label: const Text('Raporu Kaydet'),
          ),
        ],
      ),
    );
  }
}