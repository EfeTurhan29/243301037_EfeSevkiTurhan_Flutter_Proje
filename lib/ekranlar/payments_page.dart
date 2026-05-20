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
          .select('id, month, amount, status, payment_date, due_date, children(full_name)')
          .order('due_date', ascending: true);

      List<Map<String, dynamic>> loadedPayments =
        List<Map<String, dynamic>>.from(response);

      // Veli rolündeyse sadece kendi çocuğunun ödemeleri görünsün.
      // Şimdilik örnek veli çocuğu Nazlıcan Altın olarak ayarlandı.
      if (widget.role == UserRole.parent) {
        loadedPayments = loadedPayments.where((payment) {
          final childData = payment['children'];

          if (childData == null) {
            return false;
          }

          return childData['full_name'] == 'Nazlıcan Altın';
        }).toList();
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

    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme Takibi')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];

          final month = payment['month'] ?? 'Ay bilgisi yok';
          final amount = formatAmount(payment['amount']);
          final status = payment['status'] ?? 'Bilinmiyor';
          final dueDate = payment['due_date'];

          final childData = payment['children'];
          final childName = childData != null
              ? childData['full_name'] ?? 'Öğrenci bilgisi yok'
              : 'Öğrenci bilgisi yok';

          final isPaid = status == 'Ödendi';
          final isOverdue = isPaymentOverdue(status, dueDate);

          final statusColor = isPaid
              ? appGreen
              : isOverdue
                  ? appRed
                  : appOrange;

          final statusText = isOverdue ? 'Gecikmiş Ödeme' : status;

          return Card(
            child: ListTile(
              leading: Icon(
                isPaid
                    ? Icons.check_circle
                    : isOverdue
                        ? Icons.error
                        : Icons.pending,
                color: statusColor,
              ),
              title: Text(childName),
              subtitle: Text(
                '$month | Tutar: $amount\nSon ödeme: ${formatDate(dueDate)}',
              ),
              trailing: Text(
                statusText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}