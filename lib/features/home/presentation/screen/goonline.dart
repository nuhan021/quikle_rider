// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class GoOnlinePage extends StatelessWidget {
  const GoOnlinePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The font family 'Obviously' needs to be added to your pubspec.yaml file
    // and included in your project assets for this to work correctly.
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          width: 360,
          height: 196,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Do You Want To Go Online ?',
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleYesPressed(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: const Color(0xFF333333),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontFamily: 'Obviously',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleNoPressed(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                        //foregroundColor: const Color(0xFF333333),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          fontFamily: 'Obviously',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleYesPressed(BuildContext context) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(
    //       'You are now online and ready to receive orders!',
    //       style: TextStyle(
    //         fontFamily: 'Manrope',
    //       ),
    //     ),
    //     backgroundColor: Colors.green,
    //     duration: const Duration(seconds: 2), 
    //   ),
    // );
    Navigator.of(context).pop(true);
  }

  void _handleNoPressed(BuildContext context) {
    Navigator.of(context).pop(false);
  }
}

class GoOnlineDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const GoOnlinePage();
      },
    );
  }
}
