import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_social_client/core/theme/app_theme.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeShell extends StatefulWidget {
  final Widget child;
  
  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/dashboard',
    '/discovery',
    '/aux-wars',
    '/profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: isDark 
              ? AppTheme.darkTextTertiary 
              : AppTheme.lightTextTertiary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.house),
              activeIcon: Icon(PhosphorIconsBold.house),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.compass),
              activeIcon: Icon(PhosphorIconsBold.compass),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.microphone),
              activeIcon: Icon(PhosphorIconsBold.microphone),
              label: 'Aux Wars',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIconsRegular.user),
              activeIcon: Icon(PhosphorIconsBold.user),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
