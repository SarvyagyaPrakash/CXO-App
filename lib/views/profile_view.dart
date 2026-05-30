import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/forms.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundMidnight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1.5),
            ),
            child: Column(
              children: [
                // Avatar with border
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryTeal, width: 2.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=400',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.cardBorder,
                        child: const Icon(Icons.person, color: AppColors.textSecondary, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name and Vetted Role
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Dave Kincaid',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: AppColors.primaryTeal, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Scaleup COO & PMO Advisor',
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Premium Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTealDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
                  ),
                  child: Text(
                    'PLATINUM MEMBER',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTeal,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Key Metrics Grid
          Text(
            'Performance Metrics',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: [
              _buildMetricCard('Match Rate', '98.4%', Icons.check_circle_outline),
              _buildMetricCard('Intros Made', '14 Active', Icons.people_outline),
              _buildMetricCard('Vetting Status', 'Passed', Icons.verified_user_outlined),
              _buildMetricCard('Review Rating', '4.97 / 5', Icons.star_outline),
            ],
          ),
          const SizedBox(height: 28),

          // Matching Preference Controls
          Text(
            'Matching Preferences',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.backgroundMidnight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder, width: 1.0),
            ),
            child: Column(
              children: [
                _buildPreferenceRow('Target Industries', 'B2B SaaS, Logistics, EdTech'),
                const Divider(color: AppColors.cardBorder, height: 24),
                _buildPreferenceRow('Core Mandate', 'Fractional COO / OKR Scaling'),
                const Divider(color: AppColors.cardBorder, height: 24),
                _buildPreferenceRow('Target Compensation', '\$150 - \$220 / hr'),
                const Divider(color: AppColors.cardBorder, height: 24),
                _buildPreferenceRow('Weekly Capacity', '15 - 20 hours'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Log Out / Reset Options
          CustomButton(
            text: 'Update Vetting Profile',
            onTap: () {
              Forms.showSuccessToast(
                context,
                'Entering secure background verification credentials updates...',
              );
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundMidnight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(icon, color: AppColors.primaryTeal, size: 16),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: Alignment.centerRight.x > 0 ? TextAlign.right : TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
