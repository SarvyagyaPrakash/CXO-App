import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../viewmodels/app_state.dart';
import '../models/advisor_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/forms.dart';

class NetworkView extends ConsumerWidget {
  const NetworkView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController(text: ref.watch(advisorSearchProvider));
    final advisors = ref.watch(filteredAdvisorsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vetted Executive Network',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connect with verified former enterprise leaders and specialist advisors.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  controller: searchController,
                  onChanged: (val) {
                    ref.read(advisorSearchProvider.notifier).setSearch(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search advisors by name, skill, or industry...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.textMuted),
                            onPressed: () {
                              searchController.clear();
                              ref.read(advisorSearchProvider.notifier).setSearch('');
                            },
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // Advisor List
          Expanded(
            child: advisors.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: advisors.length,
                    itemBuilder: (context, index) {
                      return _AdvisorCard(advisor: advisors[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            'No Advisors Found',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try searching for core keywords like "CTO" or "Growth".',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvisorCard extends ConsumerWidget {
  final AdvisorModel advisor;

  const _AdvisorCard({required this.advisor, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final introRequests = ref.watch(introductionRequestsProvider);
    final isPending = introRequests.contains(advisor.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar, Name, Vetting Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rounded Avatar with border
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryTeal, width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Image.network(
                      advisor.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.cardBorder,
                        child: const Icon(Icons.person, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name and Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              advisor.name,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (advisor.isVetted)
                            const Icon(
                              Icons.verified,
                              color: AppColors.primaryTeal,
                              size: 16,
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        advisor.role,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Info row: rating and experience
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.primaryTeal, size: 16),
                const SizedBox(width: 4),
                Text(
                  advisor.rating.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.history, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${advisor.yearsOfExperience} Years Exp',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.place_outlined, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 4),
                Text(
                  advisor.location,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Biography
            Text(
              advisor.biography,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),

            // Skills Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: advisor.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlueDark,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.accentBlue,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Request Intro / Application Action
            CustomButton(
              text: isPending ? 'Introduction Request Pending' : 'Request Private Introduction',
              type: isPending ? ButtonType.text : ButtonType.filled,
              height: 40,
              onTap: isPending
                  ? () {}
                  : () {
                      _showIntroModal(context, ref);
                    },
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  void _showIntroModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundMidnight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request Introduction',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'With ${advisor.name}',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: AppColors.primaryTeal,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Your Business / Company Name',
                        hintText: 'Stripe, Inc.',
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter company name' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Objective of Engagement',
                        hintText: 'e.g. Seeking high-level cloud migration architecture advisory',
                      ),
                      maxLines: 3,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Please enter objective' : null,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Introduction Match Request',
                      isLoading: isSubmitting,
                      onTap: () async {
                        if (formKey.currentState!.validate()) {
                          setModalState(() => isSubmitting = true);
                          await Future.delayed(const Duration(milliseconds: 1500));
                          setModalState(() => isSubmitting = false);
                          // Mark as requested in Riverpod state
                          ref.read(introductionRequestsProvider.notifier).requestIntroduction(advisor.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            Forms.showSuccessToast(
                              context,
                              'Match request sent! Our PMO team is reviewing details and will configure the intro bridge.',
                            );
                          }
                        }
                      },
                      width: double.infinity,
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
