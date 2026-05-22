import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../user_role.dart';
import '../widgets/home_menu_card.dart';
import '../widgets/summary_card.dart';
import '../log_service.dart';

import 'child_list_page.dart';
import 'payments_page.dart';
import 'profile_page.dart';
import 'report_list_page.dart';

class HomePage extends StatefulWidget {
  final UserRole role;

  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  bool isLoadingSummary = true;
  int totalChildren = 0;
  int todayReports = 0;
  int pendingPayments = 0;
  int overduePayments = 0;

  @override
  void initState() {
    super.initState();
    fetchSummaryData();
  }

  Future<void> fetchSummaryData() async {
  try {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    List<String>? parentChildIds;

    if (widget.role == UserRole.parent) {
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() {
          totalChildren = 0;
          todayReports = 0;
          pendingPayments = 0;
          overduePayments = 0;
          isLoadingSummary = false;
        });
        return;
      }

      final relationResponse = await supabase
          .from('child_parents')
          .select('child_id')
          .eq('parent_id', userId);

      parentChildIds = List<Map<String, dynamic>>.from(relationResponse)
          .map((relation) => relation['child_id'].toString())
          .toList();
    }

    var childrenQuery = supabase.from('children').select('id');
    var reportsQuery = supabase
        .from('daily_reports')
        .select('id, child_id')
        .eq('report_date', today);
    var paymentsQuery = supabase
        .from('payments')
        .select('id, child_id, status, due_date');

    final childrenResponse = await childrenQuery;
    final reportsResponse = await reportsQuery;
    final paymentsResponse = await paymentsQuery;

    List<Map<String, dynamic>> loadedChildren =
        List<Map<String, dynamic>>.from(childrenResponse);

    List<Map<String, dynamic>> loadedReports =
        List<Map<String, dynamic>>.from(reportsResponse);

    List<Map<String, dynamic>> loadedPayments =
        List<Map<String, dynamic>>.from(paymentsResponse);

    if (widget.role == UserRole.parent) {
      final childIdSet = parentChildIds?.toSet() ?? {};

      loadedChildren = loadedChildren
          .where((child) => childIdSet.contains(child['id'].toString()))
          .toList();

      loadedReports = loadedReports
          .where((report) => childIdSet.contains(report['child_id'].toString()))
          .toList();

      loadedPayments = loadedPayments
          .where((payment) => childIdSet.contains(payment['child_id'].toString()))
          .toList();
    }

    final pendingList = loadedPayments.where((payment) {
      final status = payment['status']?.toString() ?? '';
      final dueDateText = payment['due_date']?.toString();

      if (status == 'Ödendi') {
        return false;
      }

      if (dueDateText == null) {
        return status == 'Bekliyor';
      }

      final dueDate = DateTime.tryParse(dueDateText);

      if (dueDate == null) {
        return status == 'Bekliyor';
      }

      return !dueDate.isBefore(DateTime.parse(today));
    }).toList();

    final overdueList = loadedPayments.where((payment) {
      final status = payment['status']?.toString() ?? '';
      final dueDateText = payment['due_date']?.toString();

      if (status == 'Ödendi' || dueDateText == null) {
        return false;
      }

      final dueDate = DateTime.tryParse(dueDateText);

      if (dueDate == null) {
        return false;
      }

      return dueDate.isBefore(DateTime.parse(today));
    }).toList();

    setState(() {
      totalChildren = loadedChildren.length;
      todayReports = loadedReports.length;
      pendingPayments = pendingList.length;
      overduePayments = overdueList.length;
      isLoadingSummary = false;
    });
  } catch (error) {
    setState(() {
      isLoadingSummary = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final isTeacher = widget.role == UserRole.teacher;

    return Scaffold(
      appBar: AppBar(
        title: Text(isTeacher ? 'Öğretmen Paneli' : 'Veli Paneli'),
        actions: [
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('remember_me', false);
              
              await LogService.addLog(
                action: 'logout',
                description: 'Kullanıcı ana sayfadan çıkış yaptı.',
              );
              
              await Supabase.instance.client.auth.signOut();

              if (!context.mounted) return;

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
      body: RefreshIndicator(
        onRefresh: fetchSummaryData,
        child: ListView(
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
                  title: 'Öğrenciler',
                  icon: Icons.contacts_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildListPage(role: widget.role),
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
                        builder: (_) => ReportListPage(role: widget.role),
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
                        builder: (_) => PaymentsPage(role: widget.role),
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
                        builder: (_) => ProfilePage(role: widget.role),
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
            SummaryCard(
              title: 'Toplam Çocuk',
              value: isLoadingSummary ? '...' : totalChildren.toString(),
              icon: Icons.groups,
              color: appBlue,
            ),
            SummaryCard(
              title: 'Bugün Girilen Rapor',
              value: isLoadingSummary ? '...' : todayReports.toString(),
              icon: Icons.note_alt,
              color: appBlue,
            ),
            SummaryCard(
              title: 'Bekleyen Ödeme',
              value: isLoadingSummary ? '...' : pendingPayments.toString(),
              icon: Icons.warning_amber,
              color: appOrange,
            ),
            SummaryCard(
              title: 'Gecikmiş Ödeme',
              value: isLoadingSummary ? '...' : overduePayments.toString(), 
              icon: Icons.error,
              color: appRed,
            )          
          ],
        ),
      ),
    );
  }
}