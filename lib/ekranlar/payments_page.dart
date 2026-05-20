import 'package:flutter/material.dart';

import '../app_colors.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  final List<Map<String, String>> payments = const [
    {
      'month': 'Mayıs 2026',
      'amount': '6000 TL',
      'status': 'Ödendi',
    },
    {
      'month': 'Haziran 2026',
      'amount': '6000 TL',
      'status': 'Bekliyor',
    },
    {
      'month': 'Temmuz 2026',
      'amount': '6000 TL',
      'status': 'Bekliyor',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme Takibi')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          final isPaid = payment['status'] == 'Ödendi';

          return Card(
            child: ListTile(
              leading: Icon(
                isPaid ? Icons.check_circle : Icons.pending,
                color: isPaid ? appGreen : appOrange,
              ),
              title: Text(payment['month']!),
              subtitle: Text('Tutar: ${payment['amount']}'),
              trailing: Text(
                payment['status']!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPaid ? appGreen : appOrange,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}