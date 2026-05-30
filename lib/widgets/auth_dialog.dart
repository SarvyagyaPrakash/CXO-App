import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../viewmodels/app_state.dart';
import 'forms.dart';
import '../views/company_onboarding_view.dart';
import '../views/expert_onboarding_view.dart';
import 'company_sign_in_dialog.dart';
import 'expert_sign_in_dialog.dart';



class AuthDialog extends ConsumerWidget {
  const AuthDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (context) => const Center(
        child: SingleChildScrollView(
          child: AuthDialog(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close Button Top Right
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // --- SECTION 1: FIRST TIME ---
            Text(
              'First time to this website?',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create a new account to get started.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Green Button 1: Join as a company
            _buildGreenButton(
              context: context,
              ref: ref,
              label: 'Join as a company',
              role: UserRole.company,
              successMsg: 'Company registration successful! PMO matching active.',
            ),
            const SizedBox(height: 12),

            // Green Button 2: Join as an expert
            _buildGreenButton(
              context: context,
              ref: ref,
              label: 'Join as an expert',
              role: UserRole.expert,
              successMsg: 'Expert application submitted! Vetting panel unlocked.',
            ),
            const SizedBox(height: 24),

            // Divider Line
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 24),

            // --- SECTION 2: ALREADY A MEMBER ---
            Text(
              'Already a member?',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Welcome back! Please log in.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Outline Button 1: Already a company
            _buildDarkButton(
              context: context,
              ref: ref,
              label: 'Already a company',
              role: UserRole.company,
              successMsg: 'Welcome back, Enterprise Partner! Loading active scopes.',
            ),
            const SizedBox(height: 12),

            // Outline Button 2: Already an expert
            _buildDarkButton(
              context: context,
              ref: ref,
              label: 'Already an expert',
              role: UserRole.expert,
              successMsg: 'Welcome back, Executive Advisor! Loading matching metrics.',
            ),
            const SizedBox(height: 28),

            // Spaced Footer Text
            Text(
              'SECURE EXECUTIVE GATEWAY',
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreenButton({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required UserRole role,
    required String successMsg,
  }) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: AppColors.tealGradient,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (role == UserRole.company) {
              Navigator.pop(context); // Pop auth dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompanyOnboardingView()),
              );
            } else if (role == UserRole.expert) {
              Navigator.pop(context); // Pop auth dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExpertOnboardingView()),
              );
            } else {
              ref.read(userRoleProvider.notifier).state = role;
              Navigator.pop(context);
              Forms.showSuccessToast(context, successMsg);
              ref.read(tabNavigationProvider.notifier).setTab(1); // Go to Projects
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 8), // For centering offsets
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.backgroundDark,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.backgroundDark,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDarkButton({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required UserRole role,
    required String successMsg,
  }) {
    return Container(
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
            if (label == 'Already a company') {
              Navigator.pop(context); // Close the current AuthDialog
              CompanySignInDialog.show(context);
              return;
            }
            if (label == 'Already an expert') {
              Navigator.pop(context); // Close the current AuthDialog
              ExpertSignInDialog.show(context);
              return;
            }
            ref.read(userRoleProvider.notifier).state = role;
            Navigator.pop(context);
            Forms.showSuccessToast(context, successMsg);
            // Redirect
            if (role == UserRole.expert) {
              ref.read(tabNavigationProvider.notifier).setTab(3); // Profile
            } else {
              ref.read(tabNavigationProvider.notifier).setTab(1); // Projects
            }
          },
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
