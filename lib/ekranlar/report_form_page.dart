import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../log_service.dart';

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
  final supabase = Supabase.instance.client;

  final foodController = TextEditingController();
  final sleepController = TextEditingController();
  final moodController = TextEditingController();
  final activityController = TextEditingController();
  final relationController = TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    foodController.text = 'Yemeğini düzenli yedi.';
    sleepController.text = '1 saat uyudu.';
    moodController.text = 'Neşeli ve sakin.';
    activityController.text = 'Boyama etkinliğine katıldı.';
    relationController.text = 'Arkadaşlarıyla uyumlu iletişim kurdu.';
  }

  Future<void> saveReport() async {
  setState(() {
    isSaving = true;
  });

  try {
    await supabase.from('daily_reports').insert({
      'child_id': widget.childId,
      'report_date': DateTime.now().toIso8601String().substring(0, 10),
      'food_status': foodController.text.trim(),
      'sleep_status': sleepController.text.trim(),
      'mood_status': moodController.text.trim(),
      'activity_note': activityController.text.trim(),
      'relation_note': relationController.text.trim(),
    });

    await LogService.addLog(
      action: 'report_insert',
      description: '${widget.childName} için günlük rapor eklendi.',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Günlük rapor Supabase veritabanına kaydedildi.'),
      ),
    );

    Navigator.pop(context);
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rapor kaydedilirken hata oluştu: $error'),
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
            onPressed: isSaving ? null : saveReport,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(isSaving ? 'Kaydediliyor...' : 'Raporu Kaydet'),
          ),
        ],
      ),
    );
  }
}