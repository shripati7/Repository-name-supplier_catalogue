import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/subscription_service.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

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
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  await SubscriptionService().createFreeSubscription();

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Free Subscription Activated'),
                    ),
                  );
                },
                child: const Text('Activate Free Plan'),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: ListTile(
                title: Text('Plan: ${data['planName']}'),
                subtitle: Text('Status: ${data['status']}'),
              ),
            ),
          );
        },
      ),
    );
  }
}
