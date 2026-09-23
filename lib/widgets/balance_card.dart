import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),

        gradient: const LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.accent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "Available Balance",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Rp24.580.000",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 28),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Card Holder",
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    "IKHSAN FADLY",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),

              Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 36,
              )
            ],
          )
        ],
      ),
    );
  }
}