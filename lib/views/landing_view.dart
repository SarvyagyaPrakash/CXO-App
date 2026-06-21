import 'dart:math';
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
      duration: const Duration(seconds: 10),
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
      appBar: AppBar(
        backgroundColor: AppColors.darkBgSecondary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.mintTeal),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'CXO CONNECT',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/signin'),
            child: const Text('Sign In', style: TextStyle(color: AppColors.mintTeal)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        backgroundColor: AppColors.darkBgSecondary,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                child: Text('CXO CONNECT', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const Divider(color: AppColors.darkBorder),
              ListTile(
                title: const Text('Find Experts'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/experts');
                },
              ),
              ListTile(
                title: const Text('Post a Requirement'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/requirements/create');
                },
              ),
              ListTile(
                title: const Text('Join as Company'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/join-company');
                },
              ),
              ListTile(
                title: const Text('Join as Expert'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/join-expert');
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Hero Section with Animated Overlay simulating video
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Container(
                  key: homeKey,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 64.0),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(
                        0.3 * cos(_animController.value * 2 * pi),
                        0.3 * sin(_animController.value * 2 * pi),
                      ),
                      radius: 1.2,
                      colors: const [
                        AppColors.darkBgSecondary,
                        AppColors.darkBgDeep,
                      ],
                    ),
                  ),
                  child: child,
                );
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2D25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.mintTeal.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'PREMIUM EXECUTIVE NETWORK',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mintTeal,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Elite Expertise.\nLeadership on Demand.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bridging the gap between visionary hiring firms and elite fractional executives under a managed PMO governance layer.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      color: AppColors.darkTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        text: 'Get Started Gateway',
                        onTap: () => context.push('/signin'),
                        width: 200,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Trusted partners marquee
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              color: AppColors.darkContainer,
              child: Column(
                children: [
                  Text(
                    'TRUSTED BY HIGH-GROWTH FIRMS',
                    style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.darkTextSecondary, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['FintechScale', 'Stratos Health', 'Nexus Enterprise', 'Vertex Logic', 'Flexport', 'Stripe']
                          .map((n) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  n.toUpperCase(),
                                  style: GoogleFonts.spaceGrotesk(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.5),
                                ),
                              ))
                          .toList(),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Two-sided Marketplace Bridge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                color: AppColors.darkContainer,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'The Bridge to Elite Leadership',
                              style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'We align enterprise challenges with certified independent CFOs, CTOs, CMOs, and COOs. Powered by secure escrow deposits and active project milestones, ensuring risk-free elite collaboration.',
                              style: TextStyle(color: AppColors.darkTextSecondary, height: 1.5, fontSize: 13.5),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // How it works split timeline
            Padding(
              key: howItWorksKey,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text('How It Works', style: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      final List<Widget> items = [
                        Column(
                          children: [
                            Text('For Companies', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.mintTeal)),
                            const SizedBox(height: 16),
                            _buildTimelineStep('1', 'Define Business Needs', 'Post requirements indicating role type, budget, and key milestones.'),
                            _buildTimelineStep('2', 'AI & PMO Matching', 'Get curated matches of verified executive leaders in under 48 hours.'),
                            _buildTimelineStep('3', 'Deploy & Escrow Fund', 'Secure agreements via milestone-based escrow payments.'),
                          ],
                        ),
                        if (isMobile) const SizedBox(height: 32) else const SizedBox(width: 24),
                        Column(
                          children: [
                            Text('For Advisors', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.mintTeal)),
                            const SizedBox(height: 16),
                            _buildTimelineStep('1', 'Submit Credentials', 'Apply by linking your verified professional ex-roles and portfolio.'),
                            _buildTimelineStep('2', 'Pass Vetting Panel', 'Our PMO board audits credentials to ensure quality standards.'),
                            _buildTimelineStep('3', 'Unlock Engagements', 'Access matching scopes with fully managed milestones.'),
                          ],
                        ),
                      ];

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: items,
                        );
                      } else {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: items.map((w) {
                            if (w is Column) return Expanded(child: w);
                            return w;
                          }).toList(),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Problem Carousel
            Text('Market Voids & Solutions', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            SlidingProblemCarousel(slides: problemSlides),
            const SizedBox(height: 48),

            // Benefits Grid
            Padding(
              key: benefitsKey,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text('Membership Benefits', style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isMobile = constraints.maxWidth < 600;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: isMobile ? 1 : 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isMobile ? 3.0 : 1.3,
                        children: [
                          _buildBenefitCard('Curated Matches', 'AI matches candidate profiles to specific requirements.', Icons.hub_outlined),
                          _buildBenefitCard('Verified Network', 'Vigorously audited backgrounds and legal checks.', Icons.shield_outlined),
                          _buildBenefitCard('PMO Governance', 'Standardized escrow accounts and contract systems.', Icons.star_border),
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Contact & Newsletter Section
            Container(
              key: contactKey,
              color: AppColors.darkContainer,
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Connect with Us', style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        const Text('Headquarters: Pune, MH, India\nSupport: admin@cxoconnect.com', style: TextStyle(color: AppColors.darkTextSecondary, height: 1.5)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Subscribe to Newsletter', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _newsletterController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter email...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.arrow_forward, color: AppColors.mintTeal),
                              onPressed: () {
                                if (_newsletterController.text.trim().isNotEmpty) {
                                  Forms.showSuccessToast(context, 'Successfully subscribed to our newsletter!');
                                  _newsletterController.clear();
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String step, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.mintTeal,
            radius: 12,
            child: Text(step, style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.5)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBenefitCard(String title, String desc, IconData icon) {
    return Card(
      color: AppColors.darkBgSecondary,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: AppColors.mintTeal, size: 24),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(desc, style: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
