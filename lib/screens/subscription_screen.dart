import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/subscription_service.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  Future<void> openWhatsApp() async {
    final uri = Uri.parse(
      'https://wa.me/919810365166?text=Hello%20I%20want%20to%20upgrade%20my%20subscription',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';

    final date = timestamp.toDate();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int calculateDaysRemaining(Timestamp? endDateTimestamp) {
    if (endDateTimestamp == null) return 0;

    final endDate = endDateTimestamp.toDate();
    final difference = endDate.difference(DateTime.now()).inDays;

    return difference < 0 ? 0 : difference;
  }

  Widget planCard({
    required String title,
    required String details,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(details),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: const Text('Upgrade'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscription')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: SubscriptionService().getSubscription(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text('No Subscription Found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final supplierId = data['supplierId'] as String?;

          if (supplierId != null && supplierId.isNotEmpty) {
            SubscriptionService().markExpiredIfNeeded(supplierId);
          }

          final startDate = data['startDate'] as Timestamp?;
          final endDate = data['endDate'] as Timestamp?;

          final daysRemaining = calculateDaysRemaining(endDate);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Current Plan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data['planName'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Status: ${data['status']}'),
                        Text('Retailer Limit: ${data['retailerLimit']}'),
                        Text(
                          'Connected Retailers: ${data['connectedRetailers']}',
                        ),
                        const Divider(height: 30),
                        Text('Start Date: ${formatDate(startDate)}'),
                        Text('Expiry Date: ${formatDate(endDate)}'),
                        const SizedBox(height: 8),
                        Text(
                          'Days Remaining: $daysRemaining',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Card(
                  color: Colors.amber.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'After Free Trial Expiry',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('• Existing retailers remain connected'),
                        Text('• Existing orders remain accessible'),
                        Text('• New retailer connections are blocked'),
                        Text('• Retailers can view catalogue'),
                        Text('• New orders require an active paid plan'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Available Plans',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 10),

                const Card(
                  child: ListTile(
                    title: Text(
                      'Free Trial',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('5 Retailers • Free for 60 Days'),
                  ),
                ),

                planCard(
                  title: 'Starter',
                  details: '10 Retailers • ₹999/month',
                  onTap: openWhatsApp,
                ),

                planCard(
                  title: 'Growth ⭐ Most Popular',
                  details: '15 Retailers • ₹1499/month',
                  onTap: openWhatsApp,
                ),

                planCard(
                  title: 'Business',
                  details: '20 Retailers • ₹1999/month',
                  onTap: openWhatsApp,
                ),

                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Need Plan Upgrade?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          onPressed: openWhatsApp,
                          icon: const Icon(Icons.support_agent),
                          label: const Text('Upgrade via WhatsApp'),
                        ),

                        const SizedBox(height: 10),

                        const SelectableText(
                          '+91 9810365166',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
