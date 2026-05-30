import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/app_state.dart';
import 'forms.dart';
import '../views/expert_onboarding_view.dart';

enum LoginMethod { otp, magicLink }

class ExpertSignInDialog extends ConsumerStatefulWidget {
  const ExpertSignInDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => const Center(
        child: SingleChildScrollView(
          child: ExpertSignInDialog(),
        ),
      ),
    );
  }

  @override
  ConsumerState<ExpertSignInDialog> createState() => _ExpertSignInDialogState();
}

class _ExpertSignInDialogState extends ConsumerState<ExpertSignInDialog> {
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  
  LoginMethod _loginMethod = LoginMethod.otp;
  bool _otpSent = false;
  bool _isSending = false;
  bool _isVerifying = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_emailFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isSending = true;
      });

      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 1200));

      setState(() {
        _isSending = false;
        if (_loginMethod == LoginMethod.otp) {
          _otpSent = true;
        } else {
          // Magic link login simulation
          _otpSent = false;
        }
      });

      if (mounted) {
        if (_loginMethod == LoginMethod.otp) {
          Forms.showSuccessToast(context, 'OTP sent to ${_emailController.text.trim()}');
        } else {
          // Complete login for Magic Link
          ref.read(userRoleProvider.notifier).state = UserRole.expert;
          Navigator.pop(context); // Close dialog
          Forms.showSuccessToast(context, 'Magic Link sent! Authenticated successfully.');
          ref.read(tabNavigationProvider.notifier).setTab(3); // Go to Profile
        }
      }
    }
  }

  Future<void> _handleVerifyAndSignIn() async {
    if (_otpFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isVerifying = true;
      });

      // Simulate verification check
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _isVerifying = false;
      });

      if (mounted) {
        // Set user role to expert
        ref.read(userRoleProvider.notifier).state = UserRole.expert;
        Navigator.pop(context); // Close sign-in dialog
        Forms.showSuccessToast(context, 'Welcome back, Executive Advisor! Authenticated.');
        
        // Go to Profile Dashboard
        ref.read(tabNavigationProvider.notifier).setTab(3);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white, // Pristine white card matching mockup
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 32,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Close Action button on top right
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ),

            // Login exit/entry rounded icon header in white circle
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.login_rounded,
                  color: Color(0xFF0F9F80), // Premium Green/Teal accent
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header titles
            Text(
              _otpSent ? 'Enter OTP Code' : 'Sign In as Expert',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _otpSent
                  ? 'Verify authentication code to continue'
                  : 'Enter your registered email',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),

            // Form Content based on state
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _otpSent ? _buildOtpForm() : _buildEmailForm(),
            ),
            const SizedBox(height: 24),

            // Divider Or sign in with
            Row(
              children: [
                Expanded(child: Divider(color: const Color(0xFFE2E8F0), thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Or sign in with',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: const Color(0xFFE2E8F0), thickness: 1)),
              ],
            ),
            const SizedBox(height: 20),

            // Rounded Social row icons (Google, LinkedIn, X)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialButton(
                  icon: const GoogleLogo(size: 24),
                ),
                const SizedBox(width: 14),
                _buildSocialButton(
                  icon: const LinkedInLogo(size: 24),
                ),
                const SizedBox(width: 14),
                _buildSocialButton(
                  icon: const XLogo(size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Redirection footer to onboarding
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New here? ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close sign-in dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExpertOnboardingView()),
                    );
                  },
                  child: Text(
                    'Join as Expert',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F9F80), // Green accent color
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // First View: Enter Email + Login Method Select
  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        key: const ValueKey('email_form'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Text Input box
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC), // Off-white field background
              prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF94A3B8), size: 18),
              hintText: 'Email',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0F9F80), width: 1.5),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter email';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Login Method Selector Header
          Center(
            child: Text(
              'Login Method',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Radio Selection Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRadioOption(
                  label: 'OTP',
                  value: LoginMethod.otp,
                ),
                _buildRadioOption(
                  label: 'Magic Link',
                  value: LoginMethod.magicLink,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Primary teal button "SEND OTP" or "SEND MAGIC LINK"
          GestureDetector(
            onTap: _isSending ? null : _handleSend,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0F9F80), // Rich teal color
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F9F80).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _loginMethod == LoginMethod.otp ? 'SEND OTP' : 'SEND MAGIC LINK',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Radio button helper
  Widget _buildRadioOption({
    required String label,
    required LoginMethod value,
  }) {
    final bool isSelected = _loginMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _loginMethod = value;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF0F9F80) : const Color(0xFF94A3B8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0F9F80),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.black : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Second View: Enter OTP Code
  Widget _buildOtpForm() {
    return Form(
      key: _otpFormKey,
      child: Column(
        key: const ValueKey('otp_form'),
        children: [
          // OTP text field
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.inter(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 18),
              hintText: 'Enter 6-digit OTP',
              hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF0F9F80), width: 1.5),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter OTP';
              if (val.trim().length < 4) return 'OTP must be at least 4 digits';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Primary verify button
          GestureDetector(
            onTap: _isVerifying ? null : _handleVerifyAndSignIn,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0F9F80),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F9F80).withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'VERIFY & SIGN IN',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Social Login rounded button helper
  Widget _buildSocialButton({required Widget icon}) {
    return Container(
      width: 72,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            ref.read(userRoleProvider.notifier).state = UserRole.expert;
            Navigator.pop(context);
            Forms.showSuccessToast(context, 'Social sign-in successful!');
            ref.read(tabNavigationProvider.notifier).setTab(3);
          },
          child: Center(child: icon),
        ),
      ),
    );
  }
}

// ==========================================
// High-Fidelity Custom Social Logos (Shared)
// ==========================================

class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: GoogleLogoPainter(),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22
      ..strokeCap = StrokeCap.square;

    final rect = Rect.fromLTWH(w * 0.11, h * 0.11, w * 0.78, h * 0.78);
    
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.4, 1.4, false, paint);
    
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -3.7, 1.3, false, paint);
    
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.4, 1.6, false, paint);
    
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.8, 1.2, false, paint);
    
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(w * 0.5, h * 0.39, w * 0.39, h * 0.22),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LinkedInLogo extends StatelessWidget {
  final double size;
  const LinkedInLogo({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0077B5),
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      alignment: Alignment.center,
      child: Text(
        'in',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: size * 0.62,
          fontWeight: FontWeight.w800,
          height: 0.95,
        ),
      ),
    );
  }
}

class XLogo extends StatelessWidget {
  final double size;
  const XLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Text(
      '𝕏',
      style: GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}
