import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../models/models.dart';
import '../models/advisor_model.dart';
import '../models/project_model.dart';
import '../services/mock_data_store.dart';
import '../services/mock_service.dart';
import '../widgets/custom_charts.dart';
import '../widgets/custom_button.dart';
import '../widgets/forms.dart';
import '../viewmodels/app_state.dart';

// =========================================================================
// 1. UNIFIED SIGN-IN SCREEN (`/signin`)
// =========================================================================

class SignInView extends ConsumerStatefulWidget {
  final String? initialRole;
  const SignInView({Key? key, this.initialRole}) : super(key: key);

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  late bool isCompany;
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool otpSent = false;
  bool useMagicLink = false;

  @override
  void initState() {
    super.initState();
    isCompany = widget.initialRole == 'company' || widget.initialRole != 'expert';
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = isCompany ? AppColors.lightPrimary : AppColors.mintTeal;
    final titleText = isCompany ? 'Enterprise Executive Portal' : 'Verified Expert Access';
    final subtitleText = isCompany
        ? 'Deploy vetted senior advisors into your core strategic initiatives.'
        : 'Access matching engagements and manage escrow milestones.';

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 450,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.lightBorder, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo Icon and text
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCompany ? Icons.corporate_fare_outlined : Icons.shield_outlined,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'EXIGENTCX',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: AppColors.lightPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  titleText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitleText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Toggle Role Select
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.lightBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            isCompany = true;
                            otpSent = false;
                          }),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isCompany ? AppColors.lightPrimary : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Sign In as Company',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: isCompany ? Colors.white : AppColors.lightTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            isCompany = false;
                            otpSent = false;
                          }),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !isCompany ? AppColors.mintTeal : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Sign In as Expert',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: !isCompany ? Colors.white : AppColors.lightTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (!otpSent) ...[
                  // Email Field
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: AppColors.lightTextPrimary),
                    decoration: InputDecoration(
                      labelText: 'Admin/Professional Email',
                      prefixIcon: Icon(Icons.email_outlined, color: accentColor),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sign In Mode',
                        style: GoogleFonts.inter(color: AppColors.lightTextSecondary, fontSize: 13),
                      ),
                      Row(
                        children: [
                          Text(
                            useMagicLink ? 'Magic Link' : 'OTP Code',
                            style: GoogleFonts.inter(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: useMagicLink,
                            activeColor: accentColor,
                            onChanged: (v) => setState(() => useMagicLink = v),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      final email = _emailController.text.trim();
                      if (email == 'demo@cxo.com') {
                        ref.read(userRoleProvider.notifier).state = isCompany ? UserRole.company : UserRole.expert;
                        ref.read(demoStateProvider.notifier).state = DemoState(
                          isDemo: true,
                          isCompany: isCompany,
                          isExpert: !isCompany,
                        );
                        Forms.showSuccessToast(context, 'Signed in as Demo ${isCompany ? 'Company' : 'Expert'}.');
                        context.go(isCompany ? '/company-dashboard' : '/expert-dashboard');
                      } else if (email.isEmpty) {
                        Forms.showErrorToast(context, 'Please enter a valid email.');
                      } else {
                        setState(() {
                          otpSent = true;
                        });
                        Forms.showSuccessToast(context, 'Verification code sent to $email');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      isCompany ? 'Send OTP Code' : (useMagicLink ? 'Send Magic Link' : 'Send OTP Code'),
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Enter the verification code sent to ${_emailController.text}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: AppColors.lightTextSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (useMagicLink && !isCompany)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Magic link sent! Check your inbox.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.mintTeal,
                          ),
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (i) {
                        return SizedBox(
                          width: 50,
                          height: 60,
                          child: TextField(
                            controller: _otpControllers[i],
                            focusNode: _otpFocusNodes[i],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.lightTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLength: 1,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              counterText: '',
                            ),
                            onChanged: (v) {
                              if (v.isNotEmpty && i < 5) {
                                _otpFocusNodes[i + 1].requestFocus();
                              } else if (v.isEmpty && i > 0) {
                                _otpFocusNodes[i - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(userRoleProvider.notifier).state = isCompany ? UserRole.company : UserRole.expert;
                      Forms.showSuccessToast(context, 'Welcome to ExigentCX!');
                      context.go(isCompany ? '/company-dashboard' : '/expert-dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Confirm & Sign In',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => setState(() => otpSent = false),
                    child: Text('Back to Email Input', style: TextStyle(color: accentColor)),
                  )
                ],

                const SizedBox(height: 24),
                const Divider(color: AppColors.lightBorder),
                const SizedBox(height: 16),
                // Demo Trigger Helper
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentColor,
                    side: BorderSide(color: accentColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    _emailController.text = 'demo@cxo.com';
                    ref.read(userRoleProvider.notifier).state = isCompany ? UserRole.company : UserRole.expert;
                    ref.read(demoStateProvider.notifier).state = DemoState(
                      isDemo: true,
                      isCompany: isCompany,
                      isExpert: !isCompany,
                    );
                    Forms.showSuccessToast(context, 'Demo Mode Activated');
                    context.go(isCompany ? '/company-dashboard' : '/expert-dashboard');
                  },
                  child: Text(
                    'Instant Demo Bypass (demo@cxo.com)',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// 2. ADVISOR PORTAL - EXPERT INTERFACE
// =========================================================================

class ExpertDashboardView extends ConsumerStatefulWidget {
  const ExpertDashboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpertDashboardView> createState() => _ExpertDashboardViewState();
}

class _ExpertDashboardViewState extends ConsumerState<ExpertDashboardView> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Welcome Banner
            _buildWelcomeBanner(),
            const SizedBox(height: 24),

            // 2. Today's Schedule Header
            Text(
              "Today's Schedule",
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
            ),
            const SizedBox(height: 12),
            _buildHorizontalSchedule(),
            const SizedBox(height: 24),

            // 3. Quick Actions row
            _buildShortcutButtonsRow(),
            const SizedBox(height: 28),

            // 4. Two-Column Dashboard Content
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Matched Opportunities", subtitle: "+6 roles matched to your expertise"),
                        const SizedBox(height: 12),
                        _buildMatchedOpportunitiesRow(),
                        const SizedBox(height: 28),

                        _buildSectionHeader("Active Engagements"),
                        const SizedBox(height: 12),
                        _buildActiveEngagementsDashboard(),
                        const SizedBox(height: 28),

                        _buildSectionHeader("Your Performance"),
                        const SizedBox(height: 12),
                        _buildPerformanceRow(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Priority Actions Required"),
                        const SizedBox(height: 12),
                        _buildPendingActionsPanel(),
                        const SizedBox(height: 28),

                        _buildSectionHeader("Your Network"),
                        const SizedBox(height: 12),
                        _buildNetworkStatsCard(),
                        const SizedBox(height: 28),

                        _buildSectionHeader("Profile Strength"),
                        const SizedBox(height: 12),
                        _buildProfileStrengthCard(),
                        const SizedBox(height: 28),

                        _buildSectionHeader("Earnings Balance"),
                        const SizedBox(height: 12),
                        _buildEarningsBalanceCard(),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Matched Opportunities", subtitle: "+6 roles matched to your expertise"),
                  const SizedBox(height: 12),
                  _buildMatchedOpportunitiesRow(),
                  const SizedBox(height: 28),

                  _buildSectionHeader("Active Engagements"),
                  const SizedBox(height: 12),
                  _buildActiveEngagementsDashboard(),
                  const SizedBox(height: 28),

                  _buildSectionHeader("Your Performance"),
                  const SizedBox(height: 12),
                  _buildPerformanceRow(),
                  const SizedBox(height: 28),

                  _buildSectionHeader("Priority Actions Required"),
                  const SizedBox(height: 12),
                  _buildPendingActionsPanel(),
                  const SizedBox(height: 28),

                  _buildSectionHeader("Your Network"),
                  const SizedBox(height: 12),
                  _buildNetworkStatsCard(),
                  const SizedBox(height: 28),

                  _buildSectionHeader("Profile Strength"),
                  const SizedBox(height: 12),
                  _buildProfileStrengthCard(),
                  const SizedBox(height: 28),

                  _buildSectionHeader("Earnings Balance"),
                  const SizedBox(height: 12),
                  _buildEarningsBalanceCard(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.mintTeal,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
          ),
        ],
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lightMintHighlight, Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    HeroPulsingStars(),
                    SizedBox(width: 10),
                    Text(
                      'Verified Expert · Top 5%',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightPrimary, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Welcome, David.',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'You have 3 pending actions and 3 new role matches waiting. Your profile was viewed 12 times today.',
                  style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickBadge(Icons.access_time, '3 meetings today', AppColors.mintTeal.withOpacity(0.12), AppColors.lightPrimary),
                      const SizedBox(width: 8),
                      _buildQuickBadge(Icons.mail_outline, '3 unread messages', Colors.blue.withOpacity(0.1), Colors.blue[800]!),
                      const SizedBox(width: 8),
                      _buildQuickBadge(Icons.adjust, '1 deadline this week', AppColors.warning.withOpacity(0.12), Colors.orange[800]!),
                      const SizedBox(width: 8),
                      _buildQuickBadge(Icons.visibility_outlined, '12 profile views today', Colors.purple.withOpacity(0.08), Colors.purple[800]!),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 20),

          // Availability Toggle Switch Widget
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isAvailable ? AppColors.lightMintHighlight : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isAvailable ? AppColors.mintTeal : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _isAvailable = !_isAvailable;
                });
                Forms.showSuccessToast(
                  context,
                  _isAvailable ? 'Availability set to Active. Matches notified!' : 'Availability set to Off. Quiet mode enabled.',
                );
              },
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isAvailable ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isAvailable ? 'Available for New Projects' : 'Not Available',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.lightPrimary),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickBadge(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildHorizontalSchedule() {
    final List<Map<String, String>> events = [
      {
        'time': '11:00 AM',
        'title': 'Weekly Sync & Alignment',
        'company': 'Acme Corp',
        'duration': '30 min',
        'type': 'green',
      },
      {
        'time': '12:30 PM',
        'title': 'Financial Model Review',
        'company': 'TechScale Ventures',
        'duration': '45 min',
        'type': 'blue',
      },
      {
        'time': '04:00 PM',
        'title': 'Q3 Strategy Briefing',
        'company': 'HealthTech Startup',
        'duration': '60 min',
        'type': 'orange',
      },
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      final widgets = events.map((e) {
        Color borderAccent = AppColors.mintTeal;
        if (e['type'] == 'blue') borderAccent = Colors.blue;
        if (e['type'] == 'orange') borderAccent = AppColors.warning;

        return Card(
          margin: const EdgeInsets.only(right: 12, bottom: 8),
          child: Container(
            width: isWide ? 220 : double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: borderAccent, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e['time']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightPrimary)),
                    Text(e['duration']!, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  e['title']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary),
                ),
                const SizedBox(height: 4),
                Text(e['company']!, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
              ],
            ),
          ),
        );
      }).toList();

      final scheduleButton = Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, style: BorderStyle.solid, width: 1.5),
        ),
        child: InkWell(
          onTap: () {
            Forms.showSuccessToast(context, 'Calendar matching slot creator loading...');
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: isWide ? 180 : double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: AppColors.lightTextSecondary, size: 20),
                SizedBox(height: 6),
                Text(
                  'Schedule Meeting',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );

      if (isWide) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...widgets,
              scheduleButton,
            ],
          ),
        );
      } else {
        return Column(
          children: [
            ...widgets,
            scheduleButton,
          ],
        );
      }
    });
  }

  Widget _buildShortcutButtonsRow() {
    final List<Map<String, dynamic>> shortcuts = [
      {'title': 'Browse Roles', 'icon': Icons.work_outline, 'color': AppColors.mintTeal, 'route': '/expert-opportunities'},
      {'title': 'My Engagements', 'icon': Icons.trending_up, 'color': Colors.teal, 'route': '/expert-engagements'},
      {'title': 'Earnings', 'icon': Icons.payments_outlined, 'color': Colors.orange, 'route': '/expert-earnings'},
      {'title': 'Edit Profile', 'icon': Icons.person_outline, 'color': Colors.blue, 'route': '/expert-profile'},
      {'title': 'Messages', 'icon': Icons.chat_bubble_outline, 'color': AppColors.lightPrimary, 'route': '/messages'},
      {'title': 'Reviews', 'icon': Icons.star_outline, 'color': AppColors.warning, 'route': null},
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final double width = constraints.maxWidth;
      final int crossAxisCount = width > 900 ? 6 : (width > 600 ? 3 : 2);
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: width > 900 ? 1.6 : 2.0,
        ),
        itemCount: shortcuts.length,
        itemBuilder: (context, index) {
          final s = shortcuts[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.lightBorder, width: 1.0),
            ),
            child: InkWell(
              onTap: () {
                if (s['route'] != null) {
                  context.go(s['route']);
                } else {
                  Forms.showSuccessToast(context, 'No reviews found yet. Keep up the great work!');
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(s['icon'], color: s['color'], size: 24),
                    const SizedBox(height: 8),
                    Text(
                      s['title'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMatchedOpportunitiesRow() {
    final List<Map<String, dynamic>> opps = [
      {
        'title': 'Advisory Board — Finance',
        'company': 'Logistics Startup',
        'match': 88,
        'urgency': 'NEW',
        'size': 'Seed · 10-50 employees',
        'duration': '12 months',
        'budget': '₹90K - ₹1L/mo',
        'hours': '8 hrs/wk',
        'location': 'Remote',
        'skills': ['Supply Chain Finance', 'Working Capital', 'Unit Economics'],
        'applied': '2 applied · 3 days ago',
      },
      {
        'title': 'Fractional COO',
        'company': 'SaaS Scale-up',
        'match': 80,
        'urgency': 'Featured',
        'size': 'Series B · 100-500 employees',
        'duration': '9 months',
        'budget': '₹1.8L - ₹2.5L/mo',
        'hours': '15 hrs/wk',
        'location': 'Remote',
        'skills': ['Operations', 'Product Ops'],
        'applied': '6 applied · 14 days ago',
      }
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 800;
      return isWide
          ? Row(
              children: opps.map((opp) => Expanded(child: _buildOpportunityWidgetCard(opp))).toList(),
            )
          : Column(
              children: opps.map((opp) => _buildOpportunityWidgetCard(opp)).toList(),
            );
    });
  }

  Widget _buildOpportunityWidgetCard(Map<String, dynamic> opp) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lightMintHighlight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${opp['match']}% Match',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (opp['urgency'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: opp['urgency'] == 'NEW' ? Colors.green[100] : Colors.amber[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          opp['urgency'],
                          style: TextStyle(
                            color: opp['urgency'] == 'NEW' ? Colors.green : Colors.orange[800],
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
                const Icon(Icons.bookmark_outline, size: 16, color: AppColors.lightTextSecondary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    opp['company'][0],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.lightPrimary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opp['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${opp['company']} · ${opp['size']}', style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 10)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(opp['budget'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightPrimary)),
            const SizedBox(height: 2),
            Text('${opp['hours']} · ${opp['duration']} · ${opp['location']}', style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 10)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: (opp['skills'] as List<String>)
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(4)),
                        child: Text(s, style: const TextStyle(fontSize: 8, color: AppColors.lightTextSecondary)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(opp['applied'], style: const TextStyle(fontSize: 9, color: AppColors.lightTextSecondary)),
                SizedBox(
                  height: 28,
                  child: ElevatedButton(
                    onPressed: () {
                      _showProposalDialog(context, opp['title']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showProposalDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text('Apply for $title'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Proposed Retainer Rate (₹/month)'),
                  validator: (v) => v!.isEmpty ? 'Please enter rate' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Available Hours per Week'),
                  validator: (v) => v!.isEmpty ? 'Please enter hours' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Why are you a fit?'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Please enter pitch' : null,
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  Forms.showSuccessToast(context, 'Application submitted. Matching bridge established.');
                }
              },
              child: const Text('Submit Proposal'),
            )
          ],
        );
      },
    );
  }

  Widget _buildActiveEngagementsDashboard() {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Series B Funding Strategy',
        'company': 'Acme Corp',
        'avatar': 'AC',
        'status': 'IN PROGRESS',
        'statusColor': Colors.blue,
        'rate': '₹3L/mo',
        'date': 'Apr 30, 2025',
        'nextMilestone': 'Investor Deck & Data Room',
        'progress': 0.65,
      },
      {
        'title': 'Financial Due Diligence',
        'company': 'TechScale Ventures',
        'avatar': 'TV',
        'status': 'ON TRACK',
        'statusColor': Colors.green,
        'rate': '₹2.5L/mo',
        'date': 'May 15, 2025',
        'nextMilestone': 'Submit Due Diligence Report',
        'progress': 0.40,
      }
    ];

    return LayoutBuilder(builder: (context, constraints) {
      final widgets = items.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                      child: Text(item['avatar']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightTextPrimary)),
                          Text(item['company']!, style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item['statusColor'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status']!,
                        style: TextStyle(color: item['statusColor']!, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MONTHLY RATE', style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                        const SizedBox(height: 2),
                        Text(item['rate']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NEXT MILESTONE DUE', style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                        const SizedBox(height: 2),
                        Text(item['date']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Next: ${item['nextMilestone']!}', style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: item['progress']!,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          color: AppColors.mintTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(item['progress']! * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        context.go('/engagements/eng1');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.lightPrimary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Open Workspace', style: TextStyle(color: AppColors.lightPrimary)),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.file_present_outlined, color: AppColors.lightTextSecondary),
                          onPressed: () => Forms.showSuccessToast(context, 'Opening shared files...'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: AppColors.lightTextSecondary),
                          onPressed: () => context.go('/messages'),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }).toList();

      return Column(children: widgets);
    });
  }

  Widget _buildPerformanceRow() {
    final List<Map<String, String>> stats = [
      {'title': 'Avg Response', 'val': '< 2 hrs', 'sub': 'Top 10% speed', 'color': 'green'},
      {'title': 'Client Rating', 'val': '4.92 / 5', 'sub': '23 reviews', 'color': 'orange'},
      {'title': 'Completion', 'val': '98%', 'sub': 'On-time delivery', 'color': 'blue'},
    ];

    return Row(
      children: stats.map((s) {
        Color bg = AppColors.lightMintHighlight;
        Color text = AppColors.mintTeal;
        if (s['color'] == 'orange') {
          bg = Colors.amber.withOpacity(0.1);
          text = Colors.orange[800]!;
        } else if (s['color'] == 'blue') {
          bg = Colors.blue.withOpacity(0.1);
          text = Colors.blue[800]!;
        }

        return Expanded(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                    child: Icon(
                      s['color'] == 'green'
                          ? Icons.timer_outlined
                          : (s['color'] == 'orange' ? Icons.star_border : Icons.check_circle_outline),
                      size: 16,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(s['val']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightTextPrimary)),
                  const SizedBox(height: 2),
                  Text(s['title']!, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
                  Text(s['sub']!, style: const TextStyle(fontSize: 9, color: AppColors.lightTextSecondary)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPendingActionsPanel() {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Submit Milestone Deliverable',
        'project': 'Series B Funding Strategy',
        'tag': 'SUBMIT',
        'due': 'Due in 3 days',
        'borderColor': Colors.amber,
        'bgColor': Colors.amber.withOpacity(0.05),
        'buttonText': 'Submit Deliverable',
        'route': '/expert-engagements',
      },
      {
        'title': 'Review & Sign Contract',
        'project': 'Financial Due Diligence',
        'tag': 'SIGN',
        'due': 'Expires tomorrow',
        'borderColor': Colors.red,
        'bgColor': Colors.red.withOpacity(0.05),
        'buttonText': 'Sign Contract',
        'route': '/expert-contracts',
      },
      {
        'title': 'New Message from Acme Corp',
        'project': 'Series B Funding Strategy',
        'tag': 'MESSAGE',
        'due': '2 hours ago',
        'borderColor': Colors.blue,
        'bgColor': Colors.blue.withOpacity(0.05),
        'buttonText': 'Open Message',
        'route': '/messages',
      }
    ];

    return Column(
      children: items.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: item['borderColor'] as Color, width: 4)),
              color: item['bgColor'] as Color,
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (item['borderColor'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['tag']!,
                        style: TextStyle(color: item['borderColor']!, fontWeight: FontWeight.bold, fontSize: 9),
                      ),
                    ),
                    Text(item['due']!, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.lightTextPrimary)),
                Text(item['project']!, style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 11.5)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go(item['route']!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(item['buttonText']!, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNetworkStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNetworkStatBox('33', 'Referrals'),
                _buildNetworkStatBox('0', 'Following'),
                _buildNetworkStatBox('0', 'Connected'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => Forms.showSuccessToast(context, 'Inviting network partners...'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 16),
                label: const Text('Grow Your Network', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatBox(String val, String label) {
    return Column(
      children: [
        Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
      ],
    );
  }

  Widget _buildProfileStrengthCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: 0.18,
                        backgroundColor: Colors.grey[200],
                        color: AppColors.mintTeal,
                        strokeWidth: 6,
                      ),
                    ),
                    Text('18%', style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Almost there!', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary)),
                      const Text('Complete your profile to unlock Premium matches.', style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 8),
            _buildChecklistRow(true, 'Basic info complete'),
            _buildChecklistRow(true, 'Work experience added'),
            _buildChecklistRow(false, 'Skills added'),
            _buildChecklistRow(false, 'Rate card set'),
            _buildChecklistRow(false, 'Resume uploaded'),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () => context.go('/expert-profile'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                child: const Text('Complete Profile', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistRow(bool checked, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: checked ? Colors.green : Colors.grey,
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: checked ? AppColors.lightTextPrimary : AppColors.lightTextSecondary,
              decoration: checked ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EARNINGS BALANCE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('₹3,50,000', style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Next payout: Apr 30, 2025', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('IN RETENTION', style: TextStyle(color: Colors.white70, fontSize: 8)),
                      const SizedBox(height: 2),
                      Text('₹1,23,000', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      const SizedBox(height: 2),
                      const Text('2 milestones', style: TextStyle(color: Colors.white70, fontSize: 8)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PENDING', style: TextStyle(color: Colors.white70, fontSize: 8)),
                      const SizedBox(height: 2),
                      Text('₹20,000', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      const SizedBox(height: 2),
                      const Text('Next payout', style: TextStyle(color: Colors.white70, fontSize: 8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: () => context.go('/expert-earnings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mintTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Earnings Dashboard', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}

// =========================================================================
// 3. MATCHED OPPORTUNITIES CAROUSEL
// =========================================================================

class MatchedOpportunitiesCarousel extends StatefulWidget {
  const MatchedOpportunitiesCarousel({Key? key}) : super(key: key);

  @override
  State<MatchedOpportunitiesCarousel> createState() => _MatchedOpportunitiesCarouselState();
}

class _MatchedOpportunitiesCarouselState extends State<MatchedOpportunitiesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentIndex = 0;
  Timer? _timer;
  bool _isPaused = false;
  double _linearProgress = 0.0;
  Timer? _progressTimer;

  final List<Map<String, dynamic>> _opportunities = [
    {
      'title': 'Fractional Chief Financial Officer',
      'company': 'TechScale Ventures',
      'match': 96,
      'urgency': 'Immediate',
      'new': true,
      'size': 'Series A · 50-200 employees',
      'duration': '6 months',
      'budget': '₹2.5L - ₹3.5L/mo',
      'hours': '20 hrs/wk',
      'location': 'Remote',
      'skills': ['Financial Modeling', 'Fundraising', 'M&A Due Diligence'],
    },
    {
      'title': 'Interim CTO Systems Overhaul',
      'company': 'HealthTech Startup',
      'match': 92,
      'urgency': 'High',
      'new': true,
      'size': 'Seed · 10-30 employees',
      'duration': '3 months',
      'budget': '₹3.0L - ₹4.0L/mo',
      'hours': '40 hrs/wk',
      'location': 'Hybrid (Bangalore)',
      'skills': ['Tech Architecture', 'Compliance', 'Cloud Migration'],
    },
    {
      'title': 'Fractional COO Operations Lead',
      'company': 'Logistics Corp',
      'match': 89,
      'urgency': 'Medium',
      'new': false,
      'size': 'Series B · 200+ employees',
      'duration': '12 months',
      'budget': '₹2.0L - ₹3.0L/mo',
      'hours': '15 hrs/wk',
      'location': 'Remote',
      'skills': ['Operations', 'SLA Adherence', 'Team Management'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _startProgress();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _opportunities.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  void _startProgress() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _linearProgress += 100 / 3500;
          if (_linearProgress >= 1.0) {
            _linearProgress = 0.0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isPaused = true;
      }),
      onExit: (_) => setState(() {
        _isPaused = false;
        _linearProgress = 0.0;
      }),
      child: Column(
        children: [
          SizedBox(
            height: 290,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _opportunities.length,
                  onPageChanged: (idx) {
                    setState(() {
                      _currentIndex = idx;
                      _linearProgress = 0.0;
                    });
                  },
                  itemBuilder: (context, index) {
                    final opp = _opportunities[index];
                    return _buildOpportunityCard(opp);
                  },
                ),
                Positioned(
                  left: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 16),
                      onPressed: () {
                        if (_currentIndex > 0) {
                          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, size: 16),
                      onPressed: () {
                        if (_currentIndex < _opportunities.length - 1) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(_opportunities.length, (idx) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentIndex == idx ? AppColors.mintTeal : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                );
              }),
              if (_isPaused) ...[
                const SizedBox(width: 12),
                Text(
                  'Paused',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold),
                )
              ]
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: LinearProgressIndicator(
              value: _linearProgress,
              color: AppColors.mintTeal,
              backgroundColor: Colors.grey[200],
              minHeight: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> opp) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.mintGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${opp['match']}% Match',
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (opp['new'])
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(4)),
                        child: const Text('NEW', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9)),
                      )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    opp['urgency'],
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                )
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.mintGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    opp['company'][0],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opp['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${opp['company']} · ${opp['size']}', style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 14),
            Table(
              border: TableBorder.all(color: AppColors.lightBorder, borderRadius: BorderRadius.circular(8)),
              children: [
                TableRow(
                  children: [
                    _buildTableCell('Budget', opp['budget']),
                    _buildTableCell('Commitment', opp['hours']),
                    _buildTableCell('Location', opp['location']),
                  ],
                )
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: (opp['skills'] as List<String>)
                        .map((s) => Chip(
                              label: Text(s, style: const TextStyle(fontSize: 9)),
                              backgroundColor: AppColors.lightBg,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Forms.showSuccessToast(context, 'Loading detailed specification file for ${opp['title']}...');
                      },
                      child: const Text('Details', style: TextStyle(color: AppColors.lightPrimary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        _showProposalDialog(context, opp['title']);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                      child: const Text('Apply Now', style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
        ],
      ),
    );
  }

  void _showProposalDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text('Apply for $title'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Proposed Retainer Rate (₹/month)'),
                  validator: (v) => v!.isEmpty ? 'Please enter rate' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Available Hours per Week'),
                  validator: (v) => v!.isEmpty ? 'Please enter hours' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Why are you a fit?'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Please enter pitch' : null,
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  Forms.showSuccessToast(context, 'Application submitted. Matching bridge established.');
                }
              },
              child: const Text('Submit Proposal'),
            )
          ],
        );
      },
    );
  }
}

// =========================================================================
// 4. CONNECTION REQUESTS CONTAINER
// =========================================================================

class ConnectionRequestsContainer extends StatefulWidget {
  const ConnectionRequestsContainer({Key? key}) : super(key: key);

  @override
  State<ConnectionRequestsContainer> createState() => _ConnectionRequestsContainerState();
}

class _ConnectionRequestsContainerState extends State<ConnectionRequestsContainer> {
  bool _hasRequest = true;

  @override
  Widget build(BuildContext context) {
    if (!_hasRequest) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              'No pending connection requests.',
              style: GoogleFonts.inter(color: AppColors.lightTextSecondary, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                  child: const Text('A', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acme Corp',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary),
                      ),
                      const Text(
                        'Wants to connect with you.',
                        style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _hasRequest = false;
                      });
                      Forms.showSuccessToast(context, 'Connection request declined.');
                    },
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasRequest = false;
                      });
                      Forms.showSuccessToast(context, 'Successfully connected! Acme Corp added to your active networks.');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                    child: const Text('Accept', style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 5. EXPERT SUB-VIEWS
// =========================================================================

class ExpertOpportunitiesView extends StatefulWidget {
  const ExpertOpportunitiesView({Key? key}) : super(key: key);

  @override
  State<ExpertOpportunitiesView> createState() => _ExpertOpportunitiesViewState();
}

class _ExpertOpportunitiesViewState extends State<ExpertOpportunitiesView> {
  bool _fractional = true;
  bool _interim = false;
  bool _advisory = false;
  bool _project = false;
  String _selectedBudget = 'Any';
  String _searchQuery = '';
  String _selectedTab = 'All';

  final List<Map<String, dynamic>> _allOpportunities = [
    {
      'title': 'Fractional CFO',
      'company': 'HealthTech Startup',
      'logo': 'HT',
      'logoColor': const Color(0xFF134E40),
      'match': 96,
      'type': 'Fractional',
      'urgency': 'IMMEDIATE',
      'tag': 'NEW',
      'desc': 'We are a Series A HealthTech company looking for an experienced CFO to lead our Series B fundraising and build our financial infrastructure. The ideal candidate has prior experience...',
      'budget': '₹2L - ₹3L/mo',
      'hours': '20 hrs/wk',
      'duration': '6 months',
      'location': 'Remote',
      'skills': ['Financial Modeling', 'Fundraising', 'M&A', '+1'],
      'applied': '4 applied · 2 days ago',
      'verified': true,
    },
    {
      'title': 'Interim CFO',
      'company': 'D2C Brand',
      'logo': 'DC',
      'logoColor': const Color(0xFF0F172A),
      'match': 91,
      'type': 'Interim',
      'urgency': 'IMMEDIATE',
      'tag': 'Featured',
      'desc': 'Fast-growing D2C brand looking for an Interim CFO to support our IPO preparation process. You will work closely with the founding team and investment bankers.',
      'budget': '₹2.5L - ₹4L/mo',
      'hours': '40 hrs/wk',
      'duration': '3 months',
      'location': 'Hybrid',
      'skills': ['P&L Management', 'Investor Relations', 'IPO Readiness', '+1'],
      'applied': '7 applied · 1 week ago',
      'verified': true,
    },
    {
      'title': 'Advisory Board — Finance',
      'company': 'Logistics Startup',
      'logo': 'LS',
      'logoColor': const Color(0xFF16A34A),
      'match': 88,
      'type': 'Advisory',
      'urgency': 'NEW',
      'tag': 'Seed',
      'desc': 'Early-stage logistics startup seeking an experienced finance advisor to help us build our financial model and prepare for our Seed round.',
      'budget': '₹90K - ₹1L/mo',
      'hours': '8 hrs/wk',
      'duration': '12 months',
      'location': 'Remote',
      'skills': ['Supply Chain Finance', 'Working Capital', 'Unit Economics'],
      'applied': '2 applied · 3 days ago',
      'verified': true,
    },
    {
      'title': 'Fractional VP Finance',
      'company': 'SaaS Platform',
      'logo': 'SP',
      'logoColor': const Color(0xFF4F46E5),
      'match': 84,
      'type': 'Fractional',
      'urgency': '',
      'tag': '',
      'desc': 'B2B SaaS company looking for a Fractional VP Finance to own our financial planning, board reporting, and revenue operations.',
      'budget': '₹1.5L - ₹2.5L/mo',
      'hours': '15 hrs/wk',
      'duration': '9 months',
      'location': 'Remote',
      'skills': ['SaaS Metrics', 'Board Reporting', 'Revenue Forecasting', '+1'],
      'applied': '9 applied · 5 days ago',
      'verified': true,
    },
    {
      'title': 'Interim Group CFO',
      'company': 'Manufacturing Conglomerate',
      'logo': 'MC',
      'logoColor': const Color(0xFF2563EB),
      'match': 79,
      'type': 'Interim',
      'urgency': 'IMMEDIATE',
      'tag': '',
      'desc': 'Listed manufacturing group seeking a seasoned Group CFO for a 6-month interim engagement to manage a major acquisition integration.',
      'budget': '₹5L - ₹8L/mo',
      'hours': '40 hrs/wk',
      'duration': '6 months',
      'location': 'In Office',
      'skills': ['Group Finance', 'IFRS', 'M&A Integration', '+1'],
      'applied': '12 applied · 2 weeks ago',
      'verified': true,
    },
    {
      'title': 'Finance Advisory — Pre-IPO',
      'company': 'EdTech Unicorn',
      'logo': 'EU',
      'logoColor': const Color(0xFF7C3AED),
      'match': 75,
      'type': 'Advisory',
      'urgency': 'Featured',
      'desc': "India's leading EdTech platform preparing for IPO in 2026. Looking for a seasoned financial advisor with prior public market experience.",
      'budget': '₹1L - ₹1.8L/mo',
      'hours': '10 hrs/wk',
      'duration': '18 months',
      'location': 'Remote',
      'skills': ['IPO Preparation', 'Investor Relations', 'Regulatory Compliance', '+1'],
      'applied': '15 applied · 1 week ago',
      'verified': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Filter Panel (For Desktop)
          if (isWide)
            Container(
              width: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: AppColors.lightBorder, width: 1.5)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.tune, size: 18, color: AppColors.lightPrimary),
                        SizedBox(width: 8),
                        Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightTextPrimary)),
                      ],
                    ),
                    const Divider(height: 24),

                    Text('ENGAGEMENT TYPE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.lightTextPrimary, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    _buildCheckboxFilter('Fractional', _fractional, (v) => setState(() => _fractional = v!)),
                    _buildCheckboxFilter('Interim', _interim, (v) => setState(() => _interim = v!)),
                    _buildCheckboxFilter('Advisory', _advisory, (v) => setState(() => _advisory = v!)),
                    _buildCheckboxFilter('Project', _project, (v) => setState(() => _project = v!)),
                    const SizedBox(height: 24),

                    _buildDropdownFilter('INDUSTRY'),
                    const SizedBox(height: 24),

                    _buildDropdownFilter('COMMITMENT'),
                    const SizedBox(height: 24),

                    _buildDropdownFilter('LOCATION'),
                    const SizedBox(height: 24),

                    _buildDropdownFilter('URGENCY'),
                    const SizedBox(height: 24),

                    Text('BUDGET RANGE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.lightTextPrimary, letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    _buildRadioFilter('Any'),
                    _buildRadioFilter('Under ₹1L/mo'),
                    _buildRadioFilter('₹1L - ₹2L/mo'),
                    _buildRadioFilter('₹2L - ₹4L/mo'),
                    _buildRadioFilter('₹4L+/mo'),
                  ],
                ),
              ),
            ),

          // Right Opportunities List Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upper stats block matching Screenshot 1 header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Opportunities',
                              style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sleek, executive-level opportunities tailored specifically to your background and expertise.',
                              style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // Stats badges
                      Row(
                        children: [
                          _buildStatHeaderBadge('MATCHES', '6 roles'),
                          const SizedBox(width: 8),
                          _buildStatHeaderBadge('AVG FIT', '86% Score'),
                          const SizedBox(width: 8),
                          _buildStatHeaderBadge('URGENT', '3 roles', isAlert: true),
                          const SizedBox(width: 12),
                          // Grid/list view toggles
                          Container(
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                IconButton(icon: const Icon(Icons.grid_view, size: 16), onPressed: () {}, color: AppColors.lightPrimary),
                                IconButton(icon: const Icon(Icons.menu, size: 16), onPressed: () {}, color: Colors.grey),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by title, company, skill, or industry...',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.lightBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.lightBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.mintTeal, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tabs Category & Sorting Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: ['All', 'Best Match', 'New', 'Saved', 'Applied'].map((tab) {
                          final isSel = _selectedTab == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () => setState(() => _selectedTab = tab),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.lightPrimary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tab,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? Colors.white : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      Row(
                        children: [
                          const Text('Showing 6 opportunities', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.lightBorder)),
                            child: Row(
                              children: const [
                                Text('Best Match', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down, size: 14),
                              ],
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 6 Opportunities Grid View
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWide ? 1.45 : 1.35,
                    ),
                    itemCount: _allOpportunities.length,
                    itemBuilder: (context, idx) {
                      final opp = _allOpportunities[idx];
                      return _buildJobGridCard(opp);
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatHeaderBadge(String label, String value, {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isAlert ? Colors.red.withOpacity(0.08) : AppColors.lightMintHighlight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 8, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
              Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: isAlert ? Colors.redAccent : AppColors.lightPrimary)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCheckboxFilter(String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.lightPrimary),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildRadioFilter(String label) {
    final isSelected = _selectedBudget == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Radio<String>(
            value: label,
            groupValue: _selectedBudget,
            activeColor: AppColors.lightPrimary,
            onChanged: (v) {
              setState(() {
                _selectedBudget = v!;
              });
            },
          ),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.lightTextPrimary, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Any', style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary)),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobGridCard(Map<String, dynamic> opp) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${opp['match']}% Match',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9),
                          ),
                        ),
                        if (opp['tag'] != '') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              opp['tag'],
                              style: TextStyle(color: Colors.orange[800]!, fontWeight: FontWeight.bold, fontSize: 9),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (opp['urgency'] != '')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          opp['urgency'],
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 9),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: opp['logoColor'],
                      child: Text(opp['logo'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opp['title'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightTextPrimary)),
                          Text('${opp['company']} · ${opp['type']}', style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  opp['desc'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
            Column(
              children: [
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opp['budget'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightPrimary)),
                        Text('${opp['hours']} · ${opp['location']} · ${opp['duration']}', style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 10)),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.share_outlined, size: 16),
                          onPressed: () => Forms.showSuccessToast(context, 'Link copied to clipboard!'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, size: 16),
                          onPressed: () => Forms.showSuccessToast(context, 'Role saved to bookmarks!'),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () {
                              _showApplyDialog(context, opp['title']);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                            child: const Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showApplyDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: Text('Apply for $title'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Proposed Retainer Rate (₹/month)'),
                  validator: (v) => v!.isEmpty ? 'Please enter rate' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Available Hours per Week'),
                  validator: (v) => v!.isEmpty ? 'Please enter hours' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Why are you a fit?'),
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Please enter pitch' : null,
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context);
                  Forms.showSuccessToast(context, 'Application submitted. Matching bridge established.');
                }
              },
              child: const Text('Submit Proposal'),
            )
          ],
        );
      },
    );
  }
}

class ExpertEngagementsView extends ConsumerWidget {
  const ExpertEngagementsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Engagements',
                        style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildHeaderPill('2 active', AppColors.mintTeal.withOpacity(0.12), AppColors.lightPrimary),
                          const SizedBox(width: 8),
                          _buildHeaderPill('2 actions pending', Colors.orange.withOpacity(0.12), Colors.orange[800]!),
                          const SizedBox(width: 8),
                          _buildHeaderPill('52% avg completion', Colors.blue.withOpacity(0.1), Colors.blue[800]!),
                        ],
                      )
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => context.go('/expert-opportunities'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                  icon: const Icon(Icons.search, color: Colors.white, size: 16),
                  label: const Text('Find More Roles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                )
              ],
            ),
            const SizedBox(height: 24),

            // 2. Alert Metrics Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAlertBadge('TOTAL MONTHLY VALUE', '₹5.5L/mo'),
                  _buildDivider(),
                  _buildAlertBadge('IN ESCROW', '₹1,20,000'),
                  _buildDivider(),
                  _buildAlertBadge('NEXT PAYOUT', 'Apr 30, 2025'),
                  _buildDivider(),
                  _buildAlertBadge('MILESTONES DUE', '1 this month', isAlert: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Stats cards
            Row(
              children: [
                Expanded(child: _buildEngageStatCard('2', 'ACTIVE', Icons.adjust, AppColors.mintTeal)),
                const SizedBox(width: 16),
                Expanded(child: _buildEngageStatCard('₹5.5L', 'THIS MONTH', Icons.currency_rupee, Colors.teal)),
                const SizedBox(width: 16),
                Expanded(child: _buildEngageStatCard('52%', 'AVG PROGRESS', Icons.trending_up, Colors.blue)),
              ],
            ),
            const SizedBox(height: 28),

            // 4. Split Layout or Vertical Stack
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Active Workspace', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                        const SizedBox(height: 12),
                        _buildActiveList(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Upcoming Milestones', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All ->', style: TextStyle(color: AppColors.mintTeal, fontSize: 12)),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildMilestonesPanel(context),
                      ],
                    ),
                  )
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Workspace', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                  const SizedBox(height: 12),
                  _buildActiveList(context),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Upcoming Milestones', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All ->', style: TextStyle(color: AppColors.mintTeal, fontSize: 12)),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMilestonesPanel(context),
                ],
              ),
            const SizedBox(height: 28),

            // 5. Monthly Earnings banner card
            _buildMonthlyEarningsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPill(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildAlertBadge(String label, String value, {bool isAlert = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isAlert ? Colors.redAccent : AppColors.lightPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1.5, color: AppColors.lightBorder);
  }

  Widget _buildEngageStatCard(String val, String label, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 10),
                Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveList(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'id': 'eng1',
        'title': 'Series B Funding Strategy',
        'company': 'Acme Corp',
        'avatar': 'AC',
        'status': 'IN PROGRESS',
        'statusColor': Colors.blue,
        'rate': '₹3L/mo',
        'date': 'Apr 30, 2025',
        'nextMilestone': 'Submit Investor Deck',
        'progress': 0.65,
      },
      {
        'id': 'eng2',
        'title': 'Financial Due Diligence',
        'company': 'TechScale Ventures',
        'avatar': 'TV',
        'status': 'ON TRACK',
        'statusColor': Colors.green,
        'rate': '₹2.5L/mo',
        'date': 'May 15, 2025',
        'nextMilestone': 'Submit Due Diligence Report',
        'progress': 0.40,
      }
    ];

    return Column(
      children: items.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
                      child: Text(item['avatar']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightTextPrimary)),
                          Text(item['company']!, style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (item['statusColor'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['status']!,
                        style: TextStyle(color: item['statusColor']!, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('MONTHLY RATE', style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                        const SizedBox(height: 2),
                        Text(item['rate']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NEXT PAYOUT', style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                        const SizedBox(height: 2),
                        Text(item['date']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Next: ${item['nextMilestone']!}', style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: item['progress']!,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          color: AppColors.mintTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${(item['progress']! * 100).toInt()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.go('/engagements/${item['id']}');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                      child: const Text('Open Workspace', style: TextStyle(color: Colors.white)),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.file_present_outlined, color: AppColors.lightTextSecondary),
                          onPressed: () => Forms.showSuccessToast(context, 'Opening shared files...'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: AppColors.lightTextSecondary),
                          onPressed: () => context.go('/messages'),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMilestonesPanel(BuildContext context) {
    final List<Map<String, dynamic>> milestones = [
      {
        'title': 'Investor Deck & Data Room',
        'company': 'Acme Corp',
        'date': 'Due Apr 30, 2025',
        'value': '₹2.5L',
        'status': 'In Progress',
        'color': Colors.amber,
      },
      {
        'title': 'Due Diligence Report',
        'company': 'TechScale Ventures',
        'date': 'Due May 16, 2025',
        'value': '₹2L',
        'status': 'Upcoming',
        'color': Colors.grey,
      }
    ];

    return Column(
      children: milestones.map((m) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  m['status'] == 'In Progress' ? Icons.pending_outlined : Icons.calendar_today_outlined,
                  color: m['color']!,
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary)),
                      Text('${m['company']} · ${m['date']}', style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(m['value']!, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
                    Text(
                      m['status']!,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: m['status'] == 'In Progress' ? Colors.orange[800] : Colors.grey[700],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyEarningsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EARNINGS THIS MONTH', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('₹5,50,000', style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.go('/expert-earnings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mintTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('View Earnings', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('RECEIVED', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      const SizedBox(height: 4),
                      Text('₹3,50,000', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      const Text('2 milestones', style: TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('IN ESCROW', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      const SizedBox(height: 4),
                      Text('₹1,20,000', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      const Text('Pending approval', style: TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('UPCOMING', style: TextStyle(color: Colors.white70, fontSize: 9)),
                      const SizedBox(height: 4),
                      Text('₹80,000', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                      const Text('Next payout', style: TextStyle(color: Colors.white70, fontSize: 9)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ExpertContractsView extends StatefulWidget {
  const ExpertContractsView({Key? key}) : super(key: key);

  @override
  State<ExpertContractsView> createState() => _ExpertContractsViewState();
}

class _ExpertContractsViewState extends State<ExpertContractsView> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<Map<String, dynamic>> _contracts = [
    {
      'type': 'Engagement Agreement',
      'title': 'Engagement Agreement — Interim CFO',
      'company': 'Acme Corp',
      'companyCode': 'AC',
      'project': 'Series B Funding Strategy',
      'budget': '₹18,00,000',
      'dates': 'Feb 1, 2026 -> Jul 31, 2026',
      'files': '8pp · 1.2 MB',
      'status': 'Pending Signature',
      'statusColor': Colors.orange,
      'youSigned': false,
      'clientSigned': true,
      'footer': 'Sign before Feb 3, 2026',
      'actionType': 'sign',
    },
    {
      'type': 'NDA',
      'title': 'Non-Disclosure Agreement — Acme Corp',
      'company': 'Acme Corp',
      'companyCode': 'AC',
      'project': 'Series B Funding Strategy',
      'budget': '',
      'dates': 'Feb 1, 2025 -> Feb 1, 2027',
      'files': '4pp · 0.8 MB',
      'status': 'Signed',
      'statusColor': Colors.green,
      'youSigned': true,
      'clientSigned': true,
      'footer': 'Fully executed Feb 1, 2025',
      'actionType': 'view',
    },
    {
      'type': 'Engagement Agreement',
      'title': 'Engagement Agreement — Fractional CMO',
      'company': 'BrandScale Pvt Ltd',
      'companyCode': 'BS',
      'project': 'Go-to-Market Expansion',
      'budget': '₹9,00,000',
      'dates': 'Mar 1, 2025 -> May 31, 2025',
      'files': '8pp · 1.1 MB',
      'status': 'Signed',
      'statusColor': Colors.green,
      'youSigned': true,
      'clientSigned': true,
      'footer': 'Fully executed Feb 28, 2025',
      'actionType': 'view',
    },
    {
      'type': 'NDA',
      'title': 'Non-Disclosure Agreement — BrandScale',
      'company': 'BrandScale Pvt Ltd',
      'companyCode': 'BS',
      'project': 'Go-to-Market Expansion',
      'budget': '',
      'dates': 'Feb 28, 2025 -> Feb 28, 2027',
      'files': '4pp · 0.6 MB',
      'status': 'Signed',
      'statusColor': Colors.green,
      'youSigned': true,
      'clientSigned': true,
      'footer': 'Fully executed Feb 28, 2025',
      'actionType': 'view',
    },
    {
      'type': 'Engagement Agreement',
      'title': 'Engagement Agreement — VP Engineering',
      'company': 'TechScale Ventures',
      'companyCode': 'TV',
      'project': 'Tech Infrastructure Scale-up',
      'budget': '₹7,20,000',
      'dates': 'May 1, 2025 -> Aug 31, 2025',
      'files': '8pp · 1.0 MB',
      'status': 'Under Review',
      'statusColor': Colors.blue,
      'youSigned': false,
      'clientSigned': false,
      'footer': 'Sign before Apr 30, 2025',
      'actionType': 'view',
    },
    {
      'type': 'Advisory Agreement',
      'title': 'Advisory Agreement — Interim COO',
      'company': 'OpsCo Industries',
      'companyCode': 'OI',
      'project': 'Operations Restructuring',
      'budget': '₹4,50,000',
      'dates': 'Nov 1, 2024 -> Jan 31, 2025',
      'files': '6pp · 0.9 MB',
      'status': 'Expired',
      'statusColor': Colors.red,
      'youSigned': false,
      'clientSigned': false,
      'footer': 'Sign before Oct 30, 2024',
      'actionType': 'view',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _contracts.where((c) {
      final matchesSearch = c['title']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c['company']!.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;
      if (_selectedFilter == 'All') return true;
      return c['status'] == _selectedFilter;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Block
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Contracts & NDAs',
                        style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'All agreements between you and your client companies, managed and secured by ExigentCX.',
                        style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightMintHighlight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.mintTeal),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified_user_outlined, size: 14, color: AppColors.mintTeal),
                      SizedBox(width: 6),
                      Text('Platform Secured & Legally Binding', style: TextStyle(color: AppColors.lightPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // 2. Summary stats Boxes
            Row(
              children: [
                Expanded(child: _buildStatBox('TOTAL CONTRACTS', '6', Colors.grey)),
                const SizedBox(width: 14),
                Expanded(child: _buildStatBox('AWAITING MY SIGNATURE', '1', Colors.orange)),
                const SizedBox(width: 14),
                Expanded(child: _buildStatBox('FULLY EXECUTED', '3', Colors.green)),
                const SizedBox(width: 14),
                Expanded(child: _buildStatBox('UNDER REVIEW', '1', Colors.blue)),
              ],
            ),
            const SizedBox(height: 20),

            // 3. Alert signature warning banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[800], size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('You have 1 contract awaiting YOUR signature', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary)),
                        const Text('Review and sign before the expiry date to activate your engagement.', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedFilter = 'Pending Signature';
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                    child: const Text('View Now', style: TextStyle(color: Colors.white, fontSize: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Search and Filter row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search contracts, companies...',
                      prefixIcon: const Icon(Icons.search, size: 16),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightBorder)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Pending Signature', 'Signed', 'Under Review', 'Expired'].map((filter) {
                        final isSel = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: ChoiceChip(
                            label: Text(filter, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppColors.lightTextSecondary)),
                            selected: isSel,
                            selectedColor: AppColors.lightPrimary,
                            backgroundColor: Colors.white,
                            onSelected: (selected) {
                              if (selected) setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            // 5. Contract items listing
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final c = filtered[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(6)),
                                  child: Text(c['type']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: (c['statusColor'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    c['status']!,
                                    style: TextStyle(color: c['statusColor']!, fontWeight: FontWeight.bold, fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.download_outlined, size: 16),
                                  onPressed: () => Forms.showSuccessToast(context, 'Downloading document PDF...'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_outlined, size: 16),
                                  onPressed: () => Forms.showSuccessToast(context, 'Contract reference ID copied!'),
                                ),
                                const Icon(Icons.more_vert, size: 16),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(c['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightTextPrimary)),
                        const SizedBox(height: 4),
                        Text(
                          '${c['company']} · ${c['project']} · ${c['files']}',
                          style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 11),
                        ),
                        if (c['budget'] != '') ...[
                          const SizedBox(height: 8),
                          Text('Contract Value: ${c['budget']}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightPrimary)),
                        ],
                        const SizedBox(height: 6),
                        Text('Term: ${c['dates']}', style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Signature flow indicators
                            Row(
                              children: [
                                _buildSignStatusBadge('You', c['youSigned'] as bool),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                                const SizedBox(width: 8),
                                _buildSignStatusBadge(c['company']!, c['clientSigned'] as bool),
                              ],
                            ),
                            if (c['actionType'] == 'sign')
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    c['status'] = 'Signed';
                                    c['statusColor'] = Colors.green;
                                    c['youSigned'] = true;
                                    c['actionType'] = 'view';
                                    c['footer'] = 'Fully executed just now';
                                  });
                                  Forms.showSuccessToast(context, 'Contract signed digitally and escrow lock released!');
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintTeal),
                                child: const Text('Review & Sign', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              )
                            else
                              OutlinedButton(
                                onPressed: () => Forms.showSuccessToast(context, 'Opening contract reader...'),
                                child: const Text('View Agreement', style: TextStyle(color: AppColors.lightPrimary)),
                              )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(c['footer']!, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // 6. How ExigentCX Manages Your Contracts footer
            Text('How ExigentCX Manages Your Contracts', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _buildFooterInfoCard('Auto-Generated', 'Contracts are auto-created when a company confirms your engagement.', Icons.file_present)),
                const SizedBox(width: 14),
                Expanded(child: _buildFooterInfoCard('Legally Binding', 'Every agreement is vetted and compliant with Indian contract law.', Icons.gavel)),
                const SizedBox(width: 14),
                Expanded(child: _buildFooterInfoCard('Escrow-Protected', 'Your earnings are held in escrow and released upon milestone approval.', Icons.lock_outline)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildSignStatusBadge(String party, bool signed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: signed ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(signed ? Icons.check : Icons.access_time, size: 10, color: signed ? Colors.green : Colors.red),
          const SizedBox(width: 4),
          Text(party, style: TextStyle(fontSize: 9, color: signed ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFooterInfoCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.mintTeal, size: 18),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.lightTextPrimary)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 9, color: AppColors.lightTextSecondary), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class ExpertEarningsView extends ConsumerStatefulWidget {
  const ExpertEarningsView({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpertEarningsView> createState() => _ExpertEarningsViewState();
}

class _ExpertEarningsViewState extends ConsumerState<ExpertEarningsView> {
  String _selectedTab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 950;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Block
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Earnings & Payouts',
                        style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Track your income, invoices, and payment history',
                        style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13),
                      ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Forms.showSuccessToast(context, 'Exporting statement PDF...'),
                      icon: const Icon(Icons.file_download_outlined, size: 16),
                      label: const Text('Export', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showWithdrawBottomSheet(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                      icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 16),
                      label: const Text('Withdraw Funds', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                )
              ],
            ),
            const SizedBox(height: 24),

            // 2. Large green main dashboard card
            _buildMainLifetimeEarningsCard(),
            const SizedBox(height: 24),

            // 3. Row of four stats detail boxes
            Row(
              children: [
                Expanded(child: _buildMiniStatCard('THIS MONTH', '₹3,50,000', '+12% vs last month', Icons.trending_up, AppColors.mintTeal)),
                const SizedBox(width: 12),
                Expanded(child: _buildMiniStatCard('IN ESCROW', '₹5,50,000', '3 milestones pending', Icons.lock_outline, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildMiniStatCard('WITHDRAWABLE', '₹3,50,000', 'Available now', Icons.lock_open, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildMiniStatCard('ACTIVE CLIENTS', '2', '2 engagements', Icons.business, Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Tabs Row
            Row(
              children: ['Overview', 'Transactions', 'Invoices', 'Payouts'].map((tab) {
                final isSel = _selectedTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = tab),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.lightPrimary : Colors.white,
                        border: Border.all(color: isSel ? AppColors.lightPrimary : AppColors.lightBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 5. Two-column detail block
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMonthlyEarningsChartCard(),
                        const SizedBox(height: 24),
                        _buildRecentActivityCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAvailableToWithdrawCard(),
                        const SizedBox(height: 24),
                        _buildUpcomingPaymentsCard(),
                        const SizedBox(height: 24),
                        _buildPlatformFeeCard(),
                        const SizedBox(height: 24),
                        _buildQuickActionsCard(),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthlyEarningsChartCard(),
                  const SizedBox(height: 24),
                  _buildAvailableToWithdrawCard(),
                  const SizedBox(height: 24),
                  _buildRecentActivityCard(),
                  const SizedBox(height: 24),
                  _buildUpcomingPaymentsCard(),
                  const SizedBox(height: 24),
                  _buildPlatformFeeCard(),
                  const SizedBox(height: 24),
                  _buildQuickActionsCard(),
                ],
              )
          ],
        ),
      ),
    );
  }

  Widget _buildMainLifetimeEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.lightPrimary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL LIFETIME EARNINGS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('₹12,40,000', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('₹3,50,000 this month', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Avg ₹3.1L/mo', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Vertical divider
          Container(width: 1, height: 80, color: Colors.white24),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLifetimeValueBox('AVAILABLE TO WITHDRAW', '₹3,50,000'),
              const SizedBox(height: 12),
              _buildLifetimeValueBox('IN ESCROW', '₹5,50,000'),
              const SizedBox(height: 12),
              _buildLifetimeValueBox('NEXT PAYMENT', '₹2,50,000', sub: 'Apr 30, 2025'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLifetimeValueBox(String label, String value, {String? sub}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        if (sub != null) Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 8)),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String val, String sub, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 9, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.lightTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyEarningsChartCard() {
    final List<Map<String, dynamic>> barData = [
      {'month': 'Oct', 'val': 0.0, 'label': ''},
      {'month': 'Nov', 'val': 0.45, 'label': '₹1.5L'},
      {'month': 'Dec', 'val': 0.45, 'label': '₹1.5L'},
      {'month': 'Jan', 'val': 0.6, 'label': '₹2L'},
      {'month': 'Feb', 'val': 0.85, 'label': '₹3L'},
      {'month': 'Mar', 'val': 1.0, 'label': '₹3.5L'},
      {'month': 'Apr', 'val': 1.0, 'label': '₹3.5L'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bar_chart, size: 18, color: AppColors.mintTeal),
                    const SizedBox(width: 8),
                    Text('Monthly Earnings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightTextPrimary)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.lightBg, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.lightBorder)),
                  child: Row(
                    children: const [
                      Text('Milestone Payments', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 12),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: barData.map((d) {
                  final double heightFactor = d['val'] as double;
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (heightFactor > 0.0) ...[
                          Text(d['label']!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary)),
                          const SizedBox(height: 4),
                        ],
                        Container(
                          height: (100 * heightFactor).clamp(4.0, 100.0),
                          width: 32,
                          decoration: BoxDecoration(
                            gradient: AppColors.mintGradient,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(d['month']!, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartMetaStat('Year to Date (2025)', '₹10,50,000'),
                _buildChartMetaStat('Avg Monthly', '₹3.1L'),
                _buildChartMetaStat('Best Month', '₹3,50,000'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChartMetaStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
      ],
    );
  }

  Widget _buildRecentActivityCard() {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Milestone Payment — Financial Model Development',
        'ref': 'Milestone 2',
        'date': 'Mar 28, 2025',
        'amount': '+₹2,00,000',
        'color': Colors.green,
        'icon': Icons.arrow_downward,
      },
      {
        'title': 'Milestone Payment — Campaign Strategy',
        'ref': 'Milestone 1',
        'date': 'Apr 1, 2025',
        'amount': '+₹1,50,000',
        'color': Colors.green,
        'icon': Icons.arrow_downward,
      },
      {
        'title': 'Withdrawal to HDFC Bank ****4321',
        'ref': 'Withdrawal Ref: CXO-4829',
        'date': 'Mar 30, 2025',
        'amount': '-₹3,00,000',
        'color': Colors.blue,
        'icon': Icons.arrow_upward,
      },
      {
        'title': 'Milestone Payment — Discovery & Assessment',
        'ref': 'Milestone 1',
        'date': 'Feb 25, 2025',
        'amount': '+₹1,50,000',
        'color': Colors.green,
        'icon': Icons.arrow_downward,
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 18, color: AppColors.lightPrimary),
                    const SizedBox(width: 8),
                    Text('Recent Activity', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.lightTextPrimary)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All ->', style: TextStyle(color: AppColors.mintTeal, fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, idx) {
                final a = activities[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: a['color'].withOpacity(0.08),
                        radius: 16,
                        child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 14),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.lightTextPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('${a['ref']} · ${a['date']}', style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        a['amount']!,
                        style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.bold, color: a['color'] as Color),
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableToWithdrawCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available to Withdraw', style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('₹3,50,000', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
            const Text('From 2 completed milestones', style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () => _showWithdrawBottomSheet(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintTeal),
                child: const Text('Withdraw Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingPaymentsCard() {
    final List<Map<String, String>> upcoming = [
      {'title': 'Investor Deck & Data Room', 'company': 'Acme Corp', 'date': 'Apr 30, 2025', 'val': '₹2,50,000'},
      {'title': 'Investor Outreach', 'company': 'Acme Corp', 'date': 'May 31, 2025', 'val': '₹3,00,000'},
      {'title': 'Due Diligence Report', 'company': 'TechScale', 'date': 'May 15, 2025', 'val': '₹1,25,000'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Payments', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary)),
            const SizedBox(height: 12),
            ...upcoming.map((u) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(u['title']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.lightTextPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${u['company']} · ${u['date']}', style: const TextStyle(fontSize: 10, color: AppColors.lightTextSecondary)),
                        ],
                      ),
                    ),
                    Text(u['val']!, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
                  ],
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformFeeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.purple, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Platform Fee', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.purple[800]!)),
                const SizedBox(height: 2),
                const Text(
                  'ExigentCX charges a 10% platform fee on each milestone payment. This covers PMO support, legal protection, and escrow management.',
                  style: TextStyle(fontSize: 9.5, color: AppColors.lightTextSecondary, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    final List<Map<String, dynamic>> items = [
      {'title': 'View Invoices', 'icon': Icons.receipt_long_outlined},
      {'title': 'Payout Settings', 'icon': Icons.account_balance_outlined},
      {'title': 'Download Statement', 'icon': Icons.description_outlined},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.lightTextPrimary)),
            const SizedBox(height: 12),
            ...items.map((item) {
              return InkWell(
                onTap: () => Forms.showSuccessToast(context, 'Loading ${item['title']}...'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(item['icon'] as IconData, size: 16, color: AppColors.lightTextSecondary),
                          const SizedBox(width: 12),
                          Text(item['title']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                    ],
                  ),
                ),
              );
            }).toList()
          ],
        ),
      ),
    );
  }

  void _showWithdrawBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        bool isDone = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            if (isDone) {
              return Container(
                padding: const EdgeInsets.all(36),
                height: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const ScaleCheckmark(),
                    const SizedBox(height: 24),
                    Text('Withdrawal Initiated!', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Funds will clear into your bank account in 24 hours.', textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Earnings'),
                    )
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Withdraw Available Earnings', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 18),
                    TextFormField(
                      initialValue: '350000',
                      decoration: const InputDecoration(labelText: 'Amount (INR)', hintText: 'e.g. 100000'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Enter amount' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: 'hdfc',
                      decoration: const InputDecoration(labelText: 'Select Bank Account'),
                      items: const [
                        DropdownMenuItem(value: 'hdfc', child: Text('HDFC Bank ending in 4321')),
                        DropdownMenuItem(value: 'icici', child: Text('ICICI Bank ending in 4829')),
                      ],
                      onChanged: (_) {},
                      validator: (v) => v == null ? 'Select bank' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setModalState(() {
                            isDone = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPrimary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Release Funds to Bank', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ExpertSettingsView extends StatelessWidget {
  const ExpertSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Center(child: Text('Settings, notification channels, and banking configuration.')),
    );
  }
}

// =========================================================================
// 6. EXPERT PROFILE BUILDER WIZARD (Step-by-Step)
// =========================================================================

class ExpertProfileBuilderView extends StatefulWidget {
  const ExpertProfileBuilderView({Key? key}) : super(key: key);

  @override
  State<ExpertProfileBuilderView> createState() => _ExpertProfileBuilderViewState();
}

class _ExpertProfileBuilderViewState extends State<ExpertProfileBuilderView> {
  String _activeTab = 'Basic Info';

  // Form Controllers for Basic Info
  final _firstNameController = TextEditingController(text: 'David');
  final _lastNameController = TextEditingController(text: 'Chen');
  final _headlineController = TextEditingController(
      text: 'Interim & Fractional CFO | Ex-Meesho, OYO | Series B/C Fundraising Expert');
  final _summaryController = TextEditingController(
      text: 'Seasoned financial leader with 18+ years of experience as CFO at high-growth startups and listed companies. I have led \$200M+ in fundraising across Series A to IPO stages, built finance teams from scratch, and driven profitability across D2C, SaaS, and HealthTech sectors.');
  final _emailController = TextEditingController(text: 'david.chen@email.com');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _locationController = TextEditingController(text: 'Mumbai, Maharashtra');
  final _linkedinController = TextEditingController(text: 'https://linkedin.com/in/davidchen-cfo');
  final _websiteController = TextEditingController(text: 'https://davidchenfinance.com');
  final _yearsController = TextEditingController(text: '18');

  // Form Controllers for Rate & Availability
  final _hourlyRateController = TextEditingController(text: '10000');
  final _monthlyRetainerController = TextEditingController(text: '250000');
  bool _isAvailable = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _headlineController.dispose();
    _summaryController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _yearsController.dispose();
    _hourlyRateController.dispose();
    _monthlyRetainerController.dispose();
    super.dispose();
  }

  void _saveBasicInfo() {
    Forms.showSuccessToast(context, 'Basic Info saved successfully!');
  }

  void _saveProfile() {
    Forms.showSuccessToast(context, 'Expert Profile updated and saved!');
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Builder',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF134E40),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'A complete profile gets ',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            '3x more matches',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0EB59A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Forms.showSuccessToast(context, 'Opening profile preview mode...');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.lightBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          'Preview Profile',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF134E40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF134E40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          'Save Profile',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Responsive layout structure
              isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: _buildLeftPanel(),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _buildRightFormContent(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildLeftPanel(),
                        const SizedBox(height: 24),
                        _buildRightFormContent(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Strength Card
        Card(
          color: const Color(0xFF134E40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium_outlined, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Profile Strength',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '78%',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.78,
                    minHeight: 8,
                    backgroundColor: Color(0xFF0F3E33),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0EB59A)),
                  ),
                ),
                const SizedBox(height: 20),
                _buildStrengthChecklistItem('Basic info complete', true),
                _buildStrengthChecklistItem('Work experience added', true),
                _buildStrengthChecklistItem('Skills added', true),
                _buildStrengthChecklistItem('Rate card set', false),
                _buildStrengthChecklistItem('Case studies added', true),
                _buildStrengthChecklistItem('3 client testimonials', false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Side Navigation tabs
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightBorder),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildSideTabItem('Basic Info', Icons.person_outline),
              _buildSideTabItem('Experience', Icons.work_outline),
              _buildSideTabItem('Skills', Icons.psychology_outlined),
              _buildSideTabItem('Education', Icons.school_outlined),
              _buildSideTabItem('Case Studies', Icons.auto_stories_outlined),
              _buildSideTabItem('Rate & Availability', Icons.monetization_on_outlined),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthChecklistItem(String title, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: checked ? const Color(0xFF0EB59A) : Colors.white24,
            size: 16,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: checked ? Colors.white : Colors.white60,
              fontWeight: checked ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideTabItem(String title, IconData icon) {
    final bool isSelected = _activeTab == title;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = title;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF134E40) : AppColors.lightTextSecondary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF134E40) : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightFormContent() {
    switch (_activeTab) {
      case 'Basic Info':
        return _buildBasicInfoTab();
      case 'Experience':
        return _buildExperienceTab();
      case 'Skills':
        return _buildSkillsTab();
      case 'Education':
        return _buildEducationTab();
      case 'Case Studies':
        return _buildCaseStudiesTab();
      case 'Rate & Availability':
        return _buildRateAvailabilityTab();
      default:
        return _buildBasicInfoTab();
    }
  }

  Widget _buildBasicInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Photo & Headline Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: Color(0xFF0EB59A)),
                    const SizedBox(width: 10),
                    Text(
                      'Profile Photo & Headline',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF134E40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Profile photo uploader row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF134E40),
                      child: Text(
                        'DC',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profile Photo',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF134E40),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Square image, min 400x400px. Your face should be clearly visible.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () {
                              Forms.showSuccessToast(context, 'Mock File Uploader Opened');
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.lightBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.upload_file, size: 14),
                                const SizedBox(width: 6),
                                Text('Upload Photo', style: GoogleFonts.inter(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // First name and Last name row
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField('FIRST NAME', _firstNameController),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField('LAST NAME', _lastNameController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFormField('PROFESSIONAL HEADLINE', _headlineController),
                const SizedBox(height: 16),
                _buildFormField('PROFESSIONAL SUMMARY', _summaryController, maxLines: 4),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Contact & Location Card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.lightBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.map_outlined, color: Color(0xFF0EB59A)),
                    const SizedBox(width: 10),
                    Text(
                      'Contact & Location',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF134E40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField('EMAIL', _emailController, icon: Icons.email_outlined),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField('PHONE', _phoneController, icon: Icons.phone_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField('LOCATION', _locationController, icon: Icons.location_on_outlined),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField('LINKEDIN URL', _linkedinController, icon: Icons.link_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildFormField('WEBSITE', _websiteController, icon: Icons.language_outlined),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFormField('YEARS OF EXPERIENCE', _yearsController, icon: Icons.timeline_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Save Basic Info Button
        ElevatedButton(
          onPressed: _saveBasicInfo,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0EB59A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Save Basic Info',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {int maxLines = 1, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF134E40),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextPrimary),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.lightTextSecondary, size: 16) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFFAFBF9),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.lightBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF0EB59A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceTab() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.work_outline, color: Color(0xFF0EB59A)),
                    const SizedBox(width: 10),
                    Text(
                      'Work Experience',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF134E40),
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {
                    Forms.showSuccessToast(context, 'Experience entry form opened');
                  },
                  child: const Text('+ Add Experience'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildExperienceItem(
              role: 'Fractional CFO',
              company: 'Meesho',
              duration: 'Jan 2024 - Present',
              description: 'Acting as interim advisor for Series E financial forecasting, treasury optimizations, and unit economics validation.',
            ),
            const Divider(height: 24),
            _buildExperienceItem(
              role: 'Vice President - Finance & CFO',
              company: 'OYO Room Rentals',
              duration: 'Aug 2019 - Dec 2023',
              description: 'Managed a team of 45 finance professionals. Led Series C & D corporate finance, cross-border restructuring, and EBITDA recovery pathing.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceItem({
    required String role,
    required String company,
    required String duration,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.business_center_outlined, color: Color(0xFF134E40)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
              Text('$company · $duration', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF0EB59A), fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsTab() {
    final List<String> skills = [
      'Financial Modeling',
      'M&A Due Diligence',
      'Treasury & Escrow Management',
      'Board Deck Strategy',
      'Series B Fundraising',
      'Valuation & Cap Table Audit',
      'D2C Brand Finance',
      'SaaS EBITDA Forecasting',
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology_outlined, color: Color(0xFF0EB59A)),
                const SizedBox(width: 10),
                Text(
                  'Vetted Core Skills',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF134E40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'These skills are validated via PMO vetting board and professional client feedback.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Chip(
                  label: Text(skill, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF134E40), fontWeight: FontWeight.w500)),
                  backgroundColor: const Color(0xFFF0FDF4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Color(0xFFD3EBE5)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Forms.showSuccessToast(context, 'Skills management console opened');
              },
              child: const Text('Add Vetted Skills'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationTab() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined, color: Color(0xFF0EB59A)),
                const SizedBox(width: 10),
                Text(
                  'Education & Credentials',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF134E40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildEducationItem(
              degree: 'Chartered Accountant (CA)',
              institution: 'Institute of Chartered Accountants of India (ICAI)',
              year: 'Class of 2008 · Rank Holder',
            ),
            const Divider(height: 24),
            _buildEducationItem(
              degree: 'Bachelor of Commerce (B.Com Hons)',
              institution: 'Delhi University, Shri Ram College of Commerce',
              year: 'Class of 2005',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationItem({
    required String degree,
    required String institution,
    required String year,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.school_outlined, color: Color(0xFF134E40)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(degree, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
              Text(institution, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF0EB59A), fontWeight: FontWeight.w500)),
              Text(year, style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightTextSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCaseStudiesTab() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_stories_outlined, color: Color(0xFF0EB59A)),
                    const SizedBox(width: 10),
                    Text(
                      'Case Studies',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF134E40),
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () {
                    Forms.showSuccessToast(context, 'Case study creation view opened');
                  },
                  child: const Text('+ Add Case Study'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildCaseStudyItem(
              title: 'Series B Fundraising & Deck Advisory',
              client: 'Acme Corp',
              outcome: 'Successfully raised \$35M from tier-1 VCs. Optimized pitch narrative, equity cap table simulation, and led PMO-mediated diligence response.',
            ),
            const Divider(height: 24),
            _buildCaseStudyItem(
              title: 'SaaS Unit Economics Overhaul & Path to EBITDA Breakeven',
              client: 'SaaSified Inc',
              outcome: 'Reduced customer acquisition cost (CAC) payback from 18 to 9 months, reallocated marketing budgets, and led financial modeling for transition to enterprise contracts.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseStudyItem({
    required String title,
    required String client,
    required String outcome,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
        const SizedBox(height: 4),
        Text('Client: $client', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF0EB59A), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(outcome, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary, height: 1.4)),
      ],
    );
  }

  Widget _buildRateAvailabilityTab() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monetization_on_outlined, color: Color(0xFF0EB59A)),
                const SizedBox(width: 10),
                Text(
                  'Rate Card & Availability Settings',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF134E40),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildFormField('HOURLY RATE (INR)', _hourlyRateController, icon: Icons.currency_rupee),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFormField('MINIMUM MONTHLY RETAINER (INR)', _monthlyRetainerController, icon: Icons.currency_rupee),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability Status',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF134E40)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toggle to indicate if you are open to take on new fractional/interim contracts.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightTextSecondary),
                    ),
                  ],
                ),
                Switch(
                  value: _isAvailable,
                  activeColor: const Color(0xFF0EB59A),
                  onChanged: (v) {
                    setState(() {
                      _isAvailable = v;
                    });
                    Forms.showSuccessToast(context, 'Availability status updated.');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Forms.showSuccessToast(context, 'Rate Card saved successfully!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF134E40),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Save Rate & Availability'),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 7. CLIENT PORTAL - COMPANY INTERFACE
// =========================================================================

class CompanyRequirementsView extends ConsumerWidget {
  const CompanyRequirementsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reqs = ref.watch(requirementsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Enterprise Requirements', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () => context.go('/requirements/create'),
                  child: const Text('Post Requirement'),
                )
              ],
            ),
            const SizedBox(height: 18),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reqs.length,
              itemBuilder: (context, idx) {
                final r = reqs[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Engagement: ${r.roleType} · Budget: ${r.budget} · Status: ${r.status}'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CompanySettingsView extends StatelessWidget {
  const CompanySettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.lightBg,
      body: Center(child: Text('Company details, team access settings, and payment preferences.')),
    );
  }
}

// =========================================================================
// 8. RECOMMENDED EXPERTS CAROUSEL
// =========================================================================

class RecommendedExpertsCarousel extends StatefulWidget {
  const RecommendedExpertsCarousel({Key? key}) : super(key: key);

  @override
  State<RecommendedExpertsCarousel> createState() => _RecommendedExpertsCarouselState();
}

class _RecommendedExpertsCarouselState extends State<RecommendedExpertsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.95);
  int _currentIndex = 0;
  Timer? _timer;
  bool _isPaused = false;

  final List<Map<String, dynamic>> _experts = [
    {
      'id': 'a1',
      'name': 'Sarah Jenkins',
      'role': 'Former CTO at Stripe',
      'match': 98,
      'rating': 5.0,
      'retainer': '₹2.5L - ₹3.5L/mo',
      'availability': '20 hrs/week',
      'location': 'San Francisco, CA',
      'avatar': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=400',
    },
    {
      'id': 'a2',
      'name': 'Marcus Vance',
      'role': 'Interim CFO & Board Member',
      'match': 95,
      'rating': 4.9,
      'retainer': '₹3.0L/mo',
      'availability': '15 hrs/week',
      'location': 'New York, NY',
      'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=400',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _experts.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isPaused = true),
      onExit: (_) => setState(() => _isPaused = false),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _experts.length,
              onPageChanged: (idx) => setState(() => _currentIndex = idx),
              itemBuilder: (context, idx) {
                final e = _experts[idx];
                return _buildExpertCard(e);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertCard(Map<String, dynamic> e) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(e['avatar']),
                  radius: 36,
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.green, border: Border.all(color: Colors.white, width: 1.5), shape: BoxShape.circle),
                  ),
                )
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(e['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.lightMintHighlight, borderRadius: BorderRadius.circular(6)),
                        child: Text('${e['match']}% MATCH', style: const TextStyle(color: AppColors.mintTeal, fontWeight: FontWeight.bold, fontSize: 9)),
                      )
                    ],
                  ),
                  Text(e['role'], style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('${e['availability']} · ${e['retainer']} · ${e['location']}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/experts/${e['id']}'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                  child: const Text('View Profile', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Forms.showSuccessToast(context, 'Consultant connection invitation dispatched.');
                      },
                      child: const Text('Invite'),
                    ),
                    const SizedBox(width: 6),
                    const BouncingFavoriteHeart(),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 9. STEP-BY-STEP CREATE REQUIREMENT WIZARD
// =========================================================================

class PostRequirementView extends StatefulWidget {
  const PostRequirementView({Key? key}) : super(key: key);

  @override
  State<PostRequirementView> createState() => _PostRequirementViewState();
}

class _PostRequirementViewState extends State<PostRequirementView> {
  int _step = 1;
  final _formKey = GlobalKey<FormState>();

  // Form State
  String? _engagementType;
  final List<String> _selectedChallenges = [];
  final _roleTitleController = TextEditingController();
  final List<String> _selectedSkills = [];
  String _experienceRetainer = '14-17 yrs';
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();

  final List<String> _challenges = [
    'Fundraising',
    'Go-to-Market',
    'Scaling Operations',
    'Technology',
    'People & Culture',
    'Governance',
    'Revenue Growth',
    'Product Strategy'
  ];

  @override
  void dispose() {
    _roleTitleController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 1 && _engagementType == null) {
      Forms.showErrorToast(context, 'Please select an engagement type.');
      return;
    }
    if (_step == 2 && _selectedChallenges.isEmpty) {
      Forms.showErrorToast(context, 'Please select at least one challenge.');
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _step++);
    }
  }

  void _back() => setState(() => _step--);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_step == 1) _buildStepEngagement(),
                      if (_step == 2) _buildStepChallenge(),
                      if (_step == 3) _buildStepSkills(),
                      if (_step == 4) _buildStepLogistics(),
                      if (_step == 5) _buildStepReview(),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_step > 1)
                            OutlinedButton(onPressed: _back, child: const Text('Back'))
                          else
                            const SizedBox.shrink(),
                          if (_step < 5)
                            ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                              child: const Text('Continue', style: TextStyle(color: Colors.white)),
                            )
                          else
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    Forms.showSuccessToast(context, 'Draft requirement saved.');
                                    context.go('/company-dashboard');
                                  },
                                  child: const Text('Save Draft'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    Forms.showSuccessToast(context, 'Scope posted! AI matching triggers in 24 hours.');
                                    context.go('/company-dashboard');
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                                  child: const Text('Post Requirement', style: TextStyle(color: Colors.white)),
                                )
                              ],
                            )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(5, (idx) {
        final stepNum = idx + 1;
        final isCompleted = _step >= stepNum;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isCompleted ? AppColors.mintTeal : Colors.grey[300],
                radius: 14,
                child: Text('$stepNum', style: TextStyle(color: isCompleted ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              if (idx < 4)
                Expanded(
                  child: Container(
                    height: 3,
                    color: isCompleted ? AppColors.mintTeal : Colors.grey[300],
                  ),
                )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepEngagement() {
    final List<Map<String, String>> models = [
      {'title': 'Fractional', 'desc': 'Part-time leadership (e.g. CFO 15hrs/wk)'},
      {'title': 'Interim', 'desc': 'Full-time replacement for fixed period'},
      {'title': 'Advisory', 'desc': 'Strategic board-level advisory'},
      {'title': 'Project', 'desc': 'Defined scope with clear deliverables'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Select Engagement Model', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.2,
          physics: const NeverScrollableScrollPhysics(),
          children: models.map((m) {
            final isSelected = _engagementType == m['title'];
            return InkWell(
              onTap: () => setState(() => _engagementType = m['title']),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.mintTeal : AppColors.lightBorder,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                  color: isSelected ? AppColors.lightMintHighlight : Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.mintTeal, size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(m['desc']!, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
                  ],
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildStepChallenge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Core Business Challenges', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _challenges.map((c) {
            final isSelected = _selectedChallenges.contains(c);
            return FilterChip(
              selected: isSelected,
              label: Text(c),
              selectedColor: AppColors.mintTeal,
              onSelected: (v) {
                setState(() {
                  if (isSelected) {
                    _selectedChallenges.remove(c);
                  } else {
                    _selectedChallenges.add(c);
                  }
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildStepSkills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Skills & Experience Bracket', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          controller: _roleTitleController,
          decoration: const InputDecoration(labelText: 'Desired Role Title (e.g. Interim CFO)'),
          validator: (v) => v!.isEmpty ? 'Required field' : null,
        ),
        const SizedBox(height: 18),
        const Text('Experience Retainer Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        Row(
          children: ['10-13 yrs', '14-17 yrs', '18-20 yrs', '20+ yrs'].map((bracket) {
            final isSelected = _experienceRetainer == bracket;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(bracket),
                selected: isSelected,
                selectedColor: AppColors.mintTeal,
                onSelected: (v) {
                  setState(() => _experienceRetainer = bracket);
                },
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _buildStepLogistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 4: Budget & Logistics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minBudgetController,
                decoration: const InputDecoration(labelText: 'Min Budget (₹)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextFormField(
                controller: _maxBudgetController,
                decoration: const InputDecoration(labelText: 'Max Budget (₹)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 5: Review & Post', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        Card(
          color: AppColors.lightMintHighlight,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Role: ${_roleTitleController.text}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('Engagement Model: $_engagementType'),
                Text('Experience Required: $_experienceRetainer'),
                Text('Budget Range: ₹${_minBudgetController.text} - ₹${_maxBudgetController.text}'),
                Text('Primary Challenges: ${_selectedChallenges.join(', ')}'),
              ],
            ),
          ),
        )
      ],
    );
  }
}

// =========================================================================
// 10. ALIGNMENT & MILESTONES WORKSPACE (`/engagements/:engagementId`)
// =========================================================================

class EngagementWorkspaceView extends ConsumerStatefulWidget {
  final String engagementId;
  const EngagementWorkspaceView({Key? key, required this.engagementId}) : super(key: key);

  @override
  ConsumerState<EngagementWorkspaceView> createState() => _EngagementWorkspaceViewState();
}

class _EngagementWorkspaceViewState extends ConsumerState<EngagementWorkspaceView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _workspaceChat = [
    "Board approved the cloud architecture budget.",
    "Perfect! Staging cloud resources with Terraform script sets.",
  ];
  final TextEditingController _chatMsgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatMsgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engagements = ref.watch(engagementsProvider);
    final milestones = ref.watch(milestonesProvider).where((m) => m.engagementId == widget.engagementId).toList();
    final e = engagements.firstWhere((item) => item.id == widget.engagementId, orElse: () => engagements.first);
    final userRole = ref.watch(userRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        title: Text(e.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.lightPrimary,
          unselectedLabelColor: AppColors.lightTextSecondary,
          indicatorColor: AppColors.mintTeal,
          tabs: const [
            Tab(text: 'Milestones Delivery'),
            Tab(text: 'Collaboration Chat'),
            Tab(text: 'NDA & Contracts'),
            Tab(text: 'Activity Feed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMilestonesTab(milestones, userRole, e),
          _buildMessagesTab(),
          _buildContractsTab(),
          _buildActivityFeed(),
        ],
      ),
    );
  }

  Widget _buildMilestonesTab(List<Milestone> milestones, UserRole userRole, Engagement e) {
    return ListView.builder(
      padding: const EdgeInsets.all(28.0),
      itemCount: milestones.length,
      itemBuilder: (context, idx) {
        final m = milestones[idx];
        Color statusColor = Colors.grey;
        IconData statusIcon = Icons.lock_outline;

        if (m.status == 'completed') {
          statusColor = AppColors.mintTeal;
          statusIcon = Icons.check_circle;
        } else if (m.status == 'pending_approval') {
          statusColor = AppColors.warning;
          statusIcon = Icons.hourglass_empty;
        } else if (m.status == 'in_progress') {
          statusColor = AppColors.info;
          statusIcon = Icons.play_circle_outline;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        const SizedBox(width: 8),
                        Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Text(m.cost, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.mintTeal)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(m.description, style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 13)),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Deadline Due: ${m.dueDate}'),
                    if (m.status == 'in_progress' && userRole == UserRole.expert)
                      ElevatedButton(
                        onPressed: () {
                          ref.read(milestonesProvider.notifier).submitMilestone(m.id);
                          ref.read(notificationsProvider.notifier).addNotification(
                            'Milestone Submitted for Approval',
                            ' Sarah Jenkins submitted cloud overhaul deliverables.',
                            'payment',
                          );
                          Forms.showSuccessToast(context, 'Milestone submitted to company review.');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintTeal),
                        child: const Text('Upload Deliverable', style: TextStyle(color: Colors.black)),
                      ),
                    if (m.status == 'pending_approval' && userRole == UserRole.company)
                      ElevatedButton(
                        onPressed: () {
                          ref.read(milestonesProvider.notifier).approveMilestone(m.id);
                          ref.read(escrowTransactionsProvider.notifier).releaseMilestoneTx(m.engagementId, m.title, m.cost);
                          ref.read(notificationsProvider.notifier).addNotification(
                            'Milestone Approved & Released',
                            'Stratos Health approved milestone 2 audit. Funds released.',
                            'payment',
                          );
                          Forms.showSuccessToast(context, 'Milestone Approved & Escrow released.');
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintTeal),
                        child: const Text('Approve & Release Escrow', style: TextStyle(color: Colors.black)),
                      )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _workspaceChat.length,
            itemBuilder: (context, idx) {
              final isMe = idx % 2 == 0;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.lightMintHighlight : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_workspaceChat[idx]),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatMsgController,
                  decoration: const InputDecoration(hintText: 'Type workspace memo...'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.mintTeal),
                onPressed: () {
                  if (_chatMsgController.text.trim().isNotEmpty) {
                    setState(() {
                      _workspaceChat.add(_chatMsgController.text.trim());
                      _chatMsgController.clear();
                    });
                  }
                },
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildContractsTab() {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active NDA Agreements', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_edu, color: AppColors.lightPrimary),
              title: const Text('NDA & Service Compliance Plan'),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () {
                  Forms.showSuccessToast(context, 'Downloading signed NDA PDF document copies...');
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    final activities = [
      {'user': 'Sarah Jenkins', 'action': 'submitted Milestone 2 deliverables', 'time': '2h ago', 'type': 'submission'},
      {'user': 'Arjun Mehta', 'action': 'funded Escrow for Phase 2', 'time': '4h ago', 'type': 'funding'},
      {'user': 'PMO System', 'action': 'approved NDA compliance check', 'time': '6h ago', 'type': 'approval'},
      {'user': 'Sarah Jenkins', 'action': 'uploaded architecture blueprint v3', 'time': '1d ago', 'type': 'upload'},
      {'user': 'Arjun Mehta', 'action': 'requested milestone scope revision', 'time': '1d ago', 'type': 'request'},
      {'user': 'PMO System', 'action': 'released escrow payment for Milestone 1', 'time': '2d ago', 'type': 'payment'},
      {'user': 'Sarah Jenkins', 'action': 'joined workspace', 'time': '3d ago', 'type': 'join'},
      {'user': 'Arjun Mehta', 'action': 'added Q3 OKR document', 'time': '3d ago', 'type': 'upload'},
    ];

    IconData _iconForType(String type) {
      switch (type) {
        case 'submission': return Icons.upload_file;
        case 'funding': return Icons.account_balance;
        case 'approval': return Icons.verified;
        case 'upload': return Icons.cloud_upload;
        case 'request': return Icons.rate_review;
        case 'payment': return Icons.payments;
        case 'join': return Icons.person_add;
        default: return Icons.circle;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(28.0),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final a = activities[index];
        final icon = _iconForType(a['type'] as String);
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.mintTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.mintTeal, size: 20),
            ),
            title: Text('${a['user']} ${a['action']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            trailing: Text(a['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
          ),
        );
      },
    );
  }
}

// =========================================================================
// 11. SHARDS CONTROLLER FOR OTHER STUB VIEWS
// =========================================================================

class CompanyDashboardView extends ConsumerStatefulWidget {
  const CompanyDashboardView({Key? key}) : super(key: key);

  @override
  ConsumerState<CompanyDashboardView> createState() => _CompanyDashboardViewState();
}

class _CompanyDashboardViewState extends ConsumerState<CompanyDashboardView> {
  @override
  Widget build(BuildContext context) {
    final engagements = ref.watch(engagementsProvider);
    final milestones = ref.watch(milestonesProvider);
    final pendingApprovals = milestones.where((m) => m.status == 'pending_approval').toList();

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            _buildWelcomeBanner(),
            const SizedBox(height: 28),

            // Engagement metrics dials
            _buildEngagementMetricsGrid(),
            const SizedBox(height: 28),

            // KPI grid
            _buildKPIGrid(engagements.length, pendingApprovals.length),
            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recommended Top Experts', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const RecommendedExpertsCarousel(),
                      const SizedBox(height: 32),

                      Text('Active Workspace Projects', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildActiveProjectsGrid(engagements),
                    ],
                  ),
                ),
                const SizedBox(width: 28),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Urgent Pending Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildPendingActions(pendingApprovals),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.lightMintHighlight, Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Stratos Health.',
                  style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                ),
                const SizedBox(height: 4),
                const Text('You have 3 pending actions and 3 expert matches today.', style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Download Report'),
                onPressed: () {
                  Forms.showSuccessToast(context, 'Downloading current executive performance report PDF...');
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Post a Role', style: TextStyle(color: Colors.white)),
                onPressed: () => context.go('/requirements/create'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildKPIGrid(int active, int pending) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.6,
      children: [
        _buildKPICard('Active Engagements', active.toDouble(), '🟢 +1 this month', AppColors.mintTeal),
        _buildKPICard('Pending Approvals', pending.toDouble(), '⚠️ Action needed', AppColors.warning),
        _buildKPICard('Total Spend committed', 27.0, 'Within budget limits', AppColors.info, isCurrency: true),
        _buildKPICard('Active Escrow Balance', 4.5, 'Escrow secured', AppColors.lightPrimary, isCurrency: true),
      ],
    );
  }

  Widget _buildKPICard(String title, double val, String trend, Color color, {bool isCurrency = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 11)),
            AnimatedCounter(endValue: val, prefix: isCurrency ? '₹' : '', suffix: isCurrency ? 'L' : ''),
            Text(trend, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProjectsGrid(List<Engagement> engagements) {
    return Column(
      children: engagements.map((e) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                      child: const Text('Low Risk', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                Text('Consultant: ${e.expertName} · Due: ${e.endDate}', style: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: MovingGradientProgressIndicator(value: e.progress)),
                    const SizedBox(width: 12),
                    Text('${(e.progress * 100).toInt()}%'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Escrow: ${e.totalBudget}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () => context.go('/engagements/${e.id}'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                      child: const Text('Open Workspace', style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEngagementMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildMetricDial('Active Workspaces', 8, const Color(0xFF0EB59A)),
        _buildMetricDial('Pending Approvals', 3, const Color(0xFFF59E0B)),
        _buildMetricDial('Requirements Posted', 5, const Color(0xFF134E40)),
        _buildMetricDial('Matches Found', 12, const Color(0xFF3B82F6)),
      ],
    );
  }

  Widget _buildMetricDial(String label, int count, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: count / 20.0,
                      strokeWidth: 5,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Text(
                    '$count',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightTextSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingActions(List<Milestone> pendingApprovals) {
    return Column(
      children: [
        ...pendingApprovals.map((m) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text('Review deliverables. Cost: ${m.cost}'),
              trailing: ElevatedButton(
                onPressed: () {
                  context.go('/engagements/${m.engagementId}');
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                child: const Text('Approve', style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        }).toList(),
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: const Text('Sign Contract: tech Advisory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: const Text('Awaiting signatures for Phase 2 implementation.'),
            trailing: OutlinedButton(
              onPressed: () {
                Forms.showSuccessToast(context, 'Contract signature prompt opened.');
              },
              child: const Text('Sign'),
            ),
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// 12. ANIMATION HELPERS
// =========================================================================

class AnimatedCounter extends StatefulWidget {
  final double endValue;
  final String prefix;
  final String suffix;
  final Duration duration;
  const AnimatedCounter({
    Key? key,
    required this.endValue,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: widget.endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isInteger = widget.endValue % 1 == 0;
        final displayVal = isInteger ? _animation.value.toInt().toString() : _animation.value.toStringAsFixed(1);
        return Text(
          '${widget.prefix}$displayVal${widget.suffix}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        );
      },
    );
  }
}

class MovingGradientProgressIndicator extends StatefulWidget {
  final double value;
  const MovingGradientProgressIndicator({Key? key, required this.value}) : super(key: key);

  @override
  State<MovingGradientProgressIndicator> createState() => _MovingGradientProgressIndicatorState();
}

class _MovingGradientProgressIndicatorState extends State<MovingGradientProgressIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(
            height: 8,
            color: Colors.grey[200],
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FractionallySizedBox(
                widthFactor: widget.value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [
                        AppColors.lightPrimary,
                        AppColors.mintTeal,
                        AppColors.lightPrimary,
                      ],
                      stops: [
                        max(0.0, _controller.value - 0.3),
                        _controller.value,
                        min(1.0, _controller.value + 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      tileMode: TileMode.clamp,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BouncingFavoriteHeart extends StatefulWidget {
  const BouncingFavoriteHeart({Key? key}) : super(key: key);

  @override
  State<BouncingFavoriteHeart> createState() => _BouncingFavoriteHeartState();
}

class _BouncingFavoriteHeartState extends State<BouncingFavoriteHeart> with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4), weight: 50.0),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50.0),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              _controller.forward(from: 0.0);
            },
          ),
        );
      },
    );
  }
}

class HeroPulsingStars extends StatefulWidget {
  const HeroPulsingStars({Key? key}) : super(key: key);

  @override
  State<HeroPulsingStars> createState() => _HeroPulsingStarsState();
}

class _HeroPulsingStarsState extends State<HeroPulsingStars> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _startSequence();
  }

  void _startSequence() async {
    while (mounted) {
      for (var i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (!mounted) break;
        _controllers[i].forward().then((_) {
          if (mounted) _controllers[i].reverse();
        });
      }
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return ScaleTransition(
          scale: Tween(begin: 1.0, end: 1.4).animate(
            CurvedAnimation(parent: _controllers[index], curve: Curves.elasticOut),
          ),
          child: const Icon(Icons.star, color: Colors.amber, size: 16),
        );
      }),
    );
  }
}

class ScaleCheckmark extends StatefulWidget {
  const ScaleCheckmark({Key? key}) : super(key: key);

  @override
  State<ScaleCheckmark> createState() => _ScaleCheckmarkState();
}

class _ScaleCheckmarkState extends State<ScaleCheckmark> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(color: AppColors.mintTeal, shape: BoxShape.circle),
        child: const Icon(Icons.check, color: Colors.black, size: 48),
      ),
    );
  }
}

// =========================================================================
// MISSING ROUTED VIEWS FOR EXIGENTCX ECOSYSTEM
// =========================================================================

class AboutView extends StatelessWidget {
  const AboutView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        appBar: AppBar(
          title: Text(
            'About ExigentCX',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF134E40),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF134E40), Color(0xFF0D3E33)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      children: [
                        Text(
                          'On-Demand Executive Vetting & Escrow-Backed Engagements',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0EB59A),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ExigentCX connects elite operational leaders with growth companies under standard PMO governance and secure milestone release guarantees.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Platform Ecosystem',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF134E40),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildValueCard(
                          icon: Icons.verified_user_outlined,
                          title: 'Vetted Quality',
                          desc: 'Only the top 3% of fractional, interim, and advisory executives pass our rigorous domain screening and identity verification framework.',
                        ),
                        const SizedBox(height: 12),
                        _buildValueCard(
                          icon: Icons.shield_outlined,
                          title: 'PMO Governance',
                          desc: 'Dedicated program management office oversight standardizes scopes of work, sets active milestones, and handles dispute resolution.',
                        ),
                        const SizedBox(height: 12),
                        _buildValueCard(
                          icon: Icons.payment_outlined,
                          title: 'Escrow Security',
                          desc: 'Funds are securely held in milestone-linked escrow accounts. Payments are only released upon verifiably completed deliverables.',
                        ),
                        const SizedBox(height: 40),
                        Text(
                          'Ecosystem Metrics',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF134E40),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildStatItem('500+', 'Active Members')),
                            Expanded(child: _buildStatItem('15+ yrs', 'Avg Experience')),
                            Expanded(child: _buildStatItem('98%', 'SLA Compliance')),
                          ],
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueCard({required IconData icon, required String title, required String desc}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0EB59A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF0EB59A), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF134E40),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.lightTextSecondary,
                      height: 1.4,
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

  Widget _buildStatItem(String val, String label) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Text(
              val,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0EB59A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpertDiscoveryCatalogView extends ConsumerStatefulWidget {
  const ExpertDiscoveryCatalogView({Key? key}) : super(key: key);

  @override
  ConsumerState<ExpertDiscoveryCatalogView> createState() => _ExpertDiscoveryCatalogViewState();
}

class _ExpertDiscoveryCatalogViewState extends ConsumerState<ExpertDiscoveryCatalogView> {
  final Set<String> _selectedCompareIds = {};
  String _selectedIndustry = 'All';
  bool _isGridView = true;
  bool _showFilters = false;

  // Filter state
  String _roleTypeFilter = 'All';
  String _availabilityFilter = 'All';
  String _locationFilter = 'All';
  RangeValues _experienceRange = const RangeValues(0, 30);
  RangeValues _budgetRange = const RangeValues(0, 10);

  @override
  Widget build(BuildContext context) {
    final advisors = ref.watch(filteredAdvisorsProvider);
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    final filteredAdvisors = advisors.where((advisor) {
      if (_selectedIndustry != 'All' && !advisor.industry.toLowerCase().contains(_selectedIndustry.toLowerCase())) return false;
      if (_roleTypeFilter != 'All' && !advisor.role.toLowerCase().contains(_roleTypeFilter.toLowerCase())) return false;
      if (_availabilityFilter != 'All' && !advisor.location.toLowerCase().contains(_availabilityFilter.toLowerCase())) return false;
      if (_locationFilter != 'All') {
        if (_locationFilter == 'Remote' && !advisor.location.toLowerCase().contains('remote')) return false;
        if (_locationFilter == 'Hybrid' && !advisor.location.toLowerCase().contains('hybrid')) return false;
        if (_locationFilter == 'In-office' && advisor.location.toLowerCase().contains('remote')) return false;
      }
      if (advisor.yearsOfExperience < _experienceRange.start.toInt() || advisor.yearsOfExperience > _experienceRange.end.toInt()) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: Row(
        children: [
          // Filter drawer panel (visible when wide)
          if (isWide)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _showFilters ? 280 : 0,
              child: _showFilters ? _buildFilterPanel() : null,
            ),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discover Vetted Executives',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF134E40),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Direct access to top 3% fractional and interim leaders.',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          // Grid/List toggle + filter toggle
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined, color: const Color(0xFF134E40)),
                                onPressed: () {
                                  if (isWide) {
                                    setState(() { _showFilters = !_showFilters; });
                                  } else {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.white,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                      builder: (_) => SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.7,
                                        child: _buildFilterPanel(),
                                      ),
                                    );
                                  }
                                },
                                tooltip: 'Toggle Filters',
                              ),
                              const SizedBox(width: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.lightBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildViewToggleButton(Icons.grid_view, true),
                                    _buildViewToggleButton(Icons.view_list, false),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            ref.read(advisorSearchProvider.notifier).setSearch(val);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search by skill, name, previous company...',
                            prefixIcon: Icon(Icons.search, color: AppColors.lightTextSecondary),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedIndustry,
                          items: const ['All', 'FinTech', 'SaaS', 'HealthTech', 'Logistics']
                              .map((ind) => DropdownMenuItem(
                                    value: ind,
                                    child: Text(ind, style: TextStyle(fontSize: 13, color: AppColors.lightPrimary)),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedIndustry = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredAdvisors.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off_outlined, size: 64, color: AppColors.lightTextSecondary),
                              const SizedBox(height: 16),
                              Text('No matching executives found', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Try broadening your filters or search terms.', style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary)),
                            ],
                          ),
                        )
                      : _isGridView
                          ? GridView.builder(
                              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 420,
                                mainAxisExtent: 280,
                                crossAxisSpacing: 20,
                                mainAxisSpacing: 20,
                              ),
                          itemCount: filteredAdvisors.length,
                          itemBuilder: (context, index) {
                            final advisor = filteredAdvisors[index];
                            final isSelectedForCompare = _selectedCompareIds.contains(advisor.id);

                            return Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: isSelectedForCompare ? const Color(0xFF0EB59A) : AppColors.lightBorder,
                                  width: isSelectedForCompare ? 2 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundImage: NetworkImage(advisor.avatarUrl),
                                          backgroundColor: const Color(0xFF134E40),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    advisor.name,
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                      color: const Color(0xFF134E40),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  if (advisor.isVetted)
                                                    const Icon(Icons.verified, color: Color(0xFF0EB59A), size: 16),
                                                ],
                                              ),
                                              Text(
                                                advisor.role,
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color: AppColors.lightTextSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const BouncingFavoriteHeart(),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      advisor.biography,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.lightTextSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                    const Spacer(),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: advisor.skills.take(3).map((skill) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFD1FAE5)),
                                          ),
                                          child: Text(
                                            skill,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: const Color(0xFF134E40),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton.icon(
                                          icon: Icon(
                                            isSelectedForCompare ? Icons.check_circle : Icons.add_circle_outline,
                                            size: 16,
                                            color: isSelectedForCompare ? const Color(0xFF0EB59A) : AppColors.lightPrimary,
                                          ),
                                          label: Text(
                                            isSelectedForCompare ? 'Selected' : 'Compare',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isSelectedForCompare ? const Color(0xFF0EB59A) : AppColors.lightPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (isSelectedForCompare) {
                                                _selectedCompareIds.remove(advisor.id);
                                              } else {
                                                _selectedCompareIds.add(advisor.id);
                                              }
                                            });
                                          },
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            context.go('/experts/${advisor.id}');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF134E40),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                          child: const Text('View Profile', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                          : ListView.builder(
                              itemCount: filteredAdvisors.length,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                final advisor = filteredAdvisors[index];
                                final isSelectedForCompare = _selectedCompareIds.contains(advisor.id);
                                return Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: isSelectedForCompare ? const Color(0xFF0EB59A) : AppColors.lightBorder,
                                      width: isSelectedForCompare ? 2 : 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(advisor.avatarUrl),
                                      backgroundColor: const Color(0xFF134E40),
                                    ),
                                    title: Text(advisor.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF134E40))),
                                    subtitle: Text('${advisor.role} · ${advisor.yearsOfExperience}yrs exp', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(isSelectedForCompare ? Icons.check_circle : Icons.add_circle_outline, color: isSelectedForCompare ? const Color(0xFF0EB59A) : AppColors.lightPrimary, size: 20),
                                          onPressed: () { setState(() { if (isSelectedForCompare) { _selectedCompareIds.remove(advisor.id); } else { _selectedCompareIds.add(advisor.id); } }); },
                                        ),
                                        const SizedBox(width: 4),
                                        ElevatedButton(
                                          onPressed: () => context.go('/experts/${advisor.id}'),
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF134E40), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                          child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 11)),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
          if (_selectedCompareIds.isNotEmpty)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF134E40),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Compare Candidates (${_selectedCompareIds.length})',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Align side-by-side scope requirements, availability, and retention options.',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedCompareIds.clear();
                            });
                          },
                          child: const Text('Clear', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Forms.showSuccessToast(context, 'Comparing ${_selectedCompareIds.length} profiles side-by-side...');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0EB59A),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Compare Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
      ],
    ),
    );
  }

  Widget _buildViewToggleButton(IconData icon, bool isGrid) {
    final bool active = _isGridView == isGrid;
    return InkWell(
      onTap: () { setState(() { _isGridView = isGrid; }); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF134E40) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: active ? Colors.white : const Color(0xFF134E40)),
      ),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.lightBorder)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
            const SizedBox(height: 20),
            _buildFilterDropdown('Role Type', ['All', 'Fractional', 'Interim', 'Advisory'], _roleTypeFilter, (v) { setState(() { _roleTypeFilter = v!; }); }),
            const SizedBox(height: 16),
            _buildFilterDropdown('Industry', ['All', 'FinTech', 'SaaS', 'HealthTech', 'Logistics'], _selectedIndustry, (v) { setState(() { _selectedIndustry = v!; }); }),
            const SizedBox(height: 16),
            _buildFilterDropdown('Availability', ['All', 'Full-time', 'Part-time', 'Advisory'], _availabilityFilter, (v) { setState(() { _availabilityFilter = v!; }); }),
            const SizedBox(height: 16),
            _buildFilterDropdown('Location', ['All', 'Remote', 'Hybrid', 'In-office'], _locationFilter, (v) { setState(() { _locationFilter = v!; }); }),
            const SizedBox(height: 16),
            Text('Experience (years)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
            RangeSlider(
              values: _experienceRange,
              min: 0, max: 30, divisions: 30,
              labels: RangeLabels('${_experienceRange.start.toInt()}', '${_experienceRange.end.toInt()}'),
              onChanged: (v) { setState(() { _experienceRange = v; }); },
              activeColor: const Color(0xFF0EB59A),
            ),
            const SizedBox(height: 8),
            Text('Monthly Budget (₹L)', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
            RangeSlider(
              values: _budgetRange,
              min: 0, max: 10, divisions: 10,
              labels: RangeLabels('${_budgetRange.start.toInt()}L', '${_budgetRange.end.toInt()}L'),
              onChanged: (v) { setState(() { _budgetRange = v; }); },
              activeColor: const Color(0xFF0EB59A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.lightTextSecondary)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.inter(fontSize: 13)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.lightBorder)),
            filled: true, fillColor: const Color(0xFFF4F7F5),
          ),
        ),
      ],
    );
  }
}

class DetailedExpertProfileView extends ConsumerStatefulWidget {
  final String expertId;
  const DetailedExpertProfileView({Key? key, required this.expertId}) : super(key: key);

  @override
  ConsumerState<DetailedExpertProfileView> createState() => _DetailedExpertProfileViewState();
}

class _DetailedExpertProfileViewState extends ConsumerState<DetailedExpertProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final advisors = MockService.getMockAdvisors();
    final advisor = advisors.firstWhere(
      (a) => a.id == widget.expertId,
      orElse: () => advisors.first,
    );

    final isRequested = ref.watch(introductionRequestsProvider.notifier).isRequested(advisor.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: Text(advisor.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF134E40)),
          onPressed: () => context.go('/experts'),
        ),
      ),
      body: Column(
        children: [
          // Header banner card
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.lightBorder),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(advisor.avatarUrl),
                      backgroundColor: const Color(0xFF134E40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(advisor.name, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                              ),
                              if (advisor.isVetted) const Icon(Icons.verified, color: Color(0xFF0EB59A), size: 18),
                            ],
                          ),
                          Text(advisor.role, style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              _buildBadge(Icons.location_on_outlined, advisor.location),
                              _buildBadge(Icons.work_outline, '${advisor.yearsOfExperience} yrs'),
                              _buildBadge(Icons.star, '${advisor.rating}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: isRequested ? null : () => _showRequestIntroDialog(advisor),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRequested ? Colors.grey : const Color(0xFF134E40),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[200],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(isRequested ? 'Requested' : 'Request Intro', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF134E40),
              unselectedLabelColor: AppColors.lightTextSecondary,
              indicatorColor: const Color(0xFF0EB59A),
              labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Experience'),
                Tab(text: 'Case Studies'),
                Tab(text: 'Rate & Availability'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(advisor),
                _buildExperienceTab(advisor),
                _buildCaseStudiesTab(),
                _buildRateAvailabilityTab(advisor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(AdvisorModel advisor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0, color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biography', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                  const SizedBox(height: 12),
                  Text(advisor.biography, style: GoogleFonts.inter(fontSize: 14, color: AppColors.lightTextSecondary, height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0, color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Services', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                  const SizedBox(height: 12),
                  ...['Strategic Advisory', 'Fractional Leadership', 'Interim Management', 'Board Consulting'].map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF0EB59A), size: 16),
                        const SizedBox(width: 8),
                        Text(s, style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0, color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Languages', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: ['English (Native)', 'Hindi (Fluent)', 'Spanish (Business)'].map((l) => Chip(
                      label: Text(l, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF134E40))),
                      backgroundColor: const Color(0xFFF4F7F5), side: BorderSide.none,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0, color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Core Competencies', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: advisor.skills.map((skill) => Chip(
                      label: Text(skill, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF134E40))),
                      backgroundColor: const Color(0xFFF4F7F5), side: BorderSide.none,
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceTab(AdvisorModel advisor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildTimelineItem(
            company: advisor.lastKnownCompany,
            role: advisor.role.replaceAll('Former ', ''),
            period: '2019 - 2026',
            desc: 'Directed global organizational design, core platform scalability architecture audits, and spearheaded high-capacity transaction handling.',
          ),
          _buildTimelineDivider(),
          _buildTimelineItem(
            company: 'Global Tech Consulting Corp',
            role: 'SVP of Product Engineering',
            period: '2012 - 2019',
            desc: 'Built custom SaaS execution protocols, established distributed engineering centers of excellence, and managed 100+ global personnel.',
          ),
          _buildTimelineDivider(),
          _buildTimelineItem(
            company: 'InnovateStart Inc.',
            role: 'VP of Engineering',
            period: '2008 - 2012',
            desc: 'Led product-driven engineering organization, scaling from 15 to 80 engineers across 3 continents.',
          ),
          _buildTimelineDivider(),
          _buildTimelineItem(
            company: 'Pinnacle Systems Ltd.',
            role: 'Senior Engineering Manager',
            period: '2004 - 2008',
            desc: 'Managed cross-functional delivery teams for enterprise SaaS products in the fintech domain.',
          ),
        ],
      ),
    );
  }

  Widget _buildCaseStudiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildCollapsibleCaseStudy(
            title: 'Digital Transformation at MegaBank',
            client: 'MegaBank Corp.',
            outcome: '40% cost reduction, 2x delivery velocity',
            details: 'Led a full-stack digital transformation initiative migrating 200+ legacy services to cloud-native microservices architecture. Reduced infrastructure costs by 40% and improved deployment frequency by 200%.',
          ),
          const SizedBox(height: 12),
          _buildCollapsibleCaseStudy(
            title: 'GTM Strategy for FinTech Unicorn',
            client: 'PayFlow Inc.',
            outcome: '₹12Cr revenue in first 2 quarters',
            details: 'Architected the go-to-market strategy and built the core payments platform from ground up. Scaled engineering from 5 to 50 engineers in 8 months. Achieved PCI-DSS compliance and SOC2 certification.',
          ),
          const SizedBox(height: 12),
          _buildCollapsibleCaseStudy(
            title: 'Operational Turnaround at HealthTech Co.',
            client: 'MediSync Health',
            outcome: 'SLA compliance from 72% to 98%',
            details: 'Restructured engineering operations, implemented Agile-at-scale methodologies, and established PMO governance frameworks. Reduced critical incident response time by 65%.',
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleCaseStudy({required String title, required String client, required String outcome, required String details}) {
    return Card(
      elevation: 0, color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.lightBorder)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF134E40))),
                      const SizedBox(height: 4),
                      Text(client, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.expand_more, color: const Color(0xFF134E40)),
                  onPressed: () { setState(() {}); }, // simplified toggle
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(6)),
              child: Text(outcome, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF0EB59A), fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            Text(details, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildRateAvailabilityTab(AdvisorModel advisor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0, color: const Color(0xFF134E40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scope & Retainer Options', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Secured via PMO Escrow Milestones', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF0EB59A))),
                  const SizedBox(height: 20),
                  _buildRetainerCard(title: 'Advisory Retainer', price: '₹1.5L / mo', hours: '10 hrs / week', isSelected: true),
                  const SizedBox(height: 12),
                  _buildRetainerCard(title: 'Fractional Operator', price: '₹2.8L / mo', hours: '20 hrs / week', isSelected: false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0, color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Availability', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                  const SizedBox(height: 12),
                  _buildInfoRow('Status', 'Available (Immediate)'),
                  _buildInfoRow('Hours', '20-40 hrs / week'),
                  _buildInfoRow('Time Zone', 'IST (GMT+5:30)'),
                  _buildInfoRow('Preferred Engagement', 'Fractional / Advisory'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary)),
          Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.lightTextSecondary),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.inter(fontSize: 11, color: AppColors.lightTextSecondary)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String company,
    required String role,
    required String period,
    required String desc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(role, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF134E40))),
            Text(period, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
          ],
        ),
        const SizedBox(height: 2),
        Text(company, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xFF0EB59A))),
        const SizedBox(height: 8),
        Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary, height: 1.4)),
      ],
    );
  }

  Widget _buildTimelineDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Divider(color: Colors.grey[200], thickness: 1),
    );
  }

  Widget _buildRetainerCard({
    required String title,
    required String price,
    required String hours,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF0D3E33) : Colors.transparent,
        border: Border.all(color: isSelected ? const Color(0xFF0EB59A) : Colors.white24, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 2),
              Text(hours, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
            ],
          ),
          Text(price, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF0EB59A))),
        ],
      ),
    );
  }

  void _showRequestIntroDialog(AdvisorModel advisor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Request Private Introduction',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF134E40)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit an intro request to PMO Governance to align scopes with ${advisor.name}.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 16),
              _buildCheckOption('Confirm project requirements are uploaded'),
              _buildCheckOption('Approve initial hourly/monthly rates'),
              _buildCheckOption('Acknowledge standard 3-day turnaround'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(introductionRequestsProvider.notifier).requestIntroduction(advisor.id);
                Forms.showSuccessToast(context, 'Introduction request logged with PMO.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0EB59A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckOption(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF0EB59A), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightPrimary))),
        ],
      ),
    );
  }
}

class EscrowFinancialControlView extends ConsumerStatefulWidget {
  const EscrowFinancialControlView({Key? key}) : super(key: key);

  @override
  ConsumerState<EscrowFinancialControlView> createState() => _EscrowFinancialControlViewState();
}

class _EscrowFinancialControlViewState extends ConsumerState<EscrowFinancialControlView> {
  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(escrowTransactionsProvider);
    final milestones = ref.watch(milestonesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escrow Financial Control',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF134E40),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Review active milestone funding, platform transaction ledger, and release disbursements.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildFinanceKpi(
                      title: 'Funded in Escrow',
                      amount: '₹8,50,000',
                      desc: 'Assigned to active milestones',
                      color: const Color(0xFF134E40),
                      icon: Icons.lock_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFinanceKpi(
                      title: 'Disbursed to Date',
                      amount: '₹14,20,000',
                      desc: 'Successfully released payments',
                      color: const Color(0xFF0EB59A),
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFinanceKpi(
                      title: 'Pending Approvals',
                      amount: '₹2,50,000',
                      desc: 'Awaiting scope review',
                      color: const Color(0xFFF59E0B),
                      icon: Icons.rate_review_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.lightBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Milestones Awaiting Release',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF134E40),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: milestones.length,
                              separatorBuilder: (context, idx) => Divider(color: Colors.grey[200]),
                              itemBuilder: (context, idx) {
                                final ms = milestones[idx];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _getMilestoneStatusColor(ms.status).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getMilestoneStatusIcon(ms.status),
                                          color: _getMilestoneStatusColor(ms.status),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(ms.title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF134E40))),
                                            const SizedBox(height: 2),
                                            Text(ms.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                                            const SizedBox(height: 4),
                                            Text('Due: ${ms.dueDate} · Cost: ${ms.cost}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.lightTextSecondary)),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      if (ms.status == 'pending_approval')
                                        ElevatedButton(
                                          onPressed: () => _triggerReleaseFlow(ms),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0EB59A),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text('Release Funds', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        )
                                      else
                                        _buildTextBadge(ms.status),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: AppColors.lightBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaction Ledger',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF134E40),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: transactions.take(5).length,
                              separatorBuilder: (context, idx) => Divider(color: Colors.grey[100]),
                              itemBuilder: (context, idx) {
                                final tx = transactions[idx];
                                final isRelease = tx.type == 'milestone_release';
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(tx.ref, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.lightPrimary)),
                                          Text(
                                            isRelease ? '- ${tx.amount}' : '+ ${tx.amount}',
                                            style: GoogleFonts.outfit(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: isRelease ? Colors.red[700] : const Color(0xFF0EB59A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(tx.description, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(tx.date, style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
                                          Text(tx.status, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: tx.status == 'Released' ? Colors.blue : Colors.green)),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceKpi({
    required String title,
    required String amount,
    required String desc,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                  const SizedBox(height: 4),
                  Text(amount, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightPrimary)),
                  const SizedBox(height: 2),
                  Text(desc, style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightTextSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMilestoneStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF0EB59A);
      case 'pending_approval':
        return const Color(0xFFF59E0B);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      default:
        return Colors.grey;
    }
  }

  IconData _getMilestoneStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'pending_approval':
        return Icons.rate_review_outlined;
      case 'in_progress':
        return Icons.pending_outlined;
      default:
        return Icons.lock_clock;
    }
  }

  Widget _buildTextBadge(String status) {
    String label = status.replaceAll('_', ' ').toUpperCase();
    Color color = _getMilestoneStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  void _triggerReleaseFlow(Milestone ms) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.shield_outlined, color: Color(0xFF0EB59A), size: 48),
              const SizedBox(height: 12),
              Text(
                'Authorize Escrow Disbursement',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF134E40)),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to release ${ms.cost} to the advisor? This action is immediate and secure.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref.read(milestonesProvider.notifier).approveMilestone(ms.id);
                        ref.read(escrowTransactionsProvider.notifier).releaseMilestoneTx(ms.engagementId, ms.title, ms.cost);
                        Forms.showSuccessToast(context, 'Milestone payments released successfully.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0EB59A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Release Funds Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AnalyticsHubView extends ConsumerStatefulWidget {
  const AnalyticsHubView({Key? key}) : super(key: key);

  @override
  ConsumerState<AnalyticsHubView> createState() => _AnalyticsHubViewState();
}

class _AnalyticsHubViewState extends ConsumerState<AnalyticsHubView> {
  String _activeTab = 'Overview';

  final List<String> _tabs = [
    'Overview', 'Hiring', 'Talent Pool', 'Engagement', 'Financial', 'Performance', 'Pipeline', 'Reports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Company Performance Analytics',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF134E40),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track monthly executive investment, advisor engagement velocity, and SLA completion compliance.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // 8-tab sub-navigation bar
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _tabs.map((tab) {
                    final isSelected = _activeTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () { setState(() { _activeTab = tab; }); },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF134E40) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? const Color(0xFF134E40) : AppColors.lightBorder),
                          ),
                          child: Text(
                            tab,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              // Content sections based on active tab
              if (_activeTab == 'Overview') ...[
                _buildOverviewContent(),
              ] else if (_activeTab == 'Hiring') ...[
                _buildSectionPlaceholder('Hiring Analytics', 'Track hiring velocity, time-to-fill, and candidate pipeline metrics.'),
              ] else if (_activeTab == 'Talent Pool') ...[
                _buildSectionPlaceholder('Talent Pool', 'View your vetted talent pool composition, skill distribution, and availability.'),
              ] else if (_activeTab == 'Engagement') ...[
                _buildSectionPlaceholder('Engagement Analytics', 'Monitor engagement health, SLA compliance, and milestone completion rates.'),
              ] else if (_activeTab == 'Financial') ...[
                _buildSectionPlaceholder('Financial Overview', 'Budget utilization, escrow balances, and projected spend analysis.'),
              ] else if (_activeTab == 'Performance') ...[
                _buildSectionPlaceholder('Performance Metrics', 'Expert performance scores, deliverable quality ratings, and feedback summaries.'),
              ] else if (_activeTab == 'Pipeline') ...[
                _buildSectionPlaceholder('Pipeline Analytics', 'Requirement pipeline, matching velocity, and conversion funnel metrics.'),
              ] else if (_activeTab == 'Reports') ...[
                _buildSectionPlaceholder('Reports & Exports', 'Generate custom reports, download audit trails, and export analytics data.'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewContent() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard('₹22.5L', 'Total Project Capital', '+12.4% vs last mo', Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('2.4 days', 'Avg Sourcing SLA', '-1.1 days improvement', Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('96.4%', 'Milestone Health Score', 'Excellent SLA Delivery', const Color(0xFF0EB59A))),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Card(
                elevation: 0, color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Monthly Capital Expenditure', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                          Text('FY 2026', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 180, width: double.infinity,
                        child: SparklineWidget(data: const [1.2, 1.5, 1.4, 1.8, 2.2, 2.5], color: const Color(0xFF0EB59A), width: double.infinity, height: 180),
                      ),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                        Text('Jan', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Feb', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Mar', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Apr', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('May', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Jun', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 2,
              child: Card(
                elevation: 0, color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Investment Allocations', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                      const SizedBox(height: 20),
                      Center(
                        child: DonutChartWidget(
                          size: 130, strokeWidth: 14,
                          segments: [
                            DonutSegment(value: 50, color: const Color(0xFF134E40), label: 'CTO / Engineering'),
                            DonutSegment(value: 30, color: const Color(0xFF0EB59A), label: 'CFO / Finance'),
                            DonutSegment(value: 20, color: const Color(0xFFF59E0B), label: 'CMO / Growth'),
                          ],
                          centerWidget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹22.5L', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                              Text('Disbursed', style: GoogleFonts.inter(fontSize: 10, color: AppColors.lightTextSecondary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildLegendItem(const Color(0xFF134E40), 'CTO & Product (50%)'),
                      _buildLegendItem(const Color(0xFF0EB59A), 'Finance & M&A (30%)'),
                      _buildLegendItem(const Color(0xFFF59E0B), 'CMO & Marketing (20%)'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionPlaceholder(String title, String subtitle) {
    return Card(
      elevation: 0, color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.lightBorder)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.analytics_outlined, size: 48, color: AppColors.lightTextSecondary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String value, String label, String contextMsg, Color statusColor) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.lightTextSecondary)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.trending_up, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(contextMsg, style: GoogleFonts.inter(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightPrimary)),
        ],
      ),
    );
  }
}

class MessagingHubView extends StatefulWidget {
  const MessagingHubView({Key? key}) : super(key: key);

  @override
  State<MessagingHubView> createState() => _MessagingHubViewState();
}

class _MessagingHubViewState extends State<MessagingHubView> {
  int _selectedThreadIndex = 0;
  final TextEditingController _msgController = TextEditingController();
  final Map<int, List<Map<String, dynamic>>> _threadMessages = {
    0: [
      {
        'text': 'Hello, Arjun. I reviewed the GTM launch parameters. The timeline looks very solid.',
        'time': '10:14 AM',
        'isUser': true,
      },
      {
        'text': 'Great to hear, Sarah! Are there any concerns regarding the marketing budget distribution for Q3?',
        'time': '10:20 AM',
        'isUser': false,
      },
      {
        'text': 'Not at all. We have optimized allocations on digital channels. Let us synchronize on a video call.',
        'time': '10:25 AM',
        'isUser': true,
      },
    ],
    1: [
      {
        'text': 'Did you check the Series B financial models for Q4?',
        'time': 'Yesterday',
        'isUser': false,
      },
      {
        'text': 'Yes, both scenarios indicate steady 2.8x runway extension.',
        'time': 'Yesterday',
        'isUser': true,
      },
    ],
    2: [
      {
        'text': 'Let\'s align the engineering scrum velocity with the product board.',
        'time': 'May 22',
        'isUser': false,
      },
      {
        'text': 'Perfect. Let us make sure team velocity is tracked on Jira first.',
        'time': 'May 22',
        'isUser': true,
      },
    ],
  };

  final List<Map<String, dynamic>> _threads = [
    {
      'name': 'Arjun Mehta',
      'company': 'Acme Corp.',
      'role': 'VP Operations',
      'lastMsg': 'Not at all. We have optimized allocation...',
      'time': '10:25 AM',
      'unread': true,
      'initials': 'AM',
      'color': const Color(0xFF0EB59A),
    },
    {
      'name': 'Bruce Wayne',
      'company': 'Wayne Ent.',
      'role': 'Managing Director',
      'lastMsg': 'Yes, both scenarios indicate steady 2.8...',
      'time': 'Yesterday',
      'unread': false,
      'initials': 'BW',
      'color': const Color(0xFF1E293B),
    },
    {
      'name': 'Pepper Potts',
      'company': 'Stark Ind.',
      'role': 'Chief Executive Officer',
      'lastMsg': 'Perfect. Let us make sure team velocity...',
      'time': 'May 22',
      'unread': false,
      'initials': 'PP',
      'color': const Color(0xFFEA580C),
    },
  ];

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';

    setState(() {
      _threadMessages[_selectedThreadIndex]!.add({
        'text': text,
        'time': timeStr,
        'isUser': true,
      });
      _threads[_selectedThreadIndex]['lastMsg'] = text;
      _threads[_selectedThreadIndex]['time'] = 'Just now';
      _msgController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;
    final activeThread = _threads[_selectedThreadIndex];
    final messages = _threadMessages[_selectedThreadIndex] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: Row(
        children: [
          // Left Pane - Thread List
          Container(
            width: isWide ? 340 : 280,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: AppColors.lightBorder, width: 1.5),
              ),
            ),
            child: Column(
              children: [
                // Search field matching screenshot: "Search (⌘K)"
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7F5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.lightTextSecondary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: GoogleFonts.inter(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search (⌘K)',
                              hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1, color: AppColors.lightBorder),
                // Threads list
                Expanded(
                  child: ListView.builder(
                    itemCount: _threads.length,
                    itemBuilder: (context, index) {
                      final th = _threads[index];
                      final isSelected = index == _selectedThreadIndex;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedThreadIndex = index;
                          });
                        },
                        child: Container(
                          color: isSelected ? const Color(0xFF134E40) : Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isSelected ? Colors.white : th['color'],
                                child: Text(
                                  th['initials'],
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFF134E40) : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${th['name']} (${th['company']})',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected ? Colors.white : const Color(0xFF1C3627),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          th['time'],
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            color: isSelected ? Colors.white70 : Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      th['role'],
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected ? const Color(0xFF34D399) : const Color(0xFF0EB59A),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      th['lastMsg'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: isSelected ? Colors.white60 : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Right Pane - Message Window
          Expanded(
            child: Column(
              children: [
                // Top header bar matching screenshot: Arjun Mehta (Acme Corp.), VP Operations, info icon, "Schedule a Meeting" button
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.lightBorder, width: 1.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: activeThread['color'],
                            child: Text(
                              activeThread['initials'],
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${activeThread['name']} (${activeThread['company']})',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF134E40),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.info_outline, size: 14, color: AppColors.lightTextSecondary),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0EB59A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Active now · ${activeThread['role']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showSyncSchedulerModal();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF134E40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 14, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Schedule a Meeting',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Chat Messages Window
                Expanded(
                  child: Container(
                    color: const Color(0xFFFAFBF9),
                    padding: const EdgeInsets.all(24.0),
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg['isUser'] == true;

                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: const BoxConstraints(maxWidth: 500),
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFF134E40) : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(2),
                                bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(12),
                              ),
                              border: isUser ? null : Border.all(color: AppColors.lightBorder),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x05000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['text'],
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: isUser ? Colors.white : const Color(0xFF1C3627),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      msg['time'],
                                      style: GoogleFonts.inter(
                                        fontSize: 9,
                                        color: isUser ? Colors.white70 : Colors.grey[500],
                                      ),
                                    ),
                                    if (isUser) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.done_all, color: Color(0xFF0EB59A), size: 12),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Bottom message input area matching screenshot
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.lightBorder, width: 1.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: AppColors.lightTextSecondary),
                        onPressed: () {
                          Forms.showSuccessToast(context, 'Mock File Attachment Dialog');
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: _msgController,
                            onSubmitted: (_) => _sendMessage(),
                            style: GoogleFonts.inter(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Write a message...',
                              hintStyle: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.sentiment_satisfied_alt, color: AppColors.lightTextSecondary),
                            onPressed: () => _showEmojiPicker(),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF134E40),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          onPressed: _sendMessage,
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

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          height: 320,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Emoji', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                  IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.of(ctx).pop()),
                ],
              ),
              const Divider(),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 8,
                  childAspectRatio: 1,
                  children: '😀😂😍🤔😎🙌👍❤️🔥🎉💯⭐🌈🎨🎶🚀💡🎯🏆💎🌟✨🔥🎈🎁🎊🤩😇🙏💪🦄🍀🌻⭐️💫⚡️🎵🧠👑📈💼🤝🌍⚙️🔒📊🔑💡'.split('').map((emoji) {
                    return InkWell(
                      onTap: () {
                        final currentText = _msgController.text;
                        final cursorPos = _msgController.selection.baseOffset;
                        if (cursorPos >= 0 && cursorPos <= currentText.length) {
                          _msgController.text = '${currentText.substring(0, cursorPos)}$emoji${currentText.substring(cursorPos)}';
                          _msgController.selection = TextSelection.collapsed(offset: cursorPos + emoji.length);
                        } else {
                          _msgController.text = currentText + emoji;
                        }
                        Navigator.of(ctx).pop();
                      },
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSyncSchedulerModal() {
    String topic = '';
    DateTime selectedDate = DateTime.now();
    String duration = '30min';
    String platform = 'Google Meet';
    int hour = 10;
    int minute = 0;
    String amPm = 'AM';
    String agenda = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        int step = 1;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(step == 1 ? 'Step 1: Topic & Platform' : 'Step 2: Schedule Time', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                        IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.of(ctx).pop()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (step == 1) ...[
                      TextField(
                        decoration: const InputDecoration(labelText: 'Topic', border: OutlineInputBorder()),
                        onChanged: (v) => topic = v,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_month, size: 16),
                              label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                              onPressed: () async {
                                final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                                if (picked != null) { setModalState(() { selectedDate = picked; }); }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: duration,
                        items: ['30min', '45min', '60min'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (v) { if (v != null) { setModalState(() { duration = v; }); } },
                        decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: platform,
                        items: ['Google Meet', 'Zoom'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                        onChanged: (v) { if (v != null) { setModalState(() { platform = v; }); } },
                        decoration: const InputDecoration(labelText: 'Platform', border: OutlineInputBorder()),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: hour,
                              items: List.generate(12, (i) => i + 1).map((h) => DropdownMenuItem(value: h, child: Text(h.toString().padLeft(2, '0')))).toList(),
                              onChanged: (v) { if (v != null) { setModalState(() { hour = v; }); } },
                              decoration: const InputDecoration(labelText: 'Hour', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: minute,
                              items: [0, 15, 30, 45].map((m) => DropdownMenuItem(value: m, child: Text(m.toString().padLeft(2, '0')))).toList(),
                              onChanged: (v) { if (v != null) { setModalState(() { minute = v; }); } },
                              decoration: const InputDecoration(labelText: 'Minute', border: OutlineInputBorder()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: amPm,
                              items: ['AM', 'PM'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                              onChanged: (v) { if (v != null) { setModalState(() { amPm = v; }); } },
                              decoration: const InputDecoration(labelText: '', border: OutlineInputBorder()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'Agenda', border: OutlineInputBorder(), alignLabelWithHint: true),
                        onChanged: (v) => agenda = v,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (step == 2)
                          TextButton(
                            onPressed: () { setModalState(() { step = 1; }); },
                            child: const Text('Back'),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed: () {
                            if (step == 1) {
                              setModalState(() { step = 2; });
                            } else {
                              Navigator.of(ctx).pop();
                              Forms.showSuccessToast(context, 'Meeting scheduled successfully!');
                              context.go('/meetings');
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF134E40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                          child: Text(step == 1 ? 'Next' : 'Confirm & Schedule', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ScheduledMeetingsCalendarView extends StatefulWidget {
  const ScheduledMeetingsCalendarView({Key? key}) : super(key: key);

  @override
  State<ScheduledMeetingsCalendarView> createState() => _ScheduledMeetingsCalendarViewState();
}

class _ScheduledMeetingsCalendarViewState extends State<ScheduledMeetingsCalendarView> {
  String _activeTab = 'UPCOMING SYNCS';

  final List<Map<String, dynamic>> _upcomingMeetings = [
    {
      'title': 'Q3 GTM Strategy Execution Review',
      'date': '2026-06-14',
      'time': '11:00 (45 mins)',
      'description': 'Analyze marketing spend distribution and channel conversions across paid search and influencer alignments.',
      'clientInitials': 'AM',
      'clientName': 'Arjun Mehta',
      'clientRole': 'Client Coordinator',
      'clientColor': const Color(0xFF0EB59A),
    },
    {
      'title': 'Series B Financial Model Auditing',
      'date': '2026-06-16',
      'time': '15:30 (1 hour)',
      'description': 'Auditing LTV/CAC scenario tables, runway calculations, and preparing fundraising projection data room.',
      'clientInitials': 'BW',
      'clientName': 'Bruce Wayne',
      'clientRole': 'Managing Director',
      'clientColor': const Color(0xFF1E293B),
    },
  ];

  final List<Map<String, dynamic>> _pastMeetings = [
    {
      'title': 'Kickoff Briefing & Scope Sign-off',
      'date': '2026-06-01',
      'time': '10:00 (30 mins)',
      'description': 'Aligned on project milestones, pricing scope, and released initial payment terms.',
      'clientInitials': 'AM',
      'clientName': 'Arjun Mehta',
      'clientRole': 'Client Coordinator',
      'clientColor': const Color(0xFF0EB59A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 900;
    final meetings = _activeTab == 'UPCOMING SYNCS' ? _upcomingMeetings : _pastMeetings;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header
              Text(
                'Scheduled Meetings (Expert Portal)',
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF134E40),
                ),
              ),
              const SizedBox(height: 24),

              // Navigation & Tabs Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildTabButton('UPCOMING SYNCS'),
                      const SizedBox(width: 24),
                      _buildTabButton('PAST SESSIONS'),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      context.go('/messages');
                      Forms.showSuccessToast(context, 'Opening chat channel for scheduling...');
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF134E40)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 14, color: Color(0xFF134E40)),
                        const SizedBox(width: 8),
                        Text(
                          'Open Chats to Schedule',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF134E40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Meetings list
              if (meetings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: Text(
                    'No scheduled meetings found.',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.lightTextSecondary),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final m = meetings[index];
                    return _buildMeetingCard(m, isWide);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title) {
    final bool isSelected = _activeTab == title;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = title;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF134E40) : AppColors.lightTextSecondary.withOpacity(0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 80,
            color: isSelected ? const Color(0xFF0EB59A) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> m, bool isWide) {
    final meetingContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title date and time row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF0EB59A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m['title'],
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF134E40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: AppColors.lightTextSecondary),
                      const SizedBox(width: 6),
                      Text(
                        m['date'],
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 14, color: AppColors.lightTextSecondary),
                      const SizedBox(width: 6),
                      Text(
                        m['time'],
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Description block matching screenshot
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFBF9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.notes, size: 16, color: AppColors.lightTextSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  m['description'],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final clientPanel = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: m['clientColor'],
          child: Text(
            m['clientInitials'],
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Client: ${m['clientName']}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF134E40),
              ),
            ),
            Text(
              m['clientRole'],
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );

    final actionsPanel = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            Forms.showSuccessToast(context, 'Launching secure Zoom sync meeting room...');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF134E40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Row(
            children: [
              const Icon(Icons.videocam, size: 14, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Join Meet',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () {
            Forms.showSuccessToast(context, 'Meeting cancellation request submitted.');
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFEF4444)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          child: const Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: meetingContent,
                  ),
                  const SizedBox(width: 24),
                  Container(
                    height: 100,
                    width: 1.5,
                    color: AppColors.lightBorder,
                  ),
                  const SizedBox(width: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      clientPanel,
                      const SizedBox(height: 16),
                      actionsPanel,
                    ],
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  meetingContent,
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.lightBorder),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      clientPanel,
                      actionsPanel,
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        appBar: AppBar(
          title: Text(
            'Privacy Policy',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF134E40),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.lightBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ExigentCX Privacy Policy', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                      const SizedBox(height: 8),
                      Text('Last updated: June 12, 2026', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                      const SizedBox(height: 20),
                      _buildLegalSection(
                        title: '1. Information We Collect',
                        content: 'We collect information you provide directly to us when applying as a vetted advisor or registering a company. This includes name, email address, LinkedIn profile links, company identity documents, tax registrations, resume uploads, and escrow banking routing parameters.',
                      ),
                      _buildLegalSection(
                        title: '2. Escrow & Bank Details Vetting',
                        content: 'ExigentCX partners with secure payout rails and banking institutions to hold funds in escrow. We do not store raw credit card numbers or banking passwords. All transfers comply with regulatory AML/KYC checks before fund disbursement.',
                      ),
                      _buildLegalSection(
                        title: '3. Data Security & Non-Disclosure',
                        content: 'We use industry-standard encryption protocols (SSL/TLS) to secure all document uploads. Vetted advisors signing platform NDAs agree to maintain absolute confidentiality of all intellectual property shared by client companies.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
          const SizedBox(height: 8),
          Text(content, style: GoogleFonts.inter(fontSize: 14, color: AppColors.lightTextSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        appBar: AppBar(
          title: Text(
            'Terms of Service',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF134E40),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.lightBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ExigentCX Terms of Service', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
                      const SizedBox(height: 8),
                      Text('Last updated: June 12, 2026', style: GoogleFonts.inter(fontSize: 12, color: AppColors.lightTextSecondary)),
                      const SizedBox(height: 20),
                      _buildLegalSection(
                        title: '1. Vetting and Acceptance',
                        content: 'ExigentCX provides vetting and matching. Acceptance into the network as an advisor or approval of requirements is at the sole discretion of the PMO. Users must provide verifiably accurate LinkedIn credentials.',
                      ),
                      _buildLegalSection(
                        title: '2. Escrow & Milestones Obligations',
                        content: 'Client companies must fund milestones before work begins. Payments held in escrow are released when the company confirms completed deliverables. Dispute resolutions are arbitrated by the PMO.',
                      ),
                      _buildLegalSection(
                        title: '3. Fees and Billing',
                        content: 'We charge a standard platform commission (typically 5-10%) on released funds. Withdrawal requests by advisors are processed in 3 business days once the checkmark animation is triggered.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegalSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF134E40))),
          const SizedBox(height: 8),
          Text(content, style: GoogleFonts.inter(fontSize: 14, color: AppColors.lightTextSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

