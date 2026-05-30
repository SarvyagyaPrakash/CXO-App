import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/value_prop_card.dart';
import '../widgets/benefit_card.dart';
import '../widgets/auth_dialog.dart';
import '../viewmodels/app_state.dart';

class LandingView extends ConsumerWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reading global scroll keys from centralized providers
    final homeKey = ref.watch(homeKeyProvider);
    final howItWorksKey = ref.watch(howItWorksKeyProvider);
    final benefitsKey = ref.watch(benefitsKeyProvider);
    final contactKey = ref.watch(contactKeyProvider);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Hero Section
          Container(
            key: homeKey, // Scroll Anchor: Home
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            decoration: const BoxDecoration(
              gradient: AppColors.darkHeroGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Premium Network Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTealDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryTeal.withOpacity(0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    'PREMIUM NETWORK',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTeal,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Main Heading
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 32,
                          height: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                    children: const [
                      TextSpan(text: 'Elite Expertise.\n'),
                      TextSpan(
                        text: 'Leadership on Demand.',
                        style: TextStyle(color: AppColors.primaryTeal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Connect with vetted CXOs and senior advisors to solve your most critical business challenges on-demand and managed by experts.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14.5,
                          height: 1.5,
                        ),
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                CustomButton(
                  text: 'Get Started',
                  icon: const Icon(Icons.arrow_forward, color: AppColors.backgroundDark, size: 16),
                  onTap: () => AuthDialog.show(context), // Triggers Gateway Auth card
                  width: double.infinity,
                ),
                const SizedBox(height: 14),
                CustomButton(
                  text: 'Learn More',
                  type: ButtonType.text,
                  onTap: () {
                    // Smoothly scrolls to benefits
                    final ctx = benefitsKey.currentContext;
                    if (ctx != null) {
                      Scrollable.ensureVisible(
                        ctx,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  width: double.infinity,
                ),
              ],
            ),
          ),

          // Trusted By Industry Leaders Logos
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            color: const Color(0xFF070B1B),
            child: Column(
              children: [
                Text(
                  'TRUSTED BY INDUSTRY LEADERS',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 32,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: const [
                    _MockLogoText(text: 'CORP ONE'),
                    _MockLogoText(text: 'STRATOS'),
                    _MockLogoText(text: 'NEXUS'),
                    _MockLogoText(text: 'VERTEX'),
                  ],
                ),
              ],
            ),
          ),

          // Two-Sided Marketplace Value Card
          Padding(
            key: howItWorksKey, // Scroll Anchor: How it Works
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 48.0),
            child: ValuePropCard(
              onExploreEngagements: () {
                final currentRole = ref.read(userRoleProvider);
                if (currentRole == UserRole.guest) {
                  AuthDialog.show(context);
                } else {
                  // Switches seamlessly to Projects view
                  ref.read(tabNavigationProvider.notifier).setTab(1);
                }
              },
            ),
          ),

          // Membership Benefits Title
          Padding(
            key: benefitsKey, // Scroll Anchor: Membership Benefits
            padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
            child: Column(
              children: [
                Text(
                  'Membership benefits',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join a curated community of top-tier executives.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3 Benefit Cards List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: const [
                BenefitCard(
                  icon: Icons.hub_outlined,
                  title: 'Curated Matches',
                  description: 'AI-driven matching ensures you connect with the exact expertise or role you\'re looking for.',
                ),
                SizedBox(height: 16),
                BenefitCard(
                  icon: Icons.shield_outlined,
                  title: 'Verified Network',
                  description: 'Every member undergoes rigorous vetting to ensure a high-trust environment.',
                ),
                SizedBox(height: 16),
                BenefitCard(
                  icon: Icons.gavel_outlined,
                  title: 'PMO Governance',
                  description: 'Dedicated support with structured milestones, escrow, and project success oversight.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Become a Member Outline Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: CustomButton(
              text: 'Become a Member',
              type: ButtonType.outline,
              icon: const Icon(Icons.chevron_right, color: AppColors.primaryTeal, size: 18),
              onTap: () => AuthDialog.show(context), // Triggers Gateway Auth card
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 48),

          // Let's Build the Future Section (Contact Us)
          Container(
            key: contactKey, // Scroll Anchor: Contact Us
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            color: const Color(0xFF0F1626),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    children: const [
                      TextSpan(text: 'Let\'s build the '),
                      TextSpan(
                        text: 'future.',
                        style: TextStyle(
                          color: AppColors.primaryTeal,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ready to transform your leadership model? Reach out to our advisors.',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),

                // Location Card
                _buildInfoCard(
                  context,
                  icon: Icons.location_on_outlined,
                  title: 'HEADQUARTERS',
                  value: 'Pune, MH, India',
                ),
                const SizedBox(height: 14),

                // Mail Card
                _buildInfoCard(
                  context,
                  icon: Icons.mail_outline,
                  title: 'DIRECT LINE',
                  value: 'admin@cxoconnect.com',
                ),
                const SizedBox(height: 24),

                // Get Updates Action Button
                CustomButton(
                  text: 'Get Updates',
                  icon: const Icon(Icons.chevron_right, color: AppColors.backgroundDark, size: 18),
                  onTap: () {
                    ref.read(isChatOpenProvider.notifier).state = true; // Opens TARS chatbot as support briefing
                  },
                  width: double.infinity,
                ),
              ],
            ),
          ),

          // Footer Info Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            color: const Color(0xFF080C16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CXO CONNECT',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Open chatbot
                        ref.read(isChatOpenProvider.notifier).state = true;
                      },
                      icon: const Icon(Icons.language, color: AppColors.textSecondary, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Bridging the gap between visionary companies and elite leaders.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(color: AppColors.cardBorder, height: 1),
                const SizedBox(height: 24),
                Text(
                  '© 2026 CXO CONNECT. DESIGNED FOR PRECISION.',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context,
      {required IconData icon, required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockLogoText extends StatelessWidget {
  final String text;

  const _MockLogoText({required this.text, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
