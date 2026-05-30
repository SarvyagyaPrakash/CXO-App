import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'custom_button.dart';

class ValuePropCard extends StatelessWidget {
  final VoidCallback onExploreEngagements;

  const ValuePropCard({
    Key? key,
    required this.onExploreEngagements,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundMidnight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars and Trusted Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 5 Stars
              Row(
                children: List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(
                      Icons.star,
                      color: AppColors.primaryTeal,
                      size: 16,
                    ),
                  ),
                ),
              ),
              // Trusted Badge
              Text(
                'TRUSTED PLATFORM',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Headline
          Text(
            'The premier two-sided\nmarketplace.',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 22,
                  height: 1.3,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Subtext
          Text(
            'CXOConnect bridges the gap between:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 16),

          // Checklist Items
          _buildCheckItem(
            context,
            'Companies seeking impactful leadership.',
          ),
          const SizedBox(height: 12),
          _buildCheckItem(
            context,
            'Senior Professionals seeking flexible engagements.',
          ),
          const SizedBox(height: 24),

          // Highlighted Blockquote Callout
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.primaryTeal, width: 3),
              ),
              color: AppColors.primaryTealDark,
            ),
            child: Text(
              'Supported by an expert Admin layer to ensure trust, meticulous vetting, and seamless managed delivery.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button: "Explore Engagements >"
          CustomButton(
            text: 'Explore Engagements',
            type: ButtonType.text,
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.textPrimary,
              size: 18,
            ),
            onTap: onExploreEngagements,
            width: double.infinity,
          ),
          const SizedBox(height: 24),

          // Corporate Executive Headshot Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?q=80&w=600',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback elegant placeholder in case of offline testing
                return Container(
                  width: double.infinity,
                  height: 220,
                  color: AppColors.cardBackground,
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.primaryTeal,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2.0),
          child: Icon(
            Icons.check_circle_outline,
            color: AppColors.primaryTeal,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: text.split(' ')[0] + ' ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: text.substring(text.indexOf(' ') + 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
