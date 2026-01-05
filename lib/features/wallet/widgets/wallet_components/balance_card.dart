import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final String lastUpdated;
  final VoidCallback onWithdraw;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.lastUpdated,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadows: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 312,
                        child: Text(
                          'Current Balance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF9B9B9B),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 312,
                        child: Text(
                          balance,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF333333),
                            fontSize: 32,
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w600,
                            height: 1.20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 312,
                        child: Text(
                          lastUpdated,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF7C7C7C),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.30,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onWithdraw,
            child: Container(
             
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              decoration: ShapeDecoration(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Withdraw',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFF8F8F8),
                      fontSize: 18,
                      fontFamily: 'Manrope',
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
}
