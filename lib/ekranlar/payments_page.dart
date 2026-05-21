import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app_colors.dart';
import '../user_role.dart';

class PaymentsPage extends StatefulWidget {
  final UserRole role;

  const PaymentsPage({super.key, required this.role});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final supabase = Supabase.instance.client;

  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> payments = [];

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  Future<void> fetchPayments() async {
    try {
      final response = await supabase
          .from('payments')
          .select(
            'id, child_id, month, amount, status, payment_date, due_date, children(full_name)',
          )
          .order('due_date', ascending: true);

      List<Map<String, dynamic>> loadedPayments =
          List<Map<String, dynamic>>.from(response);

      
      if (widget.role == UserRole.parent) {
        final userId = supabase.auth.currentUser?.id;

        if (userId == null) {
          loadedPayments = [];
        } else {
          final relationResponse = await supabase
              .from('child_parents')
              .select('child_id')
              .eq('parent_id', userId);

          final childIds = List<Map<String, dynamic>>.from(relationResponse)
              .map((relation) => relation['child_id'].toString())
              .toSet();

          loadedPayments = loadedPayments
              .where((payment) => childIds.contains(payment['child_id'].toString()))
              .toList();
          }
        }

      setState(() {
        payments = loadedPayments;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Ödeme bilgileri alınırken hata oluştu: $error';
        isLoading = false;
      });
    }
  }

  Future<void> payPayment(Map<String, dynamic> payment) async {
  final paymentId = payment['id'];

  if (paymentId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ödeme kaydı bulunamadı.'),
      ),
    );
    return;
  }

  try {
    final today = DateTime.now().toIso8601String().substring(0, 10);

    await supabase.from('payments').update({
      'status': 'Ödendi',
      'payment_date': today,
    }).eq('id', paymentId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ödeme başarıyla yapıldı.'),
      ),
    );

    fetchPayments();
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ödeme yapılırken hata oluştu: $error'),
      ),
    );
  }
}

  String formatAmount(dynamic amount) {
    if (amount is num) {
      return '${amount.toStringAsFixed(0)} TL';
    }

    return '$amount TL';
  }

  String formatDate(dynamic dateValue) {
    if (dateValue == null) {
      return 'Son ödeme tarihi yok';
    }

    final date = DateTime.tryParse(dateValue.toString());

    if (date == null) {
      return 'Son ödeme tarihi yok';
    }

    return '${date.day}.${date.month}.${date.year}';
  }

  bool isPaymentOverdue(String status, dynamic dueDateValue) {
    if (status == 'Ödendi') {
      return false;
    }

    if (dueDateValue == null) {
      return false;
    }

    final dueDate = DateTime.tryParse(dueDateValue.toString());

    if (dueDate == null) {
      return false;
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    return dueDateOnly.isBefore(todayOnly);
  }

  Map<String, List<Map<String, dynamic>>> groupPaymentsByChild() {
    final Map<String, List<Map<String, dynamic>>> groupedPayments = {};

    for (final payment in payments) {
      final childData = payment['children'];

      final childName = childData != null
          ? childData['full_name'] ?? 'Öğrenci bilgisi yok'
          : 'Öğrenci bilgisi yok';

      if (!groupedPayments.containsKey(childName)) {
        groupedPayments[childName] = [];
      }

      groupedPayments[childName]!.add(payment);
    }

    return groupedPayments;
  }

  Color getStatusColor(String status, dynamic dueDate) {
    final isPaid = status == 'Ödendi';
    final isOverdue = isPaymentOverdue(status, dueDate);

    if (isPaid) {
      return appGreen;
    }

    if (isOverdue) {
      return appRed;
    }

    return appOrange;
  }

  IconData getStatusIcon(String status, dynamic dueDate) {
    final isPaid = status == 'Ödendi';
    final isOverdue = isPaymentOverdue(status, dueDate);

    if (isPaid) {
      return Icons.check_circle;
    }

    if (isOverdue) {
      return Icons.error;
    }

    return Icons.pending;
  }

  String getStatusText(String status, dynamic dueDate) {
    final isOverdue = isPaymentOverdue(status, dueDate);

    if (isOverdue) {
      return 'Gecikmiş';
    }

    return status;
  }

  int getOverdueCount(List<Map<String, dynamic>> childPayments) {
    return childPayments.where((payment) {
      final status = payment['status'] ?? 'Bilinmiyor';
      final dueDate = payment['due_date'];

      return isPaymentOverdue(status, dueDate);
    }).length;
  }

  int getPendingCount(List<Map<String, dynamic>> childPayments) {
    return childPayments.where((payment) {
      final status = payment['status'] ?? 'Bilinmiyor';
      final dueDate = payment['due_date'];

      return status != 'Ödendi' && !isPaymentOverdue(status, dueDate);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ödeme Takibi')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ödeme Takibi')),
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

    if (payments.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ödeme Takibi')),
        body: const Center(
          child: Text('Henüz ödeme kaydı bulunmuyor.'),
        ),
      );
    }

    final groupedPayments = groupPaymentsByChild();
    final childNames = groupedPayments.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme Takibi')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: childNames.length,
        itemBuilder: (context, index) {
          final childName = childNames[index];
          final childPayments = groupedPayments[childName] ?? [];

          final overdueCount = getOverdueCount(childPayments);
          final pendingCount = getPendingCount(childPayments);

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
                child: Icon(Icons.person, color: appBlue),
              ),
              title: Text(
                childName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: appDarkText,
                ),
              ),
              subtitle: Text(
                '${childPayments.length} ödeme kaydı'
                '${pendingCount > 0 ? ' | $pendingCount bekleyen' : ''}'
                '${overdueCount > 0 ? ' | $overdueCount gecikmiş' : ''}',
              ),
              children: childPayments.map((payment) {
                final month = payment['month'] ?? 'Ay bilgisi yok';
                final amount = formatAmount(payment['amount']);
                final status = payment['status'] ?? 'Bilinmiyor';
                final dueDate = payment['due_date'];

                final statusColor = getStatusColor(status, dueDate);
                final statusIcon = getStatusIcon(status, dueDate);
                final statusText = getStatusText(status, dueDate);

                return ListTile(
                  leading: Icon(
                    statusIcon,
                    color: statusColor,
                  ),
                  title: Text(month),
                  subtitle: Text(
                    'Tutar: $amount\nSon ödeme: ${formatDate(dueDate)}',
                  ),
                  trailing: widget.role == UserRole.parent && status != 'Ödendi'
                      ? TextButton.icon(
                          onPressed: () {
                            payPayment(payment);
                          },
                          icon: const Icon(Icons.payment),
                          label: const Text('Öde'),
                        )
                      : Text(
                          statusText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}