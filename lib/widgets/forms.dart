import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'custom_button.dart';

class Forms {
  static void showGetStartedDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundMidnight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _GetStartedForm(),
    );
  }

  static void showBecomeMemberDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundMidnight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _BecomeMemberForm(),
    );
  }

  static void showSuccessToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.backgroundDark),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: AppColors.backgroundDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _GetStartedForm extends StatefulWidget {
  const _GetStartedForm({Key? key}) : super(key: key);

  @override
  State<_GetStartedForm> createState() => _GetStartedFormState();
}

class _GetStartedFormState extends State<_GetStartedForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Get Started',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Connect with our enterprise matching team to scope and hire your elite executive support.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Your Name',
                hintText: 'Sarah Jenkins',
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Work Email',
                hintText: 'sarah@stripe.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Company / Organization',
                hintText: 'Stripe',
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your company name' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Executive Need'),
              dropdownColor: AppColors.backgroundMidnight,
              items: const [
                DropdownMenuItem(value: 'cto', child: Text('Fractional/Interim CTO')),
                DropdownMenuItem(value: 'cfo', child: Text('Fractional/Interim CFO')),
                DropdownMenuItem(value: 'cmo', child: Text('Fractional/Interim CMO')),
                DropdownMenuItem(value: 'coo', child: Text('Fractional/Interim COO')),
                DropdownMenuItem(value: 'board', child: Text('Board Member / Advisory')),
              ],
              onChanged: (_) {},
              validator: (val) => val == null ? 'Please select an option' : null,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Submit Request',
              isLoading: _isLoading,
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(milliseconds: 1500));
                  setState(() => _isLoading = false);
                  if (mounted) {
                    Navigator.pop(context);
                    Forms.showSuccessToast(
                      context,
                      'Request submitted! Our advisors will reach out in 24 hours.',
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
  }
}

class _BecomeMemberForm extends StatefulWidget {
  const _BecomeMemberForm({Key? key}) : super(key: key);

  @override
  State<_BecomeMemberForm> createState() => _BecomeMemberFormState();
}

class _BecomeMemberFormState extends State<_BecomeMemberForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Apply for Membership',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Join our elite network of verified CXOs, board members, and senior corporate advisors.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Dave Kincaid',
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Primary Focus / Expertise',
                hintText: 'SaaS scaling, Payment architectures, M&A operations',
              ),
              validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your core expertise' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'LinkedIn Profile URL',
                hintText: 'https://linkedin.com/in/davek',
              ),
              keyboardType: TextInputType.url,
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter LinkedIn URL';
                if (!val.contains('linkedin.com')) return 'Please provide a valid LinkedIn URL';
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Submit Application',
              isLoading: _isLoading,
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isLoading = true);
                  await Future.delayed(const Duration(milliseconds: 1500));
                  setState(() => _isLoading = false);
                  if (mounted) {
                    Navigator.pop(context);
                    Forms.showSuccessToast(
                      context,
                      'Application received! Our vetting team will review your profile shortly.',
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
  }
}
