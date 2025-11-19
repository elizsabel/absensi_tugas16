import 'package:absensi_tugas16/views/attendancepage.dart';
import 'package:flutter/material.dart';
import 'package:absensi_tugas16/views/dashboard.dart';
import 'package:absensi_tugas16/views/profilpage.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardYellowFinal(),
    AttendancePage(),
    ProfileFinalPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],

      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.orange.shade700,
              unselectedItemColor: Colors.grey.shade400,
              iconSize: 28,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 11,

              items: [
                BottomNavigationBarItem(
                  icon: _navIcon(
                    Icons.dashboard_rounded,
                    selected: _currentIndex == 0,
                    color: Colors.orange,
                  ),
                  label: "Dashboard",
                ),
                BottomNavigationBarItem(
                  icon: _navIcon(
                    Icons.access_time_filled_rounded,
                    selected: _currentIndex == 1,
                    color: Colors.blue,
                  ),
                  label: "Absensi",
                ),
                BottomNavigationBarItem(
                  icon: _navIcon(
                    Icons.person_rounded,
                    selected: _currentIndex == 2,
                    color: Colors.green,
                  ),
                  label: "Profil",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navIcon(
    IconData icon, {
    required bool selected,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.all(selected ? 10 : 6),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.15) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: selected ? color : Colors.grey.shade400,
        size: selected ? 30 : 26,
      ),
    );
  }
}
