import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../viewmodels/app_state.dart';
import '../widgets/forms.dart';
import '../models/models.dart';

// =========================================================================
// 1. EXPERT SHELL LAYOUT
// =========================================================================

class ExpertShellLayout extends ConsumerStatefulWidget {
  final Widget child;
  const ExpertShellLayout({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<ExpertShellLayout> createState() => _ExpertShellLayoutState();
}

class _ExpertShellLayoutState extends ConsumerState<ExpertShellLayout> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        endDrawer: const NotificationsDrawer(),
        drawer: isMobile ? const Drawer(child: ExpertCollapsibleSidebar(isMobile: true)) : null,
        appBar: isMobile
            ? AppBar(
                backgroundColor: Colors.white,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.lightPrimary),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: Text(
                  'EXIGENTCX EXPERT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.lightPrimary,
                  ),
                ),
                actions: [
                  ShakingBellIcon(
                    unreadCount: ref.watch(notificationsProvider).where((n) => n.unread).length,
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                  const SizedBox(width: 8),
                  const PulsingOnlineAvatar(avatarUrl: '', initials: 'SJ'),
                  const SizedBox(width: 16),
                ],
              )
            : null,
        body: Row(
          children: [
            if (!isMobile)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: _isSidebarExpanded ? 260 : 78,
                child: ExpertCollapsibleSidebar(
                  isExpanded: _isSidebarExpanded,
                  onToggleCollapse: () {
                    setState(() {
                      _isSidebarExpanded = !_isSidebarExpanded;
                    });
                  },
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  if (!isMobile)
                    ExpertGlobalHeader(
                      onNotificationClick: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 2. COMPANY SHELL LAYOUT
// =========================================================================

class CompanyShellLayout extends ConsumerStatefulWidget {
  final Widget child;
  const CompanyShellLayout({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<CompanyShellLayout> createState() => _CompanyShellLayoutState();
}

class _CompanyShellLayoutState extends ConsumerState<CompanyShellLayout> {
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AppColors.lightBg,
        endDrawer: const NotificationsDrawer(),
        drawer: isMobile ? const Drawer(child: CompanyCollapsibleSidebar(isMobile: true)) : null,
        appBar: isMobile
            ? AppBar(
                backgroundColor: Colors.white,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.lightPrimary),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                title: Text(
                  'EXIGENTCX ADMIN',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AppColors.lightPrimary,
                  ),
                ),
                actions: [
                  ShakingBellIcon(
                    unreadCount: ref.watch(notificationsProvider).where((n) => n.unread).length,
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                  const SizedBox(width: 8),
                  const PulsingOnlineAvatar(avatarUrl: '', initials: 'SH'),
                  const SizedBox(width: 16),
                ],
              )
            : null,
        body: Row(
          children: [
            if (!isMobile)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: _isSidebarExpanded ? 260 : 78,
                child: CompanyCollapsibleSidebar(
                  isExpanded: _isSidebarExpanded,
                  onToggleCollapse: () {
                    setState(() {
                      _isSidebarExpanded = !_isSidebarExpanded;
                    });
                  },
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  if (!isMobile)
                    CompanyGlobalHeader(
                      onNotificationClick: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                  Expanded(
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 3. EXPERT SIDEBAR NAVIGATION WIDGET
// =========================================================================

class ExpertCollapsibleSidebar extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback? onToggleCollapse;
  final bool isMobile;

  const ExpertCollapsibleSidebar({
    Key? key,
    this.isExpanded = true,
    this.onToggleCollapse,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    final List<_SidebarItem> items = [
      _SidebarItem(
        route: '/expert-dashboard',
        title: 'Dashboard',
        icon: Icons.grid_view,
      ),
      _SidebarItem(
        route: '/expert-opportunities',
        title: 'Opportunities',
        icon: Icons.adjust,
        badgeCount: 3,
        badgeColor: AppColors.mintTeal,
      ),
      _SidebarItem(
        route: '/expert-engagements',
        title: 'My Engagements',
        icon: Icons.trending_up,
      ),
      _SidebarItem(
        route: '/expert-contracts',
        title: 'Contracts',
        icon: Icons.description_outlined,
        badgeCount: 1,
        badgeColor: AppColors.warning,
      ),
      _SidebarItem(
        route: '/expert-earnings',
        title: 'Earnings',
        icon: Icons.payments_outlined,
      ),
      _SidebarItem(
        route: '/expert-profile',
        title: 'Profile',
        icon: Icons.person_outline,
      ),
      _SidebarItem(
        route: '/messages',
        title: 'Messages',
        icon: Icons.chat_bubble_outline,
      ),
      _SidebarItem(
        route: '/meetings',
        title: 'Meetings',
        icon: Icons.calendar_month_outlined,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: (isExpanded || isMobile) ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.lightPrimary, size: 28),
                  if (isExpanded || isMobile) ...[
                    const SizedBox(width: 10),
                    Text(
                      'EXIGENTCX',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: AppColors.lightBorder, height: 1.0),

            if (isExpanded || isMobile)
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 16.0, bottom: 8.0),
                child: Row(
                  children: [
                    Text(
                      'MAIN MENU',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextSecondary.withOpacity(0.6),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),

            // Navigation Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = currentRoute.startsWith(item.route);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: InkWell(
                      onTap: () {
                        if (isMobile) Navigator.pop(context);
                        context.go(item.route);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lightPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: (isExpanded || isMobile) ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                              size: 20,
                            ),
                            if (isExpanded || isMobile) ...[
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                              if (item.badgeCount != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.badgeColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${item.badgeCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(color: AppColors.lightBorder, height: 1.0),
            // Collapse / Settings / Sign Out Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Column(
                children: [
                  // Settings item in footer
                  InkWell(
                    onTap: () {
                      if (isMobile) Navigator.pop(context);
                      context.go('/expert-settings');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: (isExpanded || isMobile) ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            color: currentRoute.startsWith('/expert-settings') ? AppColors.mintTeal : AppColors.lightTextSecondary,
                            size: 20,
                          ),
                          if (isExpanded || isMobile) ...[
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Settings',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: currentRoute.startsWith('/expert-settings') ? FontWeight.bold : FontWeight.w500,
                                  color: currentRoute.startsWith('/expert-settings') ? AppColors.lightPrimary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: () {
                      ref.read(userRoleProvider.notifier).state = UserRole.guest;
                      ref.read(tabNavigationProvider.notifier).setTab(0);
                      if (isMobile) Navigator.pop(context);
                      context.go('/signin');
                      Forms.showSuccessToast(context, 'Signed out successfully.');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: (isExpanded || isMobile) ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: AppColors.error, size: 20),
                          if (isExpanded || isMobile) ...[
                            const SizedBox(width: 14),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!isMobile && onToggleCollapse != null) ...[
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.keyboard_double_arrow_left : Icons.keyboard_double_arrow_right,
                        color: AppColors.lightTextSecondary,
                      ),
                      onPressed: onToggleCollapse,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 4. COMPANY SIDEBAR NAVIGATION WIDGET
// =========================================================================

class CompanyCollapsibleSidebar extends ConsumerWidget {
  final bool isExpanded;
  final VoidCallback? onToggleCollapse;
  final bool isMobile;

  const CompanyCollapsibleSidebar({
    Key? key,
    this.isExpanded = true,
    this.onToggleCollapse,
    this.isMobile = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    final List<_SidebarItem> items = [
      _SidebarItem(
        route: '/company-dashboard',
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
      ),
      _SidebarItem(
        route: '/requirements',
        title: 'My Requirements',
        icon: Icons.assignment_outlined,
      ),
      _SidebarItem(
        route: '/experts',
        title: 'Find Experts',
        icon: Icons.people_outline,
      ),
      _SidebarItem(
        route: '/payments',
        title: 'Payments & Escrow',
        icon: Icons.account_balance_wallet_outlined,
      ),
      _SidebarItem(
        route: '/analytics',
        title: 'Analytics & Spend',
        icon: Icons.bar_chart_outlined,
      ),
      _SidebarItem(
        route: '/messages',
        title: 'Messages',
        icon: Icons.chat_bubble_outline,
      ),
      _SidebarItem(
        route: '/meetings',
        title: 'Scheduled Meetings',
        icon: Icons.calendar_month_outlined,
      ),
      _SidebarItem(
        route: '/company-settings',
        title: 'Settings',
        icon: Icons.settings_outlined,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: (isExpanded || isMobile) ? MainAxisAlignment.start : MainAxisAlignment.center,
                children: [
                  const Icon(Icons.corporate_fare_outlined, color: AppColors.lightPrimary, size: 28),
                  if (isExpanded || isMobile) ...[
                    const SizedBox(width: 10),
                    Text(
                      'EXIGENTCX ADM',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(color: AppColors.lightBorder, height: 1.0),

            // Navigation Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = currentRoute.startsWith(item.route);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: InkWell(
                      onTap: () {
                        if (isMobile) Navigator.pop(context);
                        context.go(item.route);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.lightMintHighlight : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: (isExpanded || isMobile) ? MainAxisAlignment.start : MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? AppColors.mintTeal : AppColors.lightTextSecondary,
                              size: 20,
                            ),
                            if (isExpanded || isMobile) ...[
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? AppColors.lightPrimary : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                              if (item.badgeCount != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.badgeColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${item.badgeCount}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(color: AppColors.lightBorder, height: 1.0),
            // Collapse / Sign Out Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      ref.read(userRoleProvider.notifier).state = UserRole.guest;
                      ref.read(tabNavigationProvider.notifier).setTab(0);
                      if (isMobile) Navigator.pop(context);
                      context.go('/signin');
                      Forms.showSuccessToast(context, 'Signed out successfully.');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: (isExpanded || isMobile) ? MainAxisAlignment.start : MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: AppColors.error, size: 20),
                          if (isExpanded || isMobile) ...[
                            const SizedBox(width: 14),
                            Text(
                              'Sign Out',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!isMobile && onToggleCollapse != null) ...[
                    const SizedBox(height: 8),
                    IconButton(
                      icon: Icon(
                        isExpanded ? Icons.keyboard_double_arrow_left : Icons.keyboard_double_arrow_right,
                        color: AppColors.lightTextSecondary,
                      ),
                      onPressed: onToggleCollapse,
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 5. GLOBAL HEADERS
// =========================================================================

class ExpertGlobalHeader extends ConsumerStatefulWidget {
  final VoidCallback onNotificationClick;
  const ExpertGlobalHeader({Key? key, required this.onNotificationClick}) : super(key: key);

  @override
  ConsumerState<ExpertGlobalHeader> createState() => _ExpertGlobalHeaderState();
}

class _ExpertGlobalHeaderState extends ConsumerState<ExpertGlobalHeader> {
  bool _isSearchFocused = false;
  final LayerLink _nineDotLink = LayerLink();
  OverlayEntry? _nineDotOverlay;

  void _toggleNineDotDropdown() {
    if (_nineDotOverlay != null) {
      _closeNineDotDropdown();
    } else {
      _showNineDotDropdown();
    }
  }

  void _showNineDotDropdown() {
    _nineDotOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeNineDotDropdown,
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              width: 320,
              child: CompositedTransformFollower(
                link: _nineDotLink,
                showWhenUnlinked: false,
                offset: const Offset(-270, 48),
                child: Material(
                  elevation: 16,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Navigation shortcuts',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.5,
                          children: [
                            _buildShortcutCard(
                              icon: Icons.search,
                              title: 'Opportunities',
                              badge: '3 new',
                              badgeColor: AppColors.mintTeal,
                              onTap: () {
                                _closeNineDotDropdown();
                                context.go('/expert-opportunities');
                              },
                            ),
                            _buildShortcutCard(
                              icon: Icons.payments_outlined,
                              title: 'Earnings',
                              badge: '₹3.5L',
                              badgeColor: AppColors.warning,
                              onTap: () {
                                _closeNineDotDropdown();
                                context.go('/expert-earnings');
                              },
                            ),
                            _buildShortcutCard(
                              icon: Icons.work_outline,
                              title: 'Engagements',
                              onTap: () {
                                _closeNineDotDropdown();
                                context.go('/expert-engagements');
                              },
                            ),
                            _buildShortcutCard(
                              icon: Icons.person_outline,
                              title: 'Vetting Profile',
                              onTap: () {
                                _closeNineDotDropdown();
                                context.go('/expert-profile');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_nineDotOverlay!);
  }

  void _closeNineDotDropdown() {
    _nineDotOverlay?.remove();
    _nineDotOverlay = null;
  }

  @override
  void dispose() {
    _closeNineDotDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.lightBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Glowing Search Bar
          Expanded(
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Focus(
                    onFocusChange: (focus) {
                      setState(() {
                        _isSearchFocused = focus;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSearchFocused ? AppColors.mintTeal : AppColors.lightBorder,
                          width: _isSearchFocused ? 1.5 : 1.0,
                        ),
                        boxShadow: _isSearchFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.mintTeal.withOpacity(0.12),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search opportunities, companies, skills...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.lightTextSecondary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Primary CTA (Browse Roles Button)
          HoverBrowseRolesButton(
            onTap: () {
              context.go('/expert-opportunities');
            },
          ),
          const SizedBox(width: 18),

          // 9-Dot Quick Nav Button
          CompositedTransformTarget(
            link: _nineDotLink,
            child: IconButton(
              icon: const Icon(Icons.apps, color: AppColors.lightPrimary, size: 24),
              onPressed: _toggleNineDotDropdown,
            ),
          ),
          const SizedBox(width: 8),

          // Shaking Notification Bell
          ShakingBellIcon(
            unreadCount: ref.watch(notificationsProvider).where((n) => n.unread).length,
            onTap: widget.onNotificationClick,
          ),
          const SizedBox(width: 14),

          // Avatar with pulsing indicator
          const PulsingOnlineAvatar(avatarUrl: '', initials: 'SJ'),
        ],
      ),
    );
  }
}

class CompanyGlobalHeader extends ConsumerStatefulWidget {
  final VoidCallback onNotificationClick;
  const CompanyGlobalHeader({Key? key, required this.onNotificationClick}) : super(key: key);

  @override
  ConsumerState<CompanyGlobalHeader> createState() => _CompanyGlobalHeaderState();
}

class _CompanyGlobalHeaderState extends ConsumerState<CompanyGlobalHeader> {
  bool _isSearchFocused = false;
  final LayerLink _nineDotLink = LayerLink();
  OverlayEntry? _nineDotOverlay;

  void _toggleNineDotDropdown() {
    if (_nineDotOverlay != null) {
      _closeNineDotDropdown();
    } else {
      _showNineDotDropdown();
    }
  }

  void _showNineDotDropdown() {
    _nineDotOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeNineDotDropdown,
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              width: 320,
              child: CompositedTransformFollower(
                link: _nineDotLink,
                showWhenUnlinked: false,
                offset: const Offset(-270, 48),
                child: Material(
                  elevation: 16,
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.lightBorder),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Admin Navigation',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.5,
                          children: [
                            _buildShortcutCard(
                              icon: Icons.assignment_outlined,
                              title: 'Requirements',
                              badge: '2 active',
                              badgeColor: AppColors.mintTeal,
                              onTap: () {
                                _closeNineDotDropdown();
                                context.go('/requirements');
                              },
                            ),
                            _buildShortcutCard(
                              icon: Icons.people_outline,
                              title: 'Find Experts',
                              badge: '5 match',
                              badgeColor: AppColors.info,
                              onTap: () {
                                _closeNineDotDropdown();
                                context.go('/experts');
                              },
                            ),
                            _buildShortcutCard(
                              icon: Icons.history_edu_outlined,
                              title: 'Contracts',
                              badge: '1 pending',
                              badgeColor: AppColors.warning,
                              onTap: () {
                                _closeNineDotDropdown();
                                Forms.showSuccessToast(context, 'Signed contracts are locked via PMO.');
                              },
                            ),
                            _buildShortcutCard(
                              icon: Icons.payments_outlined,
                              title: 'Payments',
                              badge: '₹4.2L spent',
                              badgeColor: AppColors.lightPrimary,
                              onTap: () {
                                _closeNineDotDropdown();
                                context.go('/payments');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_nineDotOverlay!);
  }

  void _closeNineDotDropdown() {
    _nineDotOverlay?.remove();
    _nineDotOverlay = null;
  }

  @override
  void dispose() {
    _closeNineDotDropdown();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.lightBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Glowing Search Bar
          Expanded(
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Focus(
                    onFocusChange: (focus) {
                      setState(() {
                        _isSearchFocused = focus;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSearchFocused ? AppColors.mintTeal : AppColors.lightBorder,
                          width: _isSearchFocused ? 1.5 : 1.0,
                        ),
                        boxShadow: _isSearchFocused
                            ? [
                                BoxShadow(
                                  color: AppColors.mintTeal.withOpacity(0.12),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search requirements, experts, invoices...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.lightTextSecondary),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Post Requirement Button
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Post Requirement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            onPressed: () {
              context.go('/requirements/create');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 18),

          // 9-Dot Quick Nav Button
          CompositedTransformTarget(
            link: _nineDotLink,
            child: IconButton(
              icon: const Icon(Icons.apps, color: AppColors.lightPrimary, size: 24),
              onPressed: _toggleNineDotDropdown,
            ),
          ),
          const SizedBox(width: 8),

          // Shaking Notification Bell
          ShakingBellIcon(
            unreadCount: ref.watch(notificationsProvider).where((n) => n.unread).length,
            onTap: widget.onNotificationClick,
          ),
          const SizedBox(width: 14),

          // Avatar
          const PulsingOnlineAvatar(avatarUrl: '', initials: 'SH'),
        ],
      ),
    );
  }
}

Widget _buildShortcutCard({
  required IconData icon,
  required String title,
  String? badge,
  Color? badgeColor,
  required VoidCallback onTap,
}) {
  return Card(
    color: AppColors.lightBg,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.lightBorder),
    ),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: AppColors.lightPrimary, size: 18),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.mintTeal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  )
              ],
            ),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// =========================================================================
// 6. HELPER SUB-WIDGETS
// =========================================================================

class ShakingBellIcon extends StatefulWidget {
  final int unreadCount;
  final VoidCallback onTap;
  const ShakingBellIcon({Key? key, required this.unreadCount, required this.onTap}) : super(key: key);

  @override
  State<ShakingBellIcon> createState() => _ShakingBellIconState();
}

class _ShakingBellIconState extends State<ShakingBellIcon> with SingleTickerProviderStateMixin {
  late AnimationController _bellController;
  bool _keepRunning = true;

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _startPeriodicShake();
  }

  void _startPeriodicShake() async {
    while (_keepRunning) {
      await Future.delayed(const Duration(seconds: 7));
      if (!mounted) break;
      if (widget.unreadCount > 0) {
        _bellController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _keepRunning = false;
    _bellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.15), weight: 10.0),
      TweenSequenceItem(tween: Tween<double>(begin: 0.15, end: -0.15), weight: 15.0),
      TweenSequenceItem(tween: Tween<double>(begin: -0.15, end: 0.1), weight: 10.0),
      TweenSequenceItem(tween: Tween<double>(begin: 0.1, end: -0.1), weight: 10.0),
      TweenSequenceItem(tween: Tween<double>(begin: -0.1, end: 0.0), weight: 5.0),
    ]).animate(_bellController);

    return AnimatedBuilder(
      animation: rotation,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotation.value,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: AppColors.lightPrimary, size: 24),
                onPressed: widget.onTap,
              ),
              if (widget.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${widget.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}

class PulsingOnlineAvatar extends StatefulWidget {
  final String avatarUrl;
  final String initials;
  const PulsingOnlineAvatar({Key? key, required this.avatarUrl, required this.initials}) : super(key: key);

  @override
  State<PulsingOnlineAvatar> createState() => _PulsingOnlineAvatarState();
}

class _PulsingOnlineAvatarState extends State<PulsingOnlineAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
          backgroundImage: widget.avatarUrl.isNotEmpty ? NetworkImage(widget.avatarUrl) : null,
          child: widget.avatarUrl.isEmpty
              ? Text(
                  widget.initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.lightPrimary,
                  ),
                )
              : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.6).animate(
                  CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
                ),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class HoverBrowseRolesButton extends StatefulWidget {
  final VoidCallback onTap;
  const HoverBrowseRolesButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<HoverBrowseRolesButton> createState() => _HoverBrowseRolesButtonState();
}

class _HoverBrowseRolesButtonState extends State<HoverBrowseRolesButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: _isHovered
                ? AppColors.mintGradient
                : const LinearGradient(
                    colors: [AppColors.lightPrimary, AppColors.lightPrimary],
                  ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.mintTeal.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.business_center_outlined,
                color: _isHovered ? Colors.black : Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Browse Roles',
                style: TextStyle(
                  color: _isHovered ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 7. NOTIFICATIONS DRAWER
// =========================================================================

class NotificationsDrawer extends ConsumerWidget {
  const NotificationsDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(notificationsProvider.notifier).markAllRead();
                      Forms.showSuccessToast(context, 'All notifications marked as read.');
                    },
                    child: const Text('Mark all read', style: TextStyle(color: AppColors.mintTeal)),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.lightBorder, height: 1.0),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_none_outlined, size: 48, color: AppColors.lightTextSecondary),
                          const SizedBox(height: 12),
                          Text('No notifications', style: GoogleFonts.inter(color: AppColors.lightTextSecondary)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        IconData iconData = Icons.info_outline;
                        Color iconBg = AppColors.lightMintHighlight;
                        Color iconColor = AppColors.mintTeal;

                        if (n.type == 'payment') {
                          iconData = Icons.payments_outlined;
                          iconBg = const Color(0xFFFEF3C7);
                          iconColor = AppColors.warning;
                        } else if (n.type == 'contract') {
                          iconData = Icons.history_edu_outlined;
                          iconBg = const Color(0xFFFFF1F2);
                          iconColor = AppColors.error;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          color: n.unread ? AppColors.lightMintHighlight.withOpacity(0.5) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: n.unread ? AppColors.mintTeal.withOpacity(0.3) : AppColors.lightBorder,
                              width: n.unread ? 1.5 : 1.0,
                            ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: iconBg,
                              child: Icon(iconData, color: iconColor, size: 18),
                            ),
                            title: Text(
                              n.title,
                              style: TextStyle(
                                fontWeight: n.unread ? FontWeight.bold : FontWeight.normal,
                                color: AppColors.lightTextPrimary,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              n.description,
                              style: const TextStyle(
                                color: AppColors.lightTextSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem {
  final String route;
  final String title;
  final IconData icon;
  final int? badgeCount;
  final Color? badgeColor;

  _SidebarItem({
    required this.route,
    required this.title,
    required this.icon,
    this.badgeCount,
    this.badgeColor,
  });
}
