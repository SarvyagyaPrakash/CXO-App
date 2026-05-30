import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../viewmodels/app_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/forms.dart';

class CompanyOnboardingView extends ConsumerStatefulWidget {
  const CompanyOnboardingView({super.key});

  @override
  ConsumerState<CompanyOnboardingView> createState() => _CompanyOnboardingViewState();
}

class _CompanyOnboardingViewState extends ConsumerState<CompanyOnboardingView> {
  int _currentStep = 1;
  final int _totalSteps = 5;

  // Global Keys for step forms
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();

  // --- Step 1 Controllers & State ---
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  String? _selectedIndustry;
  String? _uploadedLogoPath;
  bool _isUploadingLogo = false;

  // --- Step 2 Controllers & State ---
  String? _selectedCompanySize;
  final _foundedController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // --- Step 3 Controllers & State ---
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isVerificationLoading = false;
  bool _isVerified = false;

  // --- Step 4 Controllers & State ---
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final List<TextEditingController> _additionalLinkControllers = [];

  // --- Step 5 Controllers & State ---
  final _adminEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _foundedController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _adminEmailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _additionalLinkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Helper to validate the active step form
  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        if (_step1Key.currentState?.validate() ?? false) {
          if (_uploadedLogoPath == null) {
            Forms.showErrorToast(context, 'Please upload a company logo.');
            return false;
          }
          if (_selectedIndustry == null) {
            Forms.showErrorToast(context, 'Please select an industry.');
            return false;
          }
          return true;
        }
        return false;
      case 2:
        if (_step2Key.currentState?.validate() ?? false) {
          if (_selectedCompanySize == null) {
            Forms.showErrorToast(context, 'Please select company size.');
            return false;
          }
          return true;
        }
        return false;
      case 3:
        if (_step3Key.currentState?.validate() ?? false) {
          if (!_isVerified) {
            Forms.showErrorToast(context, 'Please verify your contact details before proceeding.');
            return false;
          }
          return true;
        }
        return false;
      case 4:
        return _step4Key.currentState?.validate() ?? true;
      case 5:
        if (_step5Key.currentState?.validate() ?? false) {
          if (!_agreeToTerms) {
            Forms.showErrorToast(context, 'You must agree to the terms and conditions.');
            return false;
          }
          if (_passwordController.text != _confirmPasswordController.text) {
            Forms.showErrorToast(context, 'Passwords do not match.');
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

    // Simulate database submission delay
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      // 1. Set global user role state
      ref.read(userRoleProvider.notifier).state = UserRole.company;

      // 2. Clear onboarding dialog and show congratulations
      Navigator.pop(context);
      Forms.showSuccessToast(context, 'Institutional Registration complete! Welcome to the Ledger Workspace.');

      // 3. Switch bottom nav to Projects dashboard
      ref.read(tabNavigationProvider.notifier).setTab(1);
    }
  }

  // Logo simulated upload
  Future<void> _simulateLogoUpload() async {
    setState(() {
      _isUploadingLogo = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _uploadedLogoPath = 'logo_forest_global.png';
      _isUploadingLogo = false;
    });
  }

  // Simulated verification check
  Future<void> _simulateVerification() async {
    if (_phoneController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      Forms.showErrorToast(context, 'Provide contact number & official email to verify.');
      return;
    }
    setState(() {
      _isVerificationLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isVerified = true;
      _isVerificationLoading = false;
    });
    if (mounted) {
      Forms.showSuccessToast(context, 'Credentials verified successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMidnight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryTeal),
          onPressed: _prevStep,
        ),
        title: Text(
          'Onboarding',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.cardBorder,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          // Step progress indicators at top
          _buildProgressIndicatorHeader(),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepForm(),
              ),
            ),
          ),

          // Bottom navigation actions
          _buildStickyFooter(),
        ],
      ),
    );
  }

  // --- Step & Progress bar Widget Header ---
  Widget _buildProgressIndicatorHeader() {
    double progressPercent = _currentStep / _totalSteps;
    String stepTitle = '';
    switch (_currentStep) {
      case 1:
        stepTitle = 'Basics';
        break;
      case 2:
        stepTitle = 'Company Details';
        break;
      case 3:
        stepTitle = 'Credentials & Verification';
        break;
      case 4:
        stepTitle = 'Online Presence';
        break;
      case 5:
        stepTitle = 'Account Finalization';
        break;
    }

    return Container(
      color: AppColors.backgroundMidnight,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text percentages
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep: $stepTitle',
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

          // Progress bar line
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

          // Visual Circle nodes matching screenshots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_totalSteps, (index) {
              int stepNum = index + 1;
              bool isCompleted = stepNum < _currentStep;
              bool isActive = stepNum == _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // Node
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
                    // Connector line (except for last node)
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

  // Render active step structure
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
      case 5:
        return _buildStep5Form();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STEP 1: BASIC DETAILS ---
  Widget _buildStep1Form() {
    return Form(
      key: _step1Key,
      child: Column(
        key: const ValueKey('step_1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Details',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Let\'s start with some foundational information about your organization to set up your ledger workspace.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Company Name field
          Text(
            'Company Name',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'e.g. Forest Global Corp',
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter company name' : null,
          ),
          const SizedBox(height: 20),

          // Company Logo upload box
          Text(
            'Company Logo',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _isUploadingLogo ? null : _simulateLogoUpload,
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.backgroundMidnight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1.5, style: BorderStyle.solid),
              ),
              child: _isUploadingLogo
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
                  : _uploadedLogoPath != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                _uploadedLogoPath!,
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
                                'Click to upload',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SVG, PNG, or JPG (max 2MB)',
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

          // Industry selector
          Text(
            'Industry',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedIndustry,
            hint: Text('Select an industry', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            items: ['Technology', 'FinTech', 'Healthcare', 'Logistics', 'Real Estate', 'Other']
                .map((industry) => DropdownMenuItem(
                      value: industry,
                      child: Text(industry, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedIndustry = val;
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
          const SizedBox(height: 20),

          // Company Tagline
          Text(
            'Company Tagline',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _taglineController,
            decoration: const InputDecoration(
              hintText: 'Briefly describe your vision...',
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter company tagline' : null,
          ),
          const SizedBox(height: 28),

          // Visual block matching "Institutional Trust" card in screenshot 1
          _buildInfoHeroCard(
            title: 'Institutional Trust',
            description: 'Join over 5,000 corporate entities managing their assets with our secure forest-grade infrastructure.',
          ),
        ],
      ),
    );
  }

  // --- STEP 2: COMPANY PROFILE ---
  Widget _buildStep2Form() {
    return Form(
      key: _step2Key,
      child: Column(
        key: const ValueKey('step_2'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Profile',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Provide the essential identification details for your corporate entity to proceed with verification.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Company Size
          Text(
            'Company Size',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedCompanySize,
            hint: Text('Select size', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            items: ['1-10', '11-50', '51-200', '201-500', '500+']
                .map((size) => DropdownMenuItem(
                      value: size,
                      child: Text(size, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedCompanySize = val;
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
          const SizedBox(height: 20),

          // Founded Year
          Text(
            'Founded Year',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _foundedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'YYYY',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter founded year';
              final yr = int.tryParse(val);
              if (yr == null || yr < 1800 || yr > DateTime.now().year) return 'Please enter a valid year';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // HQ Location
          Text(
            'HQ Location',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: 'City, Country',
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 20),
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter HQ location' : null,
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            'Brief Description',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Tell us about your core mission and business operations...',
              counterStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
          ),
          const SizedBox(height: 20),

          // Small info panel
          _buildInfoBanner(
            icon: Icons.info_outline,
            text: 'This information will be used to generate your official ledger profile and cannot be changed easily later.',
          ),
          const SizedBox(height: 24),

          // Visual badges matching screenshot 2
          _buildInfoHeroCard(
            title: 'Trusted by 5,000+ Enterprises',
            description: 'Proven governance and matching security for cross-border engineering teams.',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryTealDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primaryTeal, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ISO 27001 Certified',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your data security is our highest priority.',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 3: CONTACT & CREDENTIAL VERIFICATION ---
  Widget _buildStep3Form() {
    return Form(
      key: _step3Key,
      child: Column(
        key: const ValueKey('step_3'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Online Presence & Verification',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Connect your contact details and verify your official company credentials.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Website URL
          Text(
            'Website URL *',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'https://www.example.com',
              prefixIcon: Icon(Icons.language, color: AppColors.textMuted, size: 18),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter website URL';
              if (!val.contains('http')) return 'Enter a valid URL (including http/https)';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Contact Number
          Text(
            'Contact Number *',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '+91 98765 43210',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMuted, size: 18),
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter contact number' : null,
          ),
          const SizedBox(height: 20),

          // Company Email
          Text(
            'Official Company Email *',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'hr@company.com',
              prefixIcon: Icon(Icons.mail_outline, color: AppColors.textMuted, size: 18),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter company email';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Verification trigger button with dynamic states
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isVerified ? AppColors.primaryTealDark : AppColors.accentBlueDark,
              border: Border.all(
                color: _isVerified ? AppColors.primaryTeal : AppColors.cardBorder,
                width: 1.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: (_isVerified || _isVerificationLoading) ? null : _simulateVerification,
                child: Center(
                  child: _isVerificationLoading
                      ? const CircularProgressIndicator(color: AppColors.primaryTeal)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isVerified ? Icons.check_circle : Icons.verified_outlined,
                              color: _isVerified ? AppColors.primaryTeal : AppColors.textPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isVerified ? 'Verified' : 'Verify Details',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _isVerified ? AppColors.primaryTeal : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Small info panel
          _buildInfoBanner(
            icon: Icons.info_outline,
            text: 'These profiles are used for professional background verification only and remain private.',
          ),
          const SizedBox(height: 24),

          _buildPresenceBadges(),
        ],
      ),
    );
  }

  // --- STEP 4: ONLINE PRESENCE & LINKS ---
  Widget _buildStep4Form() {
    return Form(
      key: _step4Key,
      child: Column(
        key: const ValueKey('step_4'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Online Presence',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Connect your professional digital identity to enhance your institutional verification profile.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // LinkedIn Page
          Text(
            'LinkedIn Page *',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _linkedinController,
            decoration: const InputDecoration(
              hintText: 'https://linkedin.com/company/your-company',
              prefixIcon: Icon(Icons.link_outlined, color: AppColors.textMuted, size: 18),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter LinkedIn page';
              if (!val.contains('linkedin')) return 'Please provide a valid LinkedIn URL';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Twitter/X Handle
          Text(
            'Twitter/X Handle',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _twitterController,
            decoration: const InputDecoration(
              hintText: '@username',
              prefixIcon: Icon(Icons.alternate_email_outlined, color: AppColors.textMuted, size: 18),
            ),
          ),
          const SizedBox(height: 20),

          // Instagram Profile
          Text(
            'Instagram Profile',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _instagramController,
            decoration: const InputDecoration(
              hintText: 'instagram.com/username',
              prefixIcon: Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 18),
            ),
          ),
          const SizedBox(height: 24),

          // Dynamic Additional Links (up to 3) matching screenshot 4
          Text(
            'Additional Links (optional)',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _additionalLinkControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _additionalLinkControllers[index],
                        decoration: InputDecoration(
                          hintText: 'https://...',
                          prefixIcon: const Icon(Icons.link, color: AppColors.textMuted, size: 16),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _additionalLinkControllers[index].dispose();
                          _additionalLinkControllers.removeAt(index);
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.close, color: AppColors.error, size: 20),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (_additionalLinkControllers.length < 3)
            OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Link'),
              onPressed: () {
                setState(() {
                  _additionalLinkControllers.add(TextEditingController());
                });
              },
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Maximum 3 links reached',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 24),

          _buildPresenceBadges(),
        ],
      ),
    );
  }

  // --- STEP 5: FINALIZE YOUR ACCOUNT ---
  Widget _buildStep5Form() {
    return Form(
      key: _step5Key,
      child: Column(
        key: const ValueKey('step_5'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finalize Your Account',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Secure your corporate ledger access by setting up your administrative credentials.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Admin Email Address
          Text(
            'Admin Email Address',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _adminEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'admin@company.com',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter admin email';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password
          Text(
            'Password',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '********',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter password';
              if (val.length < 8) return 'Password must be at least 8 characters';
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password
          Text(
            'Confirm Password',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: const InputDecoration(
              hintText: '********',
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please confirm password' : null,
          ),
          const SizedBox(height: 24),

          // Agree to terms checkbox row matching screenshot 5
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
                        text: 'Terms and Conditions',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' and the corporate privacy policy regarding '),
                      TextSpan(
                        text: 'institutional data security.',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Administrative encryption panels matching bottom of screenshot 5
          _buildInfoBanner(
            icon: Icons.security_outlined,
            text: '256-bit institutional grade security keeps your organizational accounts and metadata fully encrypted.',
          ),
          const SizedBox(height: 12),
          _buildInfoBanner(
            icon: Icons.account_balance_wallet_outlined,
            text: 'Multi-Org Ready: Swiftly configure sub-entities or switch workspaces after completion.',
          ),
        ],
      ),
    );
  }

  // --- STICKY FOOTER ---
  Widget _buildStickyFooter() {
    bool isLastStep = _currentStep == _totalSteps;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.backgroundMidnight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
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

          // Next / Complete Button
          _isSubmitting
              ? const CircularProgressIndicator(color: AppColors.primaryTeal)
              : CustomButton(
                  text: isLastStep ? 'Complete Setup' : 'Next',
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

  // Info Block layout helper
  Widget _buildInfoHeroCard({required String title, required String description}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryTeal,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // Small info banner helper
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

  // Repeated presence/trust badges in step 3 and 4
  Widget _buildPresenceBadges() {
    return Column(
      children: [
        _buildTrustBadgeCard(
          icon: Icons.verified_user_outlined,
          title: 'Trusted Network',
          subtitle: 'Validated professional presence.',
        ),
        const SizedBox(height: 12),
        _buildTrustBadgeCard(
          icon: Icons.vpn_key_outlined,
          title: 'Secure Connection',
          subtitle: 'End-to-end encrypted data entry.',
        ),
      ],
    );
  }

  Widget _buildTrustBadgeCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryTeal, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
