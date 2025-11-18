import 'package:absensi_tugas16/views/dashboard.dart';
import 'package:absensi_tugas16/views/profilpage.dart';
import 'package:absensi_tugas16/views/riwayatpage.dart';
import 'package:flutter/material.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _currentIndex = 0;

  // ⬇️ PENTING: isi dengan INSTANCE widget (pakai ())
  final List<Widget> _pages = const [
    DashboardYellow(),
    RiwayatPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ⬇️ JANGAN pakai _pages[_currentIndex]() cukup seperti ini
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.brown.shade300,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: "Riwayat",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profil",
          ),
        ],
      ),
    );
  }
}
