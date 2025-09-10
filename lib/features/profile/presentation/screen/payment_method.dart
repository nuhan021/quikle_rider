// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      name: 'Paytm',
     imagepath: "assets/images/paytm.png",
    
      isRemovable: true,
    ),
    PaymentMethod(
      name: 'Google Pay',
     imagepath: "assets/images/googlepay.png",
    
      isRemovable: true,
    ),
    PaymentMethod(
      name: 'PhonePe',
     imagepath: "assets/images/phonme.png",
  
      isRemovable: true,
    ),
    PaymentMethod(
      name: 'Cashfree',
    imagepath: "assets/images/cashfire.png",

      isRemovable: true,
    ),
    PaymentMethod(
      name: 'Razorpay',
    imagepath: "assets/images/razorpay.png",

      isRemovable: true,
    ),
    PaymentMethod(
      name: 'Bank Transfer',
      imagepath: "assets/images/bank.png",
    
      isRemovable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: UnifiedProfileAppBar(title: "Payment Method"),
      body: Column(
        children: [
          
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
                  Icon(Icons.add_box_outlined, color: Colors.white, size: 20),
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
          SizedBox(
            width: 24.h,
            height: 24.h,
            child: Image(image: AssetImage(method.imagepath!))),
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
            IconButton(
              icon: const Icon(Icons.close_outlined, color: Colors.red, size: 16),
              onPressed: () => _showRemoveDialog(method),
              color: Colors.red,
              splashColor: Colors.red.withOpacity(0.1),
              splashRadius: 16,
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
  final String? imagepath;

  final bool isRemovable;

  PaymentMethod({
    required this.name,
    required this.imagepath,
    
    required this.isRemovable,
  });
}
