import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/widgets/common_widgets.dart';
import '../screens/announcements/announcements_screen.dart';
import '../screens/campus_map/campus_map_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';

/// The main shell widget that hosts the [BottomNavigationBar] and
/// an [IndexedStack] for the four primary tabs.
///
/// Using [IndexedStack] ensures each tab's state is preserved when
/// the user switches between tabs (scroll position, form inputs, etc.).
class MainShell extends StatefulWidget {
  final int initialTab;

  const MainShell({super.key, this.initialTab = 0});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  /// Allows child widgets to switch tabs programmatically.
  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late int _currentIndex = widget.initialTab;

  // The five tab screens — order matches the BottomNavigationBar items.
  final List<Widget> _screens = const [
    HomeScreen(),
    AnnouncementsScreen(),
    EventsScreen(),
    CampusMapScreen(),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Handle Android back button: go to Home tab first, then exit.
  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false; // Don't exit the app
    }
    return true; // Exit the app
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(index: _currentIndex, children: _screens),
            ),
          ],
        ),
        bottomNavigationBar: Semantics(
          label: 'Main navigation',
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: AppStrings.navHome,
                tooltip: 'Home dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.campaign_outlined),
                activeIcon: Icon(Icons.campaign_rounded),
                label: AppStrings.navAnnouncements,
                tooltip: 'Campus announcements',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.event_outlined),
                activeIcon: Icon(Icons.event_rounded),
                label: AppStrings.navEvents,
                tooltip: 'Campus events',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map_rounded),
                label: AppStrings.navMap,
                tooltip: 'Campus map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: AppStrings.navSettings,
                tooltip: 'App settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
