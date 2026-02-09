import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SidebarMenu extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onNewOrder;

  const SidebarMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Listen to settings to show real Restaurant/Cashier name
    final settings = ref.watch(settingsProvider);

    return Container(
      width: 280, // Slightly wider for better spacing
      decoration: const BoxDecoration(
        // 2. Modern Gradient Background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A4C),
            Color(0xFF162B3A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black45,
            offset: Offset(4, 0),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // --- HEADER SECTION ---
          Hero(
            tag: 'appLogo',
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) =>
                    const Icon(Icons.store, size: 50, color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              settings.name.isNotEmpty ? settings.name : "ProDine POS",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- MENU ITEMS (Scrollable) ---
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SidebarMenuItem(
                    icon: Icons.add_box_rounded,
                    label: 'New Order',
                    isActive: selectedIndex == 0,
                    onTap: onNewOrder,
                    isPrimary: true, // Special styling for POS
                  ),
                  _SidebarMenuItem(
                    icon: Icons.fastfood_rounded,
                    label: 'Menu Management',
                    isActive: selectedIndex == 1,
                    onTap: () => onItemSelected(1),
                  ),
                  _SidebarMenuItem(
                    icon: Icons.history_rounded,
                    label: 'Sales History',
                    isActive: selectedIndex == 2,
                    onTap: () => onItemSelected(2),
                  ),
                  _SidebarMenuItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reports & Analytics',
                    isActive: selectedIndex == 3,
                    onTap: () => onItemSelected(3),
                  ),
                  _SidebarMenuItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isActive: selectedIndex == 4,
                    onTap: () => onItemSelected(4),
                  ),
                ],
              ),
            ),
          ),

          // --- USER PROFILE FOOTER ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
              color: Colors.black12,
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF2C5F7C),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.cashierName.isNotEmpty
                            ? settings.cashierName
                            : "Cashier",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        "Active Session",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- EXTRACTED WIDGET FOR BETTER PERFORMANCE ---
class _SidebarMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isPrimary;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Active Color Logic
    final Color activeBg = widget.isPrimary
        ? const Color(0xFF2C5F7C) // Standard Blue
        : const Color(0xFF2C5F7C).withOpacity(0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: widget.isActive
                  ? activeBg
                  : _isHovering
                      ? Colors.white.withOpacity(0.05)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: widget.isActive
                  ? Border.all(color: Colors.white12, width: 1)
                  : Border.all(color: Colors.transparent),
              boxShadow: widget.isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.isActive ? Colors.white : Colors.grey[400],
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.isActive ? Colors.white : Colors.grey[400],
                      fontSize: 15,
                      fontWeight:
                          widget.isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.isActive)
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
