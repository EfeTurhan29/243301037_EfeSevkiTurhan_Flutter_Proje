import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_colors.dart';
import '../user_role.dart';
import '../widgets/home_menu_card.dart';
import '../widgets/summary_card.dart';

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
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final todayText = today.toIso8601String().substring(0, 10);

    final childrenResponse = await supabase.from('children').select('id');

    final reportsResponse = await supabase
        .from('daily_reports')
        .select('id')
        .eq('report_date', todayText);

    final paymentsResponse = await supabase
        .from('payments')
        .select('id, status, due_date')
        .eq('status', 'Bekliyor');

    final paymentList = List<Map<String, dynamic>>.from(paymentsResponse);

    int pendingCount = 0;
    int overdueCount = 0;

    for (final payment in paymentList) {
      final dueDateValue = payment['due_date'];

      if (dueDateValue == null) {
        pendingCount++;
        continue;
      }

      final dueDate = DateTime.tryParse(dueDateValue.toString());

      if (dueDate == null) {
        pendingCount++;
        continue;
      }

      final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

      if (dueDateOnly.isBefore(todayOnly)) {
        overdueCount++;
      } else {
        pendingCount++;
      }
    }

    setState(() {
      totalChildren = List.from(childrenResponse).length;
      todayReports = List.from(reportsResponse).length;
      pendingPayments = pendingCount;
      overduePayments = overdueCount;
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