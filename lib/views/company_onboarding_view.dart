import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final int _totalSteps = 4;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  String? _selectedIndustry;
  String? _uploadedLogoPath;
  bool _isUploadingLogo = false;

  final _descriptionController = TextEditingController();
  final _foundedController = TextEditingController();
  String? _selectedOrgType;
  String? _selectedOrgSize;
  String? _selectedCompanyAge;

  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isVerificationLoading = false;
  bool _isVerified = false;
  final List<TextEditingController> _additionalLinkControllers = [];

  final _adminNameController = TextEditingController();
  final _cinController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _gstinController = TextEditingController();
  bool _isAdminEmailVerificationLoading = false;
  bool _isAdminEmailVerified = false;
  String? _certificateUploadedPath;
  bool _isUploadingCertificate = false;
  bool _agreeToTerms = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _foundedController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _adminNameController.dispose();
    _cinController.dispose();
    _adminEmailController.dispose();
    _gstinController.dispose();
    for (var c in _additionalLinkControllers) {
      c.dispose();
    }
    super.dispose();
  }

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
        return _step2Key.currentState?.validate() ?? false;
      case 3:
        if (_step3Key.currentState?.validate() ?? false) {
          if (!_isVerified) {
            Forms.showErrorToast(context, 'Please verify your email before proceeding.');
            return false;
          }
          return true;
        }
        return false;
      case 4:
        if (_step4Key.currentState?.validate() ?? false) {
          if (!_agreeToTerms) {
            Forms.showErrorToast(context, 'You must agree to the terms and conditions.');
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
      context.go('/');
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() {
      _isSubmitting = true;
    });
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      ref.read(userRoleProvider.notifier).state = UserRole.company;
      Forms.showSuccessToast(context, 'Onboarding complete! Welcome to CXO Connect.');
      context.go('/signin');
    }
  }

  Future<void> _simulateLogoUpload() async {
    setState(() {
      _isUploadingLogo = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _uploadedLogoPath = 'company_logo.png';
      _isUploadingLogo = false;
    });
  }

  Future<void> _simulateVerification() async {
    if (_emailController.text.trim().isEmpty) {
      Forms.showErrorToast(context, 'Please enter your official email to verify.');
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
      Forms.showSuccessToast(context, 'Email verified successfully!');
    }
  }

  Future<void> _simulateAdminEmailVerification() async {
    if (_adminEmailController.text.trim().isEmpty) {
      Forms.showErrorToast(context, 'Please enter admin email to verify.');
      return;
    }
    setState(() {
      _isAdminEmailVerificationLoading = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isAdminEmailVerified = true;
      _isAdminEmailVerificationLoading = false;
    });
    if (mounted) {
      Forms.showSuccessToast(context, 'Admin email verified successfully!');
    }
  }

  Future<void> _simulateCertificateUpload() async {
    setState(() {
      _isUploadingCertificate = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _certificateUploadedPath = 'certificate_of_incorporation.pdf';
      _isUploadingCertificate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          if (isDesktop) {
            return Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth * 0.38,
                  child: _buildLeftPanel(),
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.62,
                  child: _buildRightPanel(),
                ),
              ],
            );
          }
          return _buildRightPanel();
        },
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.mintGradient,
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.backgroundDark, size: 24),
            onPressed: () => context.go('/'),
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
          ),
          const Spacer(),
          Text(
            'CXO\nCONNECT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: AppColors.backgroundDark,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join the elite network of corporate leaders and enterprises.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.backgroundDark.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
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
        _buildStickyFooter(),
      ],
    );
  }

  Widget _buildProgressIndicatorHeader() {
    double progressPercent = _currentStep / _totalSteps;
    String stepTitle = '';
    switch (_currentStep) {
      case 1:
        stepTitle = 'Basic Details';
        break;
      case 2:
        stepTitle = 'Company Info';
        break;
      case 3:
        stepTitle = 'Online Presence';
        break;
      case 4:
        stepTitle = 'Account Setup';
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
                                  color: isActive ? AppColors.primaryTeal : AppColors.textMuted,
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
            'Basic Details',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Let\'s start with some foundational information about your organization.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Company Name',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'e.g. Acme Corp',
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter company name' : null,
          ),
          const SizedBox(height: 20),
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
            'Company Info',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Provide detailed information about your organization.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Description',
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
          Text(
            'Organization Type',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedOrgType,
            hint: Text('Select organization type', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            items: ['Private Limited', 'Public Limited', 'LLP', 'Partnership', 'Sole Proprietorship', 'Non-Profit', 'Other']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedOrgType = val;
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            validator: (val) => val == null ? 'Please select organization type' : null,
          ),
          const SizedBox(height: 20),
          Text(
            'Organization Size',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedOrgSize,
            hint: Text('Select size', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            items: ['1-10', '11-50', '51-200', '201-500', '500+', '1000+']
                .map((size) => DropdownMenuItem(
                      value: size,
                      child: Text(size, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedOrgSize = val;
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            validator: (val) => val == null ? 'Please select organization size' : null,
          ),
          const SizedBox(height: 20),
          Text(
            'Company Age',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedCompanyAge,
            hint: Text('Select company age', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            items: ['Less than 1 year', '1-3 years', '3-5 years', '5-10 years', '10+ years']
                .map((age) => DropdownMenuItem(
                      value: age,
                      child: Text(age, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedCompanyAge = val;
              });
            },
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
            validator: (val) => val == null ? 'Please select company age' : null,
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 28),
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
            'Online Presence',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Connect your digital presence and verify your official company credentials.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Website URL',
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
          Text(
            'Contact Number',
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
          Text(
            'Official Email Address',
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
              if (val == null || val.trim().isEmpty) return 'Please enter official email';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 24),
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
                              _isVerified ? 'Verified' : 'Verify Email (OTP)',
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
          Text(
            'Additional Links',
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
                        decoration: const InputDecoration(
                          hintText: 'https://twitter.com/yourhandle',
                          prefixIcon: Icon(Icons.link, color: AppColors.textMuted, size: 16),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          const SizedBox(height: 28),
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
            'Account Setup',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Finalize your administrative account and legal credentials.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Account Admin Name',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _adminNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'John Doe',
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter admin name' : null,
          ),
          const SizedBox(height: 20),
          Text(
            'CIN Number',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _cinController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'U12345MH2020PTC123456',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter CIN number';
              if (val.trim().length != 21) return 'CIN must be exactly 21 characters';
              if (!RegExp(r'^[A-Za-z0-9]{21}$').hasMatch(val.trim())) return 'CIN must be alphanumeric (21 characters)';
              return null;
            },
          ),
          const SizedBox(height: 20),
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
              prefixIcon: Icon(Icons.mail_outline, color: AppColors.textMuted, size: 18),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter admin email';
              if (!val.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _isAdminEmailVerified ? AppColors.primaryTealDark : AppColors.accentBlueDark,
              border: Border.all(
                color: _isAdminEmailVerified ? AppColors.primaryTeal : AppColors.cardBorder,
                width: 1.2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: (_isAdminEmailVerified || _isAdminEmailVerificationLoading) ? null : _simulateAdminEmailVerification,
                child: Center(
                  child: _isAdminEmailVerificationLoading
                      ? const CircularProgressIndicator(color: AppColors.primaryTeal)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isAdminEmailVerified ? Icons.check_circle : Icons.verified_outlined,
                              color: _isAdminEmailVerified ? AppColors.primaryTeal : AppColors.textPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isAdminEmailVerified ? 'Verified' : 'Verify Admin Email (OTP)',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isAdminEmailVerified ? AppColors.primaryTeal : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'GSTIN Number',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _gstinController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: '22AAAAA0000A1Z5',
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter GSTIN number';
              final clean = val.trim();
              if (clean.length != 15) return 'GSTIN must be exactly 15 characters';
              if (!RegExp(r'^[A-Za-z0-9]{15}$').hasMatch(clean)) return 'GSTIN must be alphanumeric (15 characters)';
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            'Certificate of Incorporation (optional)',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _isUploadingCertificate ? null : _simulateCertificateUpload,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.backgroundMidnight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1.5, style: BorderStyle.solid),
              ),
              child: _isUploadingCertificate
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
                  : _certificateUploadedPath != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                _certificateUploadedPath!,
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
                              const Icon(Icons.upload_file_outlined, color: AppColors.primaryTeal, size: 36),
                              const SizedBox(height: 8),
                              Text(
                                'Upload Certificate',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'PDF or image (max 5MB)',
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
                        text: 'Terms and Conditions',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const TextSpan(text: ' and the corporate privacy policy regarding institutional data security.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
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
}
