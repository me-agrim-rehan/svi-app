import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'home_screen.dart';
import 'profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.phone});

  final String phone;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _handleMenuSelection(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$value will be connected later.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Constant top bar — logo, notifications, menu — same on every tab.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Row(
                children: [
                  const AppLogo(size: 40),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifications will be connected later.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.notifications_none_rounded),
                        color: AppColors.navy,
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppColors.navy),
                    onSelected: _handleMenuSelection,
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'Settings', child: Text('Settings')),
                      PopupMenuItem(value: 'Help & support', child: Text('Help & support')),
                      PopupMenuItem(value: 'Log out', child: Text('Log out')),
                    ],
                  ),
                ],
              ),
            ),
            // Tab content — IndexedStack keeps each tab's state alive when
            // you switch away and back (e.g. search text, scroll position).
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  HomeScreen(phone: widget.phone),
                  const _ComingSoonTab(label: 'Applied jobs'),
                  const _ComingSoonTab(label: 'Documents'),
                  ProfilePage(phone: widget.phone),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label coming soon.',
        style: const TextStyle(color: AppColors.mutedText, fontSize: 14),
      ),
    );
  }
}