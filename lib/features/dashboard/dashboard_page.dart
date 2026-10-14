import 'package:flutter/material.dart';
import 'package:manajemenasrama/shared/models/jadwal_kegiatan_list.dart';
import 'package:manajemenasrama/shared/models/profile.dart';
// ...existing code... (removed unused import)
import 'package:manajemenasrama/widgets/jadwal_kegiatan_card.dart';
import 'package:manajemenasrama/widgets/quick_action.dart';
// ...existing code... (removed unused import)

import '../../core/constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../shared/models/user_role.dart';
import '../../services/asrama_service.dart';
import '../users/users_page.dart';
import '../asrama/asrama_page.dart';
import '../jadwal_kegiatan/jadwal_kegiatan_page.dart';
import '../profile/update_profile_page.dart';

import 'package:manajemenasrama/features/jadwal_kegiatan/jadwal_kegiatan_by_day_page.dart'
    as byday_page;

import '../../services/jadwal_kegiatan_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    required this.authService,
    required this.userService,
    required this.jadwalKegiatanService,
  });

  final AuthService authService;
  final UserService userService;
  final JadwalKegiatanService jadwalKegiatanService;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final _userService = widget.userService;
  late final _jadwalKegiatanService = widget.jadwalKegiatanService;

  int currentIndex = 0;
  late Future<Profile> _futureProfile;
  late Future<List<JadwalKegiatanList>> _futureNextJadwalKegiatan;

  @override
  void initState() {
    super.initState();
    _futureProfile = _userService.me();
    _futureNextJadwalKegiatan = _jadwalKegiatanService.meToday();
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Anda telah logout')));
  }

  // reload not required here; profile is loaded in initState

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
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      body: currentIndex == 1
          ? UpdateProfilePage(service: _userService)
          : SafeArea(
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
                    FutureBuilder<List<JadwalKegiatanList>>(
                      future: _futureNextJadwalKegiatan,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Text('Gagal memuat jadwal kegiatan');
                        }

                        return JadwalKegiatanCard(
                          jadwal: snapshot.data ?? [],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => byday_page.JadwalKegiatanByDayPage(
                                  service: _jadwalKegiatanService,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ), // Placeholder for the next activity card
                    const SizedBox(height: 28),
                    const Text(
                      "Menu",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 18),
                    FutureBuilder<Profile>(
                      future: _futureProfile,
                      builder: (context, snapRole) {
                        // Role-based access mapping
                        final allowed = <String, List<UserRole>>{
                          'pengguna': [UserRole.superAdmin],
                          'asrama': [UserRole.superAdmin, UserRole.pengurus],
                          'ijin': [UserRole.ustadzah, UserRole.pengurus],
                          'jadwal': [UserRole.superAdmin, UserRole.pengurus],
                        };

                        UserRole? role;
                        if (snapRole.connectionState == ConnectionState.done && snapRole.hasData) {
                          role = snapRole.data!.role;
                        }

                        bool can(String key) {
                          if (role == null) return false; // hide until loaded
                          return allowed[key]?.contains(role) == true;
                        }

                        Widget buildQuick({required IconData icon, required String label, VoidCallback? onTap}) {
                          return QuickAction(icon: icon, label: label, onTap: onTap);
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Pengguna
                            if (can('pengguna'))
                              buildQuick(
                                icon: Icons.manage_accounts_outlined,
                                label: 'Pengguna',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => UsersPage(userService: widget.userService),
                                    ),
                                  );
                                },
                              ),

                            // Asrama
                            if (can('asrama'))
                              buildQuick(
                                icon: Icons.home_outlined,
                                label: 'Asrama',
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

                            // Ijin & Sakit
                            if (can('ijin'))
                              buildQuick(
                                icon: Icons.task_alt_sharp,
                                label: 'Ijin & Sakit',
                                onTap: null,
                              ),

                            // Jadwal Kegiatan
                            if (can('jadwal'))
                              buildQuick(
                                icon: Icons.receipt_long_outlined,
                                label: 'Jadwal Kegiatan',
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => JadwalKegiatanPage(
                                        service: JadwalKegiatanService(authService: widget.authService),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
