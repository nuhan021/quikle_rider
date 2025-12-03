import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final String paymentSessionId;
  final CFEnvironment environment;
  const PaymentPage({
    Key? key,
    required this.orderId,
    required this.paymentSessionId,
    this.environment = CFEnvironment.SANDBOX,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late CFPaymentGatewayService cfPaymentGatewayService;

  @override
  void initState() {
    super.initState();
    cfPaymentGatewayService = CFPaymentGatewayService();
    cfPaymentGatewayService.setCallback(verifyPayment, onError);
  }

  void verifyPayment(String orderId) {
    // Payment successful — handle success (e.g. notify backend, navigate)
    print("Payment success for order: $orderId");
    // You can navigate or show a success screen here.
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    // Payment failed — handle error
    print("Payment error for order $orderId : ${errorResponse.getMessage()}");
    // You can show error UI or retry, etc.
  }

  void startPayment() {
    try {
      var session = CFSessionBuilder()
          .setEnvironment(widget.environment)
          .setOrderId(widget.orderId)
          .setPaymentSessionId(widget.paymentSessionId)
          .build();

      var cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          .build();

      cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e) {
      print("CFException: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Now"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: startPayment,
          child: const Text("Proceed to Payment"),
        ),
      ),
    );
  }
}
