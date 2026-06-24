import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/forms.dart';
import '../widgets/tars_chatbot.dart';
import '../viewmodels/app_state.dart';

class LandingView extends ConsumerStatefulWidget {
  const LandingView({super.key});

  @override
  ConsumerState<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends ConsumerState<LandingView> with SingleTickerProviderStateMixin {
  late AnimationController _marqueeController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _newsletterController = TextEditingController();
  late PageController _carouselController;
  double _carouselPage = 0.0;

  final List<Map<String, String>> carouselSlides = [
    {
      'title': 'The Problem for Companies',
      'content': 'Hiring high-level executive talent takes 4-6 months with an 18% churn rate. Traditional recruitment fails to deliver vetted leadership quickly.',
      'tag': 'COMPANIES',
    },
    {
      'title': 'The Problem for Professionals',
      'content': 'Top CXOs spend 30% of their time on business development and billing instead of delivering value. They need a frictionless platform.',
      'tag': 'PROFESSIONALS',
    },
    {
      'title': 'The Market Gap',
      'content': 'No platform bridges verified executive talent with high-growth companies under a fully managed governance layer with escrow protection.',
      'tag': 'MARKET',
    },
    {
      'title': 'Our Solution',
      'content': 'CXO Connect: AI-powered matching, PMO-governed engagements, milestone-based escrow, and a verified network of elite fractional executives.',
      'tag': 'SOLUTION',
    },
  ];

  final List<String> marqueeItems = [
    'FINTECHSCALE', 'STRATOS HEALTH', 'NEXUS ENTERPRISE', 'VERTEX LOGIC', 'FLEXPORT', 'STRIPE',
  ];

  @override
  void initState() {
    super.initState();
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
    _carouselController = PageController(viewportFraction: 0.8, initialPage: 0);
    _carouselController.addListener(() {
      setState(() {
        _carouselPage = _carouselController.page!;
      });
    });
  }

  @override
  void dispose() {
    _marqueeController.dispose();
    _scrollController.dispose();
    _newsletterController.dispose();
    _carouselController.dispose();
    super.dispose();
  }

  void _onNewsletterSubmit() {
    if (_newsletterController.text.trim().isNotEmpty) {
      Forms.showSuccessToast(context, 'Successfully subscribed to our newsletter!');
      _newsletterController.clear();
    }
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
      appBar: _buildAppBar(),
      drawer: _buildPremiumDrawer(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildHeroSection(homeKey, howItWorksKey),
                _buildMarqueeSection(),
                const SizedBox(height: 64),
                _buildBridgeSection(),
                const SizedBox(height: 80),
                _buildHowItWorksSection(howItWorksKey),
                const SizedBox(height: 80),
                _buildCarouselSection(),
                const SizedBox(height: 80),
                _buildBenefitsSection(benefitsKey),
                const SizedBox(height: 80),
                _buildContactSection(contactKey),
              ],
            ),
          ),
          _buildTarsFloatingButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
                  ),
                ],
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.outfit(
                  color: AppColors.darkBgDeep,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(GlobalKey homeKey, GlobalKey howItWorksKey) {
    return Stack(
      children: [
        Container(
          height: 600,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.darkBgDeep,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.darkBgDeep,
                AppColors.darkBgSecondary,
                AppColors.darkBgSecondary.withOpacity(0.8),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 0.8, 1.0],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.03),
                  Colors.white.withOpacity(0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6, 0.85, 1.0],
              ),
            ),
          ),
        ),
        Container(
          key: homeKey,
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: MediaQuery.of(context).padding.top + 100,
            bottom: 80.0,
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
                    text: 'Get Started',
                    onTap: () => context.push('/signin'),
                    width: 200,
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.darkBgDeep, size: 20),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      if (howItWorksKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          howItWorksKey.currentContext!,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      }
                    },
                    child: Text(
                      'Learn More',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mintTeal,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarqueeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.darkContainer,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Column(
        children: [
          Text(
            'TRUSTED BY HIGH-GROWTH FIRMS',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 24),
          MouseRegion(
            onEnter: (_) => _marqueeController.stop(),
            onExit: (_) {
              if (!_marqueeController.isAnimating) _marqueeController.repeat();
            },
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                stops: const [0.0, 0.05, 0.95, 1.0],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: AnimatedBuilder(
                animation: _marqueeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-_marqueeController.value * 1164.0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...marqueeItems.map((name) => _buildMarqueeItem(name)),
                        ...marqueeItems.map((name) => _buildMarqueeItem(name)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarqueeItem(String name) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        name,
        style: GoogleFonts.spaceGrotesk(
          color: Colors.white.withOpacity(0.3),
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 2.5,
        ),
      ),
    );
  }

  Widget _buildBridgeSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 700;
        final content = [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                    'Two-Sided Marketplace Bridge',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'We bridge verified expert talent with high-growth companies. Our platform connects elite fractional CXOs with enterprises that need top-tier leadership on demand — all under a fully managed PMO governance layer with milestone-based escrow protection.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      height: 1.7,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'For Advisors: Build your executive brand, get discovered by leading firms, and unlock high-value engagements without the administrative overhead.',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For Companies: Define your needs, get AI-matched with pre-vetted leaders in 48 hours, and onboard with full governance and compliance.',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMobile) const SizedBox(height: 24) else const SizedBox(width: 24),
          Expanded(
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [AppColors.mintTeal.withOpacity(0.15), AppColors.darkBgSecondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.groups_rounded, size: 80, color: AppColors.mintTeal.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text(
                      'Elite Consulting Team',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.darkContainer,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: isMobile
                ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content)
                : Row(crossAxisAlignment: CrossAxisAlignment.start, children: content),
          ),
        );
      },
    );
  }

  Widget _buildHowItWorksSection(GlobalKey key) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A seamless journey for both sides of the marketplace.',
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isMobile = constraints.maxWidth < 700;
              final items = [
                _buildRoleTimeline('For CXOs', [
                  ('Build Profile', 'Create your executive profile highlighting your expertise, track record, and availability preferences.'),
                  ('Get Discovered', 'Our AI matches you with relevant opportunities from verified high-growth companies.'),
                  ('Unlock Engagements', 'Accept matched engagements with fully managed milestones, escrow, and governance.'),
                ]),
                if (isMobile) const SizedBox(height: 48) else const SizedBox(width: 48),
                _buildRoleTimeline('For Companies', [
                  ('Define Needs', 'Post your requirement specifying role type, budget, duration, and key milestones.'),
                  ('Match AI', 'Receive AI-curated matches of pre-vetted executive leaders within 48 hours.'),
                  ('Onboard with Governance', 'Secure agreements via milestone-based escrow and PMO-managed delivery.'),
                ]),
              ];
              return isMobile
                  ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: items)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items.map((w) => w is SizedBox ? w : Expanded(child: w)).toList(),
                    );
            },
          ),
        ],
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
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.mintTeal,
            ),
          ),
          const SizedBox(height: 32),
          ...steps.asMap().entries.map((entry) {
            int idx = entry.key;
            var step = entry.value;
            bool isLast = idx == steps.length - 1;
            return _buildTimelineStep((idx + 1).toString(), step.$1, step.$2, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String number, String title, String desc, bool isLast) {
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
                    BoxShadow(
                      color: AppColors.mintTeal.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: AppColors.darkBgDeep,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
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
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSection() {
    return Column(
      children: [
        Text(
          'Market Voids & Solutions',
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 380,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _carouselController,
                itemCount: carouselSlides.length,
                itemBuilder: (context, index) {
                  double delta = (index - _carouselPage).clamp(-2.0, 2.0);
                  double scale = (1.0 - (delta.abs() * 0.15)).clamp(0.7, 1.0);
                  double opacity = (1.0 - (delta.abs() * 0.4)).clamp(0.2, 1.0);
                  double blur = (delta.abs() * 6.0).clamp(0.0, 6.0);
                  return _buildCarouselCard(index, scale, opacity, blur);
                },
              ),
              Positioned(
                left: 8,
                child: CircleAvatar(
                  backgroundColor: AppColors.mintTeal.withOpacity(0.8),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, color: AppColors.darkBgDeep, size: 20),
                    onPressed: () {
                      int prev = _carouselController.page!.toInt() - 1;
                      if (prev >= 0) {
                        _carouselController.animateToPage(
                          prev,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                right: 8,
                child: CircleAvatar(
                  backgroundColor: AppColors.mintTeal.withOpacity(0.8),
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, color: AppColors.darkBgDeep, size: 20),
                    onPressed: () {
                      int next = _carouselController.page!.toInt() + 1;
                      if (next < carouselSlides.length) {
                        _carouselController.animateToPage(
                          next,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            carouselSlides.length,
            (index) => Container(
              width: _carouselPage.round() == index ? 24.0 : 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _carouselPage.round() == index ? AppColors.mintTeal : Colors.white24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselCard(int index, double scale, double opacity, double blur) {
    final slide = carouselSlides[index];
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D1A18), Color(0xFF0C0F0D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.business, size: 80, color: Color(0xFF0EB59A)),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.95),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.mintTeal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.mintTeal.withOpacity(0.5)),
                        ),
                        child: Text(
                          slide['tag'] ?? 'INSIGHT',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mintTeal,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        slide['title']!,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        slide['content']!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.grey[300],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitsSection(GlobalKey key) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Membership Benefits',
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
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
                  _buildBenefitCard(
                    'Curated Matches',
                    'AI precisely matches candidate profiles to specific enterprise requirements.',
                    Icons.track_changes_outlined,
                  ),
                  _buildBenefitCard(
                    'Verified Network',
                    'Vigorously audited backgrounds, achievements, and legal checks.',
                    Icons.shield_outlined,
                  ),
                  _buildBenefitCard(
                    'PMO Governance',
                    'Standardized escrow accounts and contract systems for mutual safety.',
                    Icons.star_border,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(String title, String desc, IconData icon) {
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
          Text(
            title,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(GlobalKey key) {
    return Container(
      key: key,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CXO CONNECT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.mintTeal, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Office Headquarters: Pune, MH, India',
                        style: GoogleFonts.inter(color: Colors.white54, height: 1.6, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.email_outlined, color: AppColors.mintTeal, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'admin@cxoconnect.com',
                        style: GoogleFonts.inter(color: Colors.white54, height: 1.6, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isMobile) const SizedBox(height: 48) else const SizedBox(width: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subscribe to Insights',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
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
                            onPressed: _onNewsletterSubmit,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
          return isMobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content)
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: content);
        },
      ),
    );
  }

  Widget _buildTarsFloatingButton() {
    return Consumer(
      builder: (context, ref, child) {
        final isChatOpen = ref.watch(isChatOpenProvider);
        return Positioned(
          right: 20,
          bottom: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isChatOpen) const TarsChatbot(),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: 'tars_chat',
                backgroundColor: AppColors.mintTeal,
                onPressed: () {
                  ref.read(isChatOpenProvider.notifier).state = !isChatOpen;
                },
                child: Icon(
                  isChatOpen ? Icons.close : Icons.support_agent,
                  color: AppColors.darkBgDeep,
                ),
              ),
            ],
          ),
        );
      },
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
                  child: Text(
                    'CXO CONNECT',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 2.0,
                      color: Colors.white,
                    ),
                  ),
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
      title: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
    );
  }
}
