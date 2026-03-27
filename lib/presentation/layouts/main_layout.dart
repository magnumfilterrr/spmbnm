import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spmb_app/core/theme/app_theme.dart';
import 'package:spmb_app/core/utils/responsive_helper.dart';
import 'package:spmb_app/logic/auth/auth_bloc.dart';
import 'package:spmb_app/logic/auth/auth_event.dart';
import 'package:spmb_app/logic/dashboard/dashboard_bloc.dart';
import 'package:spmb_app/logic/dashboard/dashboard_event.dart';
import 'package:spmb_app/logic/database/database_bloc.dart';
import 'package:spmb_app/logic/database/database_event.dart';
import 'package:spmb_app/presentation/pages/dashboard/dashboard_page.dart';
import 'package:spmb_app/presentation/pages/database/database_page.dart';
import 'package:spmb_app/presentation/pages/pendaftaran/pendaftaran_page.dart';

class MainLayout extends StatefulWidget {
  final int index;
  const MainLayout({super.key, this.index = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  final List<_NavItem> _navItems = [
    _NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard'),
    _NavItem(
        icon: Icons.app_registration_outlined,
        activeIcon: Icons.app_registration,
        label: 'Pendaftaran'),
    _NavItem(
        icon: Icons.table_chart_outlined,
        activeIcon: Icons.table_chart,
        label: 'Database'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.index;
    _loadInitialData();
  }

  void _loadInitialData() {
    context.read<DashboardBloc>().add(LoadDashboard());
    context.read<DatabaseBloc>().add(LoadPeserta());
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const PendaftaranPage();
      case 2:
        return const DatabasePage();
      default:
        return const DashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return _buildDesktop();
    if (ResponsiveHelper.isTablet(context)) return _buildTablet();
    return _buildMobile();
  }

  // ─── DESKTOP ─────────────────────────────────────────
  Widget _buildDesktop() {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _getPage(_selectedIndex)),
        ],
      ),
    );
  }

  // ─── TABLET ──────────────────────────────────────────
  Widget _buildTablet() {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(),
          Expanded(child: _getPage(_selectedIndex)),
        ],
      ),
    );
  }

  // ─── MOBILE ──────────────────────────────────────────
  Widget _buildMobile() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_navItems[_selectedIndex].label),
        actions: [_buildLogoutButton()],
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: _navItems
            .map((e) => NavigationDestination(
                  icon: Icon(e.icon),
                  selectedIcon: Icon(e.activeIcon),
                  label: e.label,
                ))
            .toList(),
      ),
    );
  }

  // ─── SIDEBAR (Desktop) ───────────────────────────────
  Widget _buildSidebar() {
    return Container(
      width: 250,
      color: AppTheme.primary,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/nm.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 12),
                Text(
                  'SPMB 2026/2027',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Sistem Penerimaan Murid Baru',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 8),

          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _navItems.length,
              itemBuilder: (_, i) => _buildSidebarItem(i),
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          // Logout
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.logout, color: Colors.white70),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.white70)),
              onTap: _showLogoutDialog,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: isSelected ? Colors.white.withOpacity(0.15) : null,
        leading: Icon(
          isSelected ? item.activeIcon : item.icon,
          color: isSelected ? Colors.white : Colors.white60,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white60,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }

  // ─── NAVIGATION RAIL (Tablet) ────────────────────────
  Widget _buildNavigationRail() {
    return NavigationRail(
      backgroundColor: AppTheme.primary,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      labelType: NavigationRailLabelType.all,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Icon(Icons.school_rounded, color: Colors.white, size: 32),
      ),
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: _showLogoutDialog,
            ),
          ),
        ),
      ),
      destinations: _navItems
          .map((e) => NavigationRailDestination(
                icon: Icon(e.icon, color: Colors.white60),
                selectedIcon: Icon(e.activeIcon, color: Colors.white),
                label: Text(e.label,
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ))
          .toList(),
    );
  }

  // ─── LOGOUT ──────────────────────────────────────────
  Widget _buildLogoutButton() {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: _showLogoutDialog,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
