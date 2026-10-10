import 'package:flutter/material.dart';
import 'package:manajemenasrama/shared/models/profile.dart';
import 'package:manajemenasrama/widgets/activity_item.dart';
import 'package:manajemenasrama/widgets/balance_card.dart';
import 'package:manajemenasrama/widgets/quick_action.dart';
import 'package:manajemenasrama/widgets/stat_card.dart';

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/asrama_service.dart';
import '../users/users_page.dart';
import '../asrama/asrama_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.authService,
    required this.userService,
  });

  final AuthService authService;
  final UserService userService;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final _userService = widget.userService;
  late final _authService = widget.authService;

  int currentIndex = 0;
  late Future<Profile> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = _userService.me();
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Anda telah logout')));
  }

  Future<void> _reload() async {
    setState(() => _futureProfile = widget.userService.me());
    await _futureProfile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          setState(() => currentIndex = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Kegiatan Saya',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 2),
                        FutureBuilder<Profile>(
                          future: _futureProfile,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text(
                                'Loading...',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Text(
                                'User',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }

                            final profile = snapshot.data;

                            return Text(
                              profile?.fullName ?? 'User',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const BalanceCard(),
              const SizedBox(height: 28),
              const Text(
                "Menu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  QuickAction(
                    icon: Icons.manage_accounts_outlined,
                    label: "Pengguna",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              UsersPage(userService: widget.userService),
                        ),
                      );
                    },
                  ),
                  QuickAction(
                    icon: Icons.home_outlined,
                    label: "Asrama",
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AsramaPage(
                            service: AsramaService(authService: widget.authService),
                          ),
                        ),
                      );
                    },
                  ),
                  QuickAction(
                    icon: Icons.task_alt_sharp,
                    label: "Ijin & Sakit",
                    notificationCount: 10,
                  ),
                  QuickAction(
                    icon: Icons.receipt_long_outlined,
                    label: "Kegiatan",
                    notificationCount: 10,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hari Ini",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: () {}, child: const Text("See All")),
                ],
              ),
              const SizedBox(height: 10),
              const ActivityItem(
                title: "Netflix",
                subtitle: "Subscription",
                amount: "-Rp159.000",
                icon: Icons.movie,
                color: Colors.red,
              ),
              const ActivityItem(
                title: "Salary",
                subtitle: "Monthly Income",
                amount: "+Rp18.500.000",
                icon: Icons.payments,
                color: Colors.green,
              ),
              const ActivityItem(
                title: "Shopee",
                subtitle: "Shopping",
                amount: "-Rp325.000",
                icon: Icons.shopping_bag,
                color: Colors.orange,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
