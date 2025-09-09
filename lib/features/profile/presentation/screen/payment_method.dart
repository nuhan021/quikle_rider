import 'package:flutter/material.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({Key? key}) : super(key: key);

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      name: 'Paytm',
      icon: Icons.account_balance_wallet,
      color: const Color(0xFF00BAF2),
      isRemovable: true,
    ),
    PaymentMethod(
      name: 'Google Pay',
      icon: Icons.g_translate,
      color: const Color(0xFF4285F4),
      isRemovable: true,
    ),
    PaymentMethod(
      name: 'PhonePe',
      icon: Icons.phone_android,
      color: const Color(0xFF5F259F),
      isRemovable: true,
    ),
    PaymentMethod(
      name: 'Cashfree',
      icon: Icons.attach_money,
      color: const Color(0xFF00D4AA),
      isRemovable: true,
    ),
    PaymentMethod(
      name: 'Razorpay',
      icon: Icons.payment,
      color: const Color(0xFF528FF0),
      isRemovable: true,
    ),
    PaymentMethod(
      name: 'Bank Transfer',
      icon: Icons.account_balance,
      color: Colors.grey[700]!,
      isRemovable: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment Method',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.yellow],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                return _buildPaymentMethodItem(paymentMethods[index]);
              },
            ),
          ),
          // Add New Payment Method Button
          Container(
            margin: const EdgeInsets.all(20),
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showAddPaymentMethodDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add New Payment Method',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem(PaymentMethod method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: method.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(method.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              method.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          if (method.isRemovable)
            GestureDetector(
              onTap: () => _showRemoveDialog(method),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.close, color: Colors.red, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  void _showRemoveDialog(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Payment Method'),
          content: Text('Are you sure you want to remove ${method.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  paymentMethods.remove(method);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${method.name} removed successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddPaymentMethodDialog() {
    final List<String> availableMethods = [
      'Credit Card',
      'Debit Card',
      'PayPal',
      'Apple Pay',
      'Samsung Pay',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: availableMethods.map((method) {
              return ListTile(
                title: Text(method),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$method will be added soon'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final Color color;
  final bool isRemovable;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.color,
    required this.isRemovable,
  });
}
