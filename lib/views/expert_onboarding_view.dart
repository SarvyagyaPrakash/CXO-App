import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/forms.dart';

class ExpertOnboardingView extends ConsumerStatefulWidget {
  const ExpertOnboardingView({super.key});

  @override
  ConsumerState<ExpertOnboardingView> createState() => _ExpertOnboardingViewState();
}

class _ExpertOnboardingViewState extends ConsumerState<ExpertOnboardingView> {
  int _currentStep = 1;
  final int _totalSteps = 4;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _headlineController = TextEditingController();

  String? _selectedYearsOfExperience;
  final _currentRoleController = TextEditingController();
  final List<String> _keySkills = [];

  String? _uploadedCvPath;
  bool _isUploadingCv = false;
  final _portfolioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isOtpVerifying = false;
  bool _isOtpVerified = false;

  final _rateController = TextEditingController();
  String? _selectedCommitmentLevel;
  bool _agreeToTerms = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _headlineController.dispose();
    _currentRoleController.dispose();
    _portfolioController.dispose();
    _linkedinController.dispose();
    _otpController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _step1Key.currentState?.validate() ?? false;
      case 2:
        if (_step2Key.currentState?.validate() ?? false) {
          if (_selectedYearsOfExperience == null) {
            Forms.showErrorToast(context, 'Please select years of experience.');
            return false;
          }
          return true;
        }
        return false;
      case 3:
        if (_step3Key.currentState?.validate() ?? false) {
          if (_uploadedCvPath == null) {
            Forms.showErrorToast(context, 'Please upload your CV.');
            return false;
          }
          if (!_isOtpVerified) {
            Forms.showErrorToast(context, 'Please verify your email OTP.');
            return false;
          }
          return true;
        }
        return false;
      case 4:
        if (_step4Key.currentState?.validate() ?? false) {
          if (!_agreeToTerms) {
            Forms.showErrorToast(context, 'You must agree to the terms of service.');
            return false;
          }
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < _totalSteps) {
        setState(() {
          _currentStep++;
        });
      } else {
        _submitOnboarding();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      context.go('/signin');
    }
  }

  Future<void> _simulateCvUpload() async {
    setState(() {
      _isUploadingCv = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _uploadedCvPath = 'cv_sarah_jenkins.pdf';
      _isUploadingCv = false;
    });
  }

  Future<void> _simulateOtpVerification() async {
    if (_otpController.text.trim().isEmpty) {
      Forms.showErrorToast(context, 'Please enter the OTP sent to your email.');
      return;
    }
    setState(() {
      _isOtpVerifying = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isOtpVerified = true;
      _isOtpVerifying = false;
    });
    if (mounted) {
      Forms.showSuccessToast(context, 'Email verified successfully!');
    }
  }

  void _addSkill() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMidnight,
        title: Text('Add Skill', style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g. Financial Modeling'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryTeal),
            child: const Text('Add', style: TextStyle(color: AppColors.backgroundDark)),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _keySkills.add(controller.text.trim());
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Row(
        children: [
          _buildLeftPanel(),
          _buildRightPanel(),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.38,
      decoration: const BoxDecoration(
        gradient: AppColors.darkHeroGradient,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryTeal),
                onPressed: _prevStep,
              ),
              const Spacer(),
              Text(
                'Join as an\nExpert',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Complete your profile to join our elite network of verified executives and advisors.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    double progressPercent = _currentStep / _totalSteps;
    return Expanded(
      child: Column(
        children: [
          _buildProgressIndicatorHeader(progressPercent),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepForm(),
              ),
            ),
          ),
          _buildStickyFooter(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicatorHeader(double progressPercent) {
    String stepTitle = '';
    switch (_currentStep) {
      case 1:
        stepTitle = 'Basic Profile Info';
        break;
      case 2:
        stepTitle = 'Professional Experience';
        break;
      case 3:
        stepTitle = 'Validation & Verification';
        break;
      case 4:
        stepTitle = 'Agreement';
        break;
    }

    return Container(
      color: AppColors.backgroundMidnight,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of $_totalSteps: $stepTitle',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${(progressPercent * 100).toInt()}% Complete',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progressPercent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.tealGradient,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (index) {
              int stepNum = index + 1;
              bool isCompleted = stepNum < _currentStep;
              bool isActive = stepNum == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primaryTeal.withOpacity(0.1)
                            : (isActive ? AppColors.primaryTealDark : AppColors.backgroundDark),
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.primaryTeal
                              : (isActive ? AppColors.primaryTeal : AppColors.cardBorder),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: AppColors.primaryTeal, size: 14)
                            : Text(
                                '$stepNum',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? AppColors.primaryTeal
                                      : AppColors.textMuted,
                                ),
                              ),
                      ),
                    ),
                    if (stepNum < _totalSteps)
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: isCompleted ? AppColors.primaryTeal : AppColors.cardBorder,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepForm() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Form();
      case 2:
        return _buildStep2Form();
      case 3:
        return _buildStep3Form();
      case 4:
        return _buildStep4Form();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Form() {
    return Form(
      key: _step1Key,
      child: Column(
        key: const ValueKey('step_1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Profile Info',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Provide your foundational credentials to build your premium advisor profile.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Full Name',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'e.g. Sarah Jenkins'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 20),
          Text(
            'Contact Email',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _contactEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'expert@domain.com'),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter your email';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Contact Phone',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _contactPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: '+1 555 123 4567'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your phone number' : null,
          ),
          const SizedBox(height: 20),
          Text(
            'Headline',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _headlineController,
            decoration: const InputDecoration(hintText: 'e.g. Former VP of Technology at Nexus Group'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a headline' : null,
          ),
          const SizedBox(height: 28),
          _buildInfoBanner(
            icon: Icons.info_outline,
            text: 'Your profile information is used to match you with the right corporate partners.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Form() {
    return Form(
      key: _step2Key,
      child: Column(
        key: const ValueKey('step_2'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Experience',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Provide details about your professional background to help us verify your expertise.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Years of Experience',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedYearsOfExperience,
            hint: Text('Select duration', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            items: ['5-10 years', '10-15 years', '15-20 years', '20+ years']
                .map((duration) => DropdownMenuItem(
                      value: duration,
                      child: Text(duration, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedYearsOfExperience = val;
              });
            },
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
          ),
          const SizedBox(height: 20),
          Text(
            'Current Role',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _currentRoleController,
            decoration: const InputDecoration(hintText: 'e.g. Senior Strategic Advisor'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your current role' : null,
          ),
          const SizedBox(height: 20),
          Text(
            'Key Skills',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Add your core competencies and expertise areas.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._keySkills.map((skill) => Chip(
                    label: Text(
                      skill,
                      style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: AppColors.cardBackground,
                    deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                    onDeleted: () {
                      setState(() {
                        _keySkills.remove(skill);
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                  )),
              GestureDetector(
                onTap: _addSkill,
                child: Chip(
                  avatar: const Icon(Icons.add, size: 14, color: AppColors.primaryTeal),
                  label: Text(
                    'Add Skill',
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                  backgroundColor: AppColors.primaryTealDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.primaryTeal, width: 1.0, style: BorderStyle.solid),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoBanner(
            icon: Icons.lightbulb_outline,
            text: 'Pro Tip: Experts with detailed skill profiles have a 40% higher match rate with premium corporate clients.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Form() {
    return Form(
      key: _step3Key,
      child: Column(
        key: const ValueKey('step_3'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validation & Verification',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Upload your CV and verify your identity to complete the vetting process.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'CV Upload',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _isUploadingCv ? null : _simulateCvUpload,
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.backgroundMidnight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1.5, style: BorderStyle.solid),
              ),
              child: _isUploadingCv
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
                  : _uploadedCvPath != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                _uploadedCvPath!,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tap to re-upload',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryTeal, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'Click to upload CV',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PDF, DOC up to 10MB',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Portfolio Link',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _portfolioController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'https://your-portfolio.com',
              prefixIcon: Icon(Icons.link_outlined, color: AppColors.textMuted, size: 18),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'LinkedIn URL',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _linkedinController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'https://linkedin.com/in/your-profile',
              prefixIcon: Icon(Icons.link_outlined, color: AppColors.textMuted, size: 18),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter LinkedIn URL';
              if (!val.contains('linkedin.com')) return 'Please provide a valid LinkedIn URL';
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Email OTP Verification',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    hintText: 'Enter OTP',
                    prefixIcon: Icon(Icons.smartphone_outlined, color: AppColors.textMuted, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _isOtpVerified ? AppColors.primaryTealDark : AppColors.accentBlueDark,
                  border: Border.all(
                    color: _isOtpVerified ? AppColors.primaryTeal : AppColors.cardBorder,
                    width: 1.2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: (_isOtpVerified || _isOtpVerifying) ? null : _simulateOtpVerification,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: _isOtpVerifying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryTeal),
                              )
                            : Text(
                                _isOtpVerified ? 'Verified' : 'Verify',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _isOtpVerified ? AppColors.primaryTeal : AppColors.textPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoBanner(
            icon: Icons.lock_outline,
            text: 'Your documents and credentials are encrypted and used solely for verification purposes.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Form() {
    return Form(
      key: _step4Key,
      child: Column(
        key: const ValueKey('step_4'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agreement',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Define your engagement terms and finalize your commitment to the network.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Rates',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _rateController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '\$  ',
              prefixStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              suffixIcon: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  'USD / HR',
                  style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter your rate';
              if (double.tryParse(val) == null) return 'Please enter a valid rate';
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Preferred Commitment Level',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedCommitmentLevel,
            hint: Text('Select commitment level', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            items: ['Full-time', 'Part-time', 'Advisory']
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedCommitmentLevel = val;
              });
            },
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreeToTerms,
                  activeColor: AppColors.primaryTeal,
                  checkColor: AppColors.backgroundDark,
                  onChanged: (val) {
                    setState(() {
                      _agreeToTerms = val ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ', confirming my professional credentials are valid and verifiable.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildInfoBanner(
            icon: Icons.verified_user_outlined,
            text: 'Identity Verified - KYC/AML Compliant setup ensures institutional governance standards.',
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    bool isLastStep = _currentStep == _totalSteps;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.backgroundMidnight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary, size: 20),
            label: Text(
              'Back',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            onPressed: _prevStep,
          ),
          _isSubmitting
              ? const CircularProgressIndicator(color: AppColors.primaryTeal)
              : CustomButton(
                  text: isLastStep ? 'Submit' : 'Next',
                  icon: Icon(
                    isLastStep ? Icons.check : Icons.arrow_forward,
                    color: AppColors.backgroundDark,
                    size: 16,
                  ),
                  onTap: _nextStep,
                  width: 160,
                ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundMidnight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textMuted, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
