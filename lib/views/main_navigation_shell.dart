import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../viewmodels/app_state.dart';
import 'landing_view.dart';
import 'projects_view.dart';
import 'network_view.dart';
import 'profile_view.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/tars_chatbot.dart';
import '../widgets/forms.dart';

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(tabNavigationProvider);
    final isChatOpen = ref.watch(isChatOpenProvider);

    final List<Widget> screens = const [
      LandingView(),
      ProjectsView(),
      NetworkView(),
      ProfileView(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMidnight,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.primaryTeal),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'CXO CONNECT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
        // ACTIONS REMOVED: Profile Avatar button is completely deleted from all views!
        actions: const [],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.cardBorder,
            height: 1.0,
          ),
        ),
      ),
      drawer: const _NavigationDrawer(),
      body: Stack(
        children: [
          // Screen Stack container
          Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundDark,
            ),
            child: IndexedStack(
              index: currentIndex,
              children: screens,
            ),
          ),

          // ASK TARS Chatbot Floating Panel
          const Positioned(
            bottom: 0,
            right: 0,
            child: TarsChatbot(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggles TARS chat overlay
          ref.read(isChatOpenProvider.notifier).update((state) => !state);
        },
        backgroundColor: AppColors.primaryTeal,
        child: Icon(
          isChatOpen ? Icons.close : Icons.chat_bubble_outline,
          color: AppColors.backgroundDark,
          size: 24,
        ),
      ),
      // BOTTOM NAVIGATION REMOVED: Unconditionally set to null to delete it from the entire application!
      bottomNavigationBar: null,
    );
  }
}

class _NavigationDrawer extends ConsumerWidget {
  const _NavigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Scroll Keys
    final homeKey = ref.watch(homeKeyProvider);
    final howItWorksKey = ref.watch(howItWorksKeyProvider);
    final benefitsKey = ref.watch(benefitsKeyProvider);
    final contactKey = ref.watch(contactKeyProvider);
    final userRole = ref.watch(userRoleProvider);

    return Drawer(
      backgroundColor: AppColors.backgroundMidnight,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CXO CONNECT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userRole == UserRole.guest
                        ? 'Enterprise Vetting & Match Platform'
                        : userRole == UserRole.company
                            ? 'Enterprise Workspace'
                            : 'Executive Advisor Portal',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Links List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _buildDrawerTile(
                    context: context,
                    ref: ref,
                    title: 'Home',
                    icon: Icons.home_outlined,
                    targetKey: homeKey,
                  ),
                  _buildDrawerTile(
                    context: context,
                    ref: ref,
                    title: 'How it Works',
                    icon: Icons.assignment_turned_in_outlined,
                    targetKey: howItWorksKey,
                  ),
                  _buildDrawerTile(
                    context: context,
                    ref: ref,
                    title: 'Membership Benefits',
                    icon: Icons.shield_outlined,
                    targetKey: benefitsKey,
                  ),
                  _buildDrawerTile(
                    context: context,
                    ref: ref,
                    title: 'Contact Us',
                    icon: Icons.mail_outline,
                    targetKey: contactKey,
                  ),

                  // Dynamic Workspace Dashboard Tabs displayed only when logged in
                  if (userRole != UserRole.guest) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Divider(color: AppColors.cardBorder),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                      child: Text(
                        'MY WORKSPACE',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    _buildTabDrawerTile(
                      context: context,
                      ref: ref,
                      title: 'Matches',
                      icon: Icons.shield_outlined,
                      tabIndex: 0,
                    ),
                    _buildTabDrawerTile(
                      context: context,
                      ref: ref,
                      title: 'Projects Marketplace',
                      icon: Icons.work_outline,
                      tabIndex: 1,
                    ),
                    _buildTabDrawerTile(
                      context: context,
                      ref: ref,
                      title: 'Expert Network',
                      icon: Icons.people_outline,
                      tabIndex: 2,
                    ),
                    _buildTabDrawerTile(
                      context: context,
                      ref: ref,
                      title: 'My Profile',
                      icon: Icons.person_outline,
                      tabIndex: 3,
                    ),
                  ],
                ],
              ),
            ),

            // Footer / Authentication actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 16),

                  if (userRole == UserRole.guest)
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: AppColors.tealGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryTeal.withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Navigator.pop(context);
                            AuthDialog.show(context); // Open Auth Gateway
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.person_add_alt_1_outlined,
                                color: AppColors.backgroundDark,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Join / Sign In',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.backgroundDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.accentBlueDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            ref.read(userRoleProvider.notifier).state = UserRole.guest;
                            ref.read(tabNavigationProvider.notifier).setTab(0); // Reset to Home/Landing
                            Navigator.pop(context);
                            Forms.showSuccessToast(context, 'Signed out successfully.');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_outlined,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sign Out',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Version text at bottom
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'v1.0.0 Stable',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required GlobalKey targetKey,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        // 1. Close drawer
        Navigator.pop(context);

        // 2. Switch bottom nav to tab 0 (Matches/Landing view) if not already active
        final currentTab = ref.read(tabNavigationProvider);
        if (currentTab != 0) {
          ref.read(tabNavigationProvider.notifier).setTab(0);
        }

        // 3. Post-frame scroll execution
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = targetKey.currentContext;
          if (ctx != null) {
            Scrollable.ensureVisible(
              ctx,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
          }
        });
      },
    );
  }

  Widget _buildTabDrawerTile({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required IconData icon,
    required int tabIndex,
  }) {
    final currentTab = ref.watch(tabNavigationProvider);
    final isSelected = currentTab == tabIndex;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
        size: 20,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13.5,
          color: isSelected ? AppColors.primaryTeal : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close drawer
        ref.read(tabNavigationProvider.notifier).setTab(tabIndex);
      },
    );
  }
}
