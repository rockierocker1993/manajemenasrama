import 'package:flutter/material.dart';
import 'package:manajemenasrama/widgets/activity_item.dart';
import 'package:manajemenasrama/widgets/balance_card.dart';
import 'package:manajemenasrama/widgets/quick_action.dart';
import 'package:manajemenasrama/widgets/stat_card.dart';

import '../../core/constants/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          setState(() => currentIndex = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: "Aktivitas Hari Ini",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),

                  const SizedBox(width: 15),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Good Morning",
                          style: TextStyle(color: Colors.grey),
                        ),

                        SizedBox(height: 2),

                        Text(
                          "Ikhsan Fadly",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none),
                  )
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              //
              // const SizedBox(height: 24),
              //
              // const BalanceCard(),
              //
              // const SizedBox(height: 28),
              //
              // const Text(
              //   "Quick Actions",
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              //
              // const SizedBox(height: 18),
              //
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     QuickAction(icon: Icons.send, label: "Transfer"),
              //     QuickAction(icon: Icons.account_balance_wallet, label: "Top Up"),
              //     QuickAction(icon: Icons.payment, label: "Pay"),
              //     QuickAction(icon: Icons.qr_code_scanner, label: "QR"),
              //   ],
              // ),
              //
              // const SizedBox(height: 30),
              //
              // const Text(
              //   "Overview",
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              //
              // const SizedBox(height: 18),
              //
              // const Row(
              //   children: [
              //
              //     Expanded(
              //       child: StatCard(
              //         title: "Income",
              //         amount: "Rp12.5M",
              //         icon: Icons.arrow_downward,
              //         color: Colors.green,
              //       ),
              //     ),
              //
              //     SizedBox(width: 12),
              //
              //     Expanded(
              //       child: StatCard(
              //         title: "Expense",
              //         amount: "Rp5.2M",
              //         icon: Icons.arrow_upward,
              //         color: Colors.red,
              //       ),
              //     ),
              //   ],
              // ),
              //
              // const SizedBox(height: 30),
              //
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //
              //     const Text(
              //       "Recent Activity",
              //       style: TextStyle(
              //         fontSize: 20,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //
              //     TextButton(
              //       onPressed: () {},
              //       child: const Text("See All"),
              //     )
              //   ],
              // ),
              //
              // const SizedBox(height: 10),
              //
              // const ActivityItem(
              //   title: "Netflix",
              //   subtitle: "Subscription",
              //   amount: "-Rp159.000",
              //   icon: Icons.movie,
              //   color: Colors.red,
              // ),
              //
              // const ActivityItem(
              //   title: "Salary",
              //   subtitle: "Monthly Income",
              //   amount: "+Rp18.500.000",
              //   icon: Icons.payments,
              //   color: Colors.green,
              // ),
              //
              // const ActivityItem(
              //   title: "Shopee",
              //   subtitle: "Shopping",
              //   amount: "-Rp325.000",
              //   icon: Icons.shopping_bag,
              //   color: Colors.orange,
              // ),
              //
              // const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}