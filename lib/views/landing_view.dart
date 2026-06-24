import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_charts.dart';
import '../widgets/forms.dart';
import '../viewmodels/app_state.dart';

class LandingView extends ConsumerStatefulWidget {
  const LandingView({super.key});

  @override
  ConsumerState<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends ConsumerState<LandingView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _newsletterController = TextEditingController();

  final List<Map<String, String>> problemSlides = [
    {
      'title': 'The Corporate Vetting Gap',
      'content': 'Hiring high-level executive talent takes an average of 4-6 months and carries an 18% churn rate. CXO Connect matches you with vetted leaders in 48 hours.',
      'image': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=600',
      'tag': 'COMPANIES',
    },
    {
      'title': 'The Fractional Advisor Opportunity',
      'content': 'Top tier CXOs prefer portfolio advisory roles, but spend 30% of their time on business development and billing. We automate their workspace completely.',
      'image': 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=600',
      'tag': 'PROFESSIONALS',
    },
    {
      'title': 'Our Managed PMO Solution',
      'content': 'We don\'t just match; we govern. Our dedicated project management office ensures deliverables compliance, escrow protection, and milestone tracking.',
      'image': 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?q=80&w=600',
      'tag': 'GOVERNANCE',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    _newsletterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeKey = ref.watch(homeKeyProvider);
    final howItWorksKey = ref.watch(howItWorksKeyProvider);
    final benefitsKey = ref.watch(benefitsKeyProvider);
    final contactKey = ref.watch(contactKeyProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBgDeep,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.darkBgSecondary.withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'CXO CONNECT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.0,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: InkWell(
              onTap: () => context.push('/signin'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.mintGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mintTeal.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    )
                  ]
                ),
                child: Text('Sign In', style: GoogleFonts.outfit(color: AppColors.darkBgDeep, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildPremiumDrawer(context),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. STUNNING HERO SECTION
            Stack(
              children: [
                _buildAnimatedBackground(),
                Container(
                  key: homeKey,
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    left: 24.0, 
                    right: 24.0, 
                    top: MediaQuery.of(context).padding.top + 100, 
                    bottom: 80.0
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.mintTeal.withOpacity(0.4),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: AppColors.mintTeal, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'PREMIUM EXECUTIVE NETWORK',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mintTeal,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFD5E0FA)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          'Elite Expertise.\nLeadership on Demand.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Bridging the gap between visionary hiring firms and elite fractional executives under a fully managed PMO governance layer.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            text: 'Enter Gateway',
                            onTap: () => context.push('/signin'),
                            width: 220,
                            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.darkBgDeep, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 2. TRUSTED BY MARQUEE (Stunning fade edges)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.darkContainer,
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05)),
                  bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
                )
              ),
              child: Column(
                children: [
                  Text(
                    'TRUSTED BY HIGH-GROWTH FIRMS',
                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 3.0),
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                        stops: [0.0, 0.1, 0.9, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: ['FINTECHSCALE', 'STRATOS HEALTH', 'NEXUS ENTERPRISE', 'VERTEX LOGIC', 'FLEXPORT', 'STRIPE']
                            .map((n) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    n,
                                    style: GoogleFonts.spaceGrotesk(
                                      color: Colors.white.withOpacity(0.3), 
                                      fontWeight: FontWeight.w800, 
                                      fontSize: 16, 
                                      letterSpacing: 2.5
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 64),

            // 3. THE BRIDGE (Glassmorphic Card)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(40.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.01),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.mintTeal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.handshake_outlined, color: AppColors.mintTeal, size: 32),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'The Bridge to Elite Leadership',
                          style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We align enterprise challenges with certified independent CFOs, CTOs, CMOs, and COOs. Powered by secure escrow deposits and active project milestones, ensuring risk-free elite collaboration.',
                          style: GoogleFonts.inter(color: Colors.white70, height: 1.7, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),

            // 4. HOW IT WORKS (Redesigned with lines and elegance)
            Padding(
              key: howItWorksKey,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text('How It Works', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('A seamless journey for both sides of the marketplace.', style: GoogleFonts.inter(color: Colors.white54, fontSize: 14)),
                  const SizedBox(height: 48),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 700;
                      final items = [
                        _buildRoleTimeline('For Companies', [
                          ('Define Business Needs', 'Post requirements indicating role type, budget, and milestones.'),
                          ('AI & PMO Matching', 'Get curated matches of verified executive leaders in under 48 hours.'),
                          ('Deploy & Escrow', 'Secure agreements via milestone-based escrow payments.')
                        ]),
                        if (isMobile) const SizedBox(height: 48) else const SizedBox(width: 48),
                        _buildRoleTimeline('For Advisors', [
                          ('Submit Credentials', 'Apply by linking your verified professional ex-roles and portfolio.'),
                          ('Pass Vetting Panel', 'Our PMO board audits credentials to ensure quality standards.'),
                          ('Unlock Engagements', 'Access matching scopes with fully managed milestones.')
                        ]),
                      ];

                      return isMobile 
                        ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: items)
                        : Row(crossAxisAlignment: CrossAxisAlignment.start, children: items.map((w) => w is SizedBox ? w : Expanded(child: w)).toList());
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 80),

            // 5. PROBLEM CAROUSEL
            Text('Market Voids & Solutions', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 32),
            SlidingProblemCarousel(slides: problemSlides),
            const SizedBox(height: 80),

            // 6. MEMBERSHIP BENEFITS (Glassmorphic Cards)
            Padding(
              key: benefitsKey,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text('Membership Benefits', style: GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 700;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 1 : 3,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 24,
                        childAspectRatio: isMobile ? 2.5 : 1.0,
                        children: [
                          _buildPremiumBenefitCard('Curated Matches', 'AI precisely matches candidate profiles to specific enterprise requirements.', Icons.hub_outlined),
                          _buildPremiumBenefitCard('Verified Network', 'Vigorously audited backgrounds, achievements, and legal checks.', Icons.shield_outlined),
                          _buildPremiumBenefitCard('PMO Governance', 'Standardized escrow accounts and contract systems for mutual safety.', Icons.star_border),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 80),

            // 7. FOOTER & NEWSLETTER
            Container(
              key: contactKey,
              decoration: BoxDecoration(
                color: AppColors.darkBgSecondary,
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isMobile = constraints.maxWidth < 700;
                  final content = [
                    Expanded(
                      flex: isMobile ? 0 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CXO CONNECT', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.0)),
                          const SizedBox(height: 16),
                          Text('Headquarters: Pune, MH, India\nSupport: admin@cxoconnect.com', style: GoogleFonts.inter(color: Colors.white54, height: 1.6, fontSize: 14)),
                        ],
                      ),
                    ),
                    if (isMobile) const SizedBox(height: 48) else const SizedBox(width: 48),
                    Expanded(
                      flex: isMobile ? 0 : 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Subscribe to Insights', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.darkContainer,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: TextField(
                              controller: _newsletterController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Enter your email address...',
                                hintStyle: const TextStyle(color: Colors.white30),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                fillColor: Colors.transparent,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.mintTeal.withOpacity(0.2),
                                    ),
                                    icon: const Icon(Icons.arrow_forward, color: AppColors.mintTeal, size: 20),
                                    onPressed: () {
                                      if (_newsletterController.text.trim().isNotEmpty) {
                                        Forms.showSuccessToast(context, 'Successfully subscribed to our newsletter!');
                                        _newsletterController.clear();
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ];
                  return isMobile 
                    ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content)
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return SizedBox(
          height: 600,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned(
                top: 100 * sin(_animController.value * 2 * pi),
                left: -100 + (200 * cos(_animController.value * 2 * pi)),
                child: _buildGlowOrb(AppColors.mintTeal.withOpacity(0.15), 300),
              ),
              Positioned(
                top: 200 + (100 * cos(_animController.value * 2 * pi)),
                right: -50 + (150 * sin(_animController.value * 2 * pi)),
                child: _buildGlowOrb(const Color(0xFF3B82F6).withOpacity(0.1), 400),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                  child: Container(color: Colors.transparent),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlowOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildRoleTimeline(String title, List<(String, String)> steps) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.darkContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.mintTeal)),
          const SizedBox(height: 32),
          ...steps.asMap().entries.map((entry) {
            int idx = entry.key;
            var step = entry.value;
            bool isLast = idx == steps.length - 1;
            return _buildStunningTimelineStep((idx + 1).toString(), step.$1, step.$2, isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStunningTimelineStep(String number, String title, String desc, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.mintGradient,
                  boxShadow: [
                    BoxShadow(color: AppColors.mintTeal.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))
                  ]
                ),
                child: Center(child: Text(number, style: const TextStyle(color: AppColors.darkBgDeep, fontWeight: FontWeight.bold, fontSize: 14))),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.mintTeal.withOpacity(0.5), AppColors.mintTeal.withOpacity(0.0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    ),
                  ),
                )
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(desc, style: GoogleFonts.inter(color: Colors.white54, fontSize: 14, height: 1.5)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPremiumBenefitCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.mintTeal, size: 28),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
          const SizedBox(height: 12),
          Text(desc, style: GoogleFonts.inter(color: Colors.white54, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildPremiumDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.darkBgSecondary.withOpacity(0.8),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('CXO CONNECT', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 2.0, color: Colors.white)),
                ),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
                const SizedBox(height: 16),
                _drawerItem(context, 'Find Experts', Icons.search_rounded, '/experts'),
                _drawerItem(context, 'Post a Requirement', Icons.add_circle_outline_rounded, '/requirements/create'),
                _drawerItem(context, 'Join as Company', Icons.business_rounded, '/join-company'),
                _drawerItem(context, 'Join as Expert', Icons.person_outline_rounded, '/join-expert'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title, IconData icon, String route) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      leading: Icon(icon, color: AppColors.mintTeal, size: 24),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
    );
  }
}
