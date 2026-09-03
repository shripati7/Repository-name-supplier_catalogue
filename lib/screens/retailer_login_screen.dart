import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'my_orders_screen.dart';
import 'my_suppliers_screen.dart';
import 'retailer_catalogue_screen.dart';
import 'retailer_signup_screen.dart';

class RetailerLoginScreen extends StatefulWidget {
  const RetailerLoginScreen({super.key});

  @override
  State<RetailerLoginScreen> createState() => _RetailerLoginScreenState();
}

class _RetailerLoginScreenState extends State<RetailerLoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    try {
      setState(() => loading = true);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = FirebaseAuth.instance.currentUser!;

      final suppliers = await FirebaseFirestore.instance
          .collection('supplier_connections')
          .where('retailerId', isEqualTo: user.uid)
          .get();

      if (!mounted) return;

      if (suppliers.docs.isEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RetailerWaitingScreen()),
        );
        return;
      }

      if (suppliers.docs.length == 1) {
        final data = suppliers.docs.first.data();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RetailerCatalogueScreen(
              shopId: (data['supplierShopId'] ?? '').toString(),
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MySuppliersScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login Failed')));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retailer Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: Text(loading ? 'Please Wait...' : 'Login'),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RetailerSignupScreen(),
                  ),
                );
              },
              child: const Text('Create New Retailer Account'),
            ),
          ],
        ),
      ),
    );
  }
}

class RetailerWaitingScreen extends StatefulWidget {
  const RetailerWaitingScreen({super.key});

  @override
  State<RetailerWaitingScreen> createState() => _RetailerWaitingScreenState();
}

class _RetailerWaitingScreenState extends State<RetailerWaitingScreen> {
  String retailerShopId = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadRetailerShopId();
  }

  Future<void> loadRetailerShopId() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('retailers')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      retailerShopId = (doc.data()?['retailerShopId'] ?? '').toString();
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> copyShopId() async {
    if (retailerShopId.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: retailerShopId));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Retailer Shop ID Copied')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting For Connection')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_top, size: 80),

                  const SizedBox(height: 20),

                  const Text(
                    'Your retailer profile has been created.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Please share your Retailer Shop ID with the supplier.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Retailer Shop ID',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 10),

                          SelectableText(
                            retailerShopId,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          ElevatedButton.icon(
                            onPressed: copyShopId,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy Shop ID'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyOrdersScreen(),
                          ),
                        );
                      },
                      child: const Text('My Orders'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
