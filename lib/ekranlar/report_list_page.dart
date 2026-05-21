import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_colors.dart';
import '../user_role.dart';
import 'child_detail_page.dart';

class ReportListPage extends StatefulWidget {
  final UserRole role;

  const ReportListPage({super.key, required this.role});

  @override
  State<ReportListPage> createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> children = [];
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    fetchReportData();
  }

  Future<void> fetchReportData() async {
    try {
      final childrenResponse = await supabase
          .from('children')
          .select('id, full_name, classroom')
          .order('full_name', ascending: true);

      final reportsResponse = await supabase
          .from('daily_reports')
          .select(
            'id, child_id, report_date, created_at, food_status, sleep_status, mood_status, activity_note, relation_note',
          )
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> loadedChildren =
          List<Map<String, dynamic>>.from(childrenResponse);

      
      if (widget.role == UserRole.parent) {
        final userId = supabase.auth.currentUser?.id;

        if (userId == null) {
          loadedChildren = [];
        } else {
          final relationResponse = await supabase
              .from('child_parents')
              .select('child_id')
              .eq('parent_id', userId);

          final childIds = List<Map<String, dynamic>>.from(relationResponse)
              .map((relation) => relation['child_id'].toString())
              .toSet();

          loadedChildren = loadedChildren
              .where((child) => childIds.contains(child['id'].toString()))
              .toList();
        }
      }

      setState(() {
        children = loadedChildren;
        reports = List<Map<String, dynamic>>.from(reportsResponse);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Günlük raporlar alınırken hata oluştu: $error';
        isLoading = false;
      });
    }
  }

  Map<String, dynamic>? getLatestReportForChild(String childId) {
    final childReports = reports
        .where((report) => report['child_id'] == childId)
        .toList();

    if (childReports.isEmpty) {
      return null;
    }

    return childReports.first;
  }

  String getReportValue(
    Map<String, dynamic>? report,
    String key,
    String emptyText,
  ) {
    if (report == null) {
      return emptyText;
    }

    final value = report[key];

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
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Günlük Raporlar')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Günlük Raporlar')),
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
      appBar: AppBar(title: const Text('Günlük Raporlar')),
      body: RefreshIndicator(
        onRefresh: fetchReportData,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            final childId = child['id'];
            final childName = child['full_name'] ?? 'İsimsiz Öğrenci';
            final classroom = child['classroom'] ?? 'Sınıf bilgisi yok';
            final latestReport = getLatestReportForChild(childId);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                initiallyExpanded: index == 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: CircleAvatar(
                  backgroundColor: appLightBlue,
                  child: Icon(Icons.assignment, color: appBlue),
                ),
                title: Text(
                  childName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: appDarkText,
                  ),
                ),
                subtitle: Text(
                  latestReport == null
                      ? '$classroom | Henüz rapor yok'
                      : '$classroom | Son rapor: ${formatDate(latestReport['report_date'])}',
                ),
                children: [
                  if (latestReport == null)
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Bu öğrenci için henüz rapor girilmemiş.'),
                    )
                  else ...[
                    ReportMiniInfo(
                      icon: Icons.restaurant,
                      title: 'Yemek Durumu',
                      value: getReportValue(
                        latestReport,
                        'food_status',
                        'Yemek bilgisi girilmemiş.',
                      ),
                    ),
                    ReportMiniInfo(
                      icon: Icons.bedtime,
                      title: 'Uyku Durumu',
                      value: getReportValue(
                        latestReport,
                        'sleep_status',
                        'Uyku bilgisi girilmemiş.',
                      ),
                    ),
                    ReportMiniInfo(
                      icon: Icons.mood,
                      title: 'Ruh Hali',
                      value: getReportValue(
                        latestReport,
                        'mood_status',
                        'Ruh hali bilgisi girilmemiş.',
                      ),
                    ),
                    ReportMiniInfo(
                      icon: Icons.palette,
                      title: 'Etkinlik Notu',
                      value: getReportValue(
                        latestReport,
                        'activity_note',
                        'Etkinlik notu girilmemiş.',
                      ),
                    ),
                    ReportMiniInfo(
                      icon: Icons.groups,
                      title: 'Öğrencilerle İlişkileri',
                      value: getReportValue(
                        latestReport,
                        'relation_note',
                        'İlişki notu girilmemiş.',
                      ),
                    ),
                  ],
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChildDetailPage(
                                role: widget.role,
                                childId: childId,
                                childName: childName,
                              ),
                            ),
                          );

                          fetchReportData();
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Rapor detayını aç'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ReportMiniInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ReportMiniInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: appBlue),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}