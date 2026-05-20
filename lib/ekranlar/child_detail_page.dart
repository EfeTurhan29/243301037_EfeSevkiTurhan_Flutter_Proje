import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_colors.dart';
import '../user_role.dart';
import 'report_form_page.dart';

class ChildDetailPage extends StatefulWidget {
  final UserRole role;
  final String childId;
  final String childName;

  const ChildDetailPage({
    super.key,
    required this.role,
    required this.childId,
    required this.childName,
  });

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? report;

  @override
  void initState() {
    super.initState();
    fetchDailyReport();
  }

  Future<void> fetchDailyReport() async {
    try {
      final response = await supabase
          .from('daily_reports')
          .select(
            'id, report_date, food_status, sleep_status, mood_status, activity_note, relation_note',
          )
          .eq('child_id', widget.childId)
          .order('report_date', ascending: false)
          .limit(1);

      final reports = List<Map<String, dynamic>>.from(response);

      setState(() {
        report = reports.isNotEmpty ? reports.first : null;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Günlük rapor alınırken hata oluştu: $error';
        isLoading = false;
      });
    }
  }

  String getReportValue(String key, String emptyText) {
    if (report == null) {
      return emptyText;
    }

    final value = report![key];

    if (value == null || value.toString().trim().isEmpty) {
      return emptyText;
    }

    return value.toString();
  }

  String formatDate(dynamic dateValue) {
    if (dateValue == null) {
      return 'Tarih bilgisi yok';
    }

    final date = DateTime.tryParse(dateValue.toString());

    if (date == null) {
      return 'Tarih bilgisi yok';
    }

    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(title: Text(widget.childName)),
      floatingActionButton: isTeacher
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportFormPage(
                      childId: widget.childId,
                      childName: widget.childName,
                    ),
                  ),
                );

                fetchDailyReport();
              },
              icon: const Icon(Icons.add),
              label: const Text('Rapor Ekle'),
            )
          : null,
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (report == null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.info, color: appBlue),
              title: Text(widget.childName),
              subtitle: const Text('Bu öğrenci için henüz günlük rapor yok.'),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.info, color: appBlue),
            title: Text(widget.childName),
            subtitle: Text(
              'Rapor Tarihi: ${formatDate(report!['report_date'])}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Günlük Rapor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: appDarkText,
          ),
        ),
        const SizedBox(height: 8),
        ReportInfoCard(
          title: 'Yemek Durumu',
          value: getReportValue(
            'food_status',
            'Yemek bilgisi girilmemiş.',
          ),
          icon: Icons.restaurant,
        ),
        ReportInfoCard(
          title: 'Uyku Durumu',
          value: getReportValue(
            'sleep_status',
            'Uyku bilgisi girilmemiş.',
          ),
          icon: Icons.bedtime,
        ),
        ReportInfoCard(
          title: 'Ruh Hali',
          value: getReportValue(
            'mood_status',
            'Ruh hali bilgisi girilmemiş.',
          ),
          icon: Icons.mood,
        ),
        ReportInfoCard(
          title: 'Etkinlik Notu',
          value: getReportValue(
            'activity_note',
            'Etkinlik notu girilmemiş.',
          ),
          icon: Icons.palette,
        ),
        ReportInfoCard(
          title: 'Öğrencilerle İlişkileri',
          value: getReportValue(
            'relation_note',
            'İlişki notu girilmemiş.',
          ),
          icon: Icons.groups,
        ),
      ],
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
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}