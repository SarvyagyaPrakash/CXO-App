import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme.dart';
import '../viewmodels/app_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/forms.dart';

class ExpertOnboardingView extends ConsumerStatefulWidget {
  const ExpertOnboardingView({super.key});

  @override
  ConsumerState<ExpertOnboardingView> createState() => _ExpertOnboardingViewState();
}

class _ExpertOnboardingViewState extends ConsumerState<ExpertOnboardingView> {
  int _currentStep = 1;
  final int _totalSteps = 5;

  // Global Keys for step forms
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step4Key = GlobalKey<FormState>();
  final _step5Key = GlobalKey<FormState>();

  // --- Step 1 Controllers & State ---
  final _fullNameController = TextEditingController();
  final _headlineController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  String? _uploadedAvatarPath;
  bool _isUploadingAvatar = false;

  // --- Step 2 Controllers & State ---
  String? _selectedYearsOfExperience;
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _accomplishmentsController = TextEditingController();

  // --- Step 3 Controllers & State ---
  final List<String> _skillsList = ['Strategic Planning', 'Change Management', 'Operational Audit'];
  final List<Map<String, String>> _toolsList = [
    {'name': 'SAP ERP', 'level': 'Expert'}
  ];
  final List<Map<String, String>> _languagesList = [
    {'name': 'English', 'level': 'Native / Bilingual'},
    {'name': 'German', 'level': 'Professional Working'}
  ];

  // --- Step 4 Controllers & State ---
  final _rateController = TextEditingController();
  String? _selectedProjectType;
  String _selectedAvailability = '5-15'; // Default: Part-time

  // --- Step 5 Controllers & State ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _headlineController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    _accomplishmentsController.dispose();
    _rateController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        if (_step1Key.currentState?.validate() ?? false) {
          if (_uploadedAvatarPath == null) {
            Forms.showErrorToast(context, 'Please upload a professional profile headshot.');
            return false;
          }
          return true;
        }
        return false;
      case 2:
        if (_step2Key.currentState?.validate() ?? false) {
          if (_selectedYearsOfExperience == null) {
            Forms.showErrorToast(context, 'Please select total years of experience.');
            return false;
          }
          return true;
        }
        return false;
      case 3:
        if (_skillsList.isEmpty) {
          Forms.showErrorToast(context, 'Please add at least one primary skill.');
          return false;
        }
        return true;
      case 4:
        if (_step4Key.currentState?.validate() ?? false) {
          if (_selectedProjectType == null) {
            Forms.showErrorToast(context, 'Please select your preferred project type.');
            return false;
          }
          return true;
        }
        return false;
      case 5:
        if (_step5Key.currentState?.validate() ?? false) {
          if (!_agreeToTerms) {
            Forms.showErrorToast(context, 'You must agree to the terms of service.');
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

    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      // 1. Set global user role state to expert
      ref.read(userRoleProvider.notifier).state = UserRole.expert;

      // 2. Clear onboarding dialog and show congratulations
      Navigator.pop(context);
      Forms.showSuccessToast(context, 'Expert Registration complete! Welcome to the Vetting Panel.');

      // 3. Switch bottom nav to Profile tab (tab 3)
      ref.read(tabNavigationProvider.notifier).setTab(3);
    }
  }

  Future<void> _simulateAvatarUpload() async {
    setState(() {
      _isUploadingAvatar = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _uploadedAvatarPath = 'headshot_sarah.png';
      _isUploadingAvatar = false;
    });
  }

  // --- Dynamic helper functions for Step 3 list modifiers ---
  void _showAddSkillDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMidnight,
        title: Text('Add Primary Skill', style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary)),
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
                  _skillsList.add(controller.text.trim());
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddLanguageDialog() {
    final nameController = TextEditingController();
    final levelController = TextEditingController(text: 'Professional Working');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMidnight,
        title: Text('Add Language', style: GoogleFonts.spaceGrotesk(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Language Name', hintText: 'e.g. French'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: levelController,
              decoration: const InputDecoration(labelText: 'Proficiency Level', hintText: 'e.g. Native / Billingual'),
            ),
          ],
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
              if (nameController.text.trim().isNotEmpty && levelController.text.trim().isNotEmpty) {
                setState(() {
                  _languagesList.add({
                    'name': nameController.text.trim(),
                    'level': levelController.text.trim()
                  });
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMidnight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryTeal),
          onPressed: _prevStep,
        ),
        title: Text(
          'Expert Onboarding',
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
      ),
    );
  }

  // --- Step & Progress bar Widget Header ---
  Widget _buildProgressIndicatorHeader() {
    double progressPercent = _currentStep / _totalSteps;
    String stepTitle = '';
    switch (_currentStep) {
      case 1:
        stepTitle = 'Basic Info';
        break;
      case 2:
        stepTitle = 'Experience';
        break;
      case 3:
        stepTitle = 'Skills & Expertise';
        break;
      case 4:
        stepTitle = 'Pricing & Rates';
        break;
      case 5:
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
                'Step $_currentStep of 5: $stepTitle',
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
                    // Connector line
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
      case 5:
        return _buildStep5Form();
      default:
        return const SizedBox.shrink();
    }
  }

  // --- STEP 1: BASIC INFO ---
  Widget _buildStep1Form() {
    return Form(
      key: _step1Key,
      child: Column(
        key: const ValueKey('step_1'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Info',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Provide your foundational credentials to build your premium advisor profile and match with top tier corporations.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Full Name
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

          // Headline
          Text(
            'Professional Headline',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _headlineController,
            decoration: const InputDecoration(hintText: 'e.g. Former VP of Technology at Nexus Group'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a professional headline' : null,
          ),
          const SizedBox(height: 20),

          // Location
          Text(
            'Location',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: 'City, Country',
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textMuted, size: 20),
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your location' : null,
          ),
          const SizedBox(height: 20),

          // Professional Bio brief
          Text(
            'Brief Advisory Bio',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Describe your core advisory strengths and leadership specialties...'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a brief bio' : null,
          ),
          const SizedBox(height: 20),

          // Profile Image Upload Container
          Text(
            'Professional Headshot',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _isUploadingAvatar ? null : _simulateAvatarUpload,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.backgroundMidnight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder, width: 1.5),
              ),
              child: _isUploadingAvatar
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal))
                  : _uploadedAvatarPath != null
                      ? Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.success, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'Headshot Saved!',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${_uploadedAvatarPath!})',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.account_box_outlined, color: AppColors.primaryTeal, size: 28),
                              const SizedBox(height: 6),
                              Text(
                                'Upload Profile Headshot',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                              Text(
                                'PNG, JPG up to 5MB',
                                style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 28),

          _buildInfoHeroCard(
            title: 'Elite Vetting Policy',
            description: 'Only the top 3% of corporate advisors are verified to ensure high-trust matching for visionary brands.',
          ),
        ],
      ),
    );
  }

  // --- STEP 2: EXPERIENCE ---
  Widget _buildStep2Form() {
    return Form(
      key: _step2Key,
      child: Column(
        key: const ValueKey('step_2'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience',
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

          // Total Years of Experience Dropdown
          Text(
            'Total Years of Experience',
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

          // Current/Last Job Title
          Text(
            'Current/Last Job Title',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _jobTitleController,
            decoration: const InputDecoration(hintText: 'e.g. Senior Strategic Advisor'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter job title' : null,
          ),
          const SizedBox(height: 20),

          // Company Name
          Text(
            'Company Name',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _companyController,
            decoration: const InputDecoration(hintText: 'e.g. Global Solutions Corp'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter company name' : null,
          ),
          const SizedBox(height: 20),

          // Key Accomplishments
          Text(
            'Key Accomplishments',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _accomplishmentsController,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Highlight your most impactful contributions, projects, or leadership roles...',
              counterStyle: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter accomplishments' : null,
          ),
          const SizedBox(height: 20),

          // Verification Panel matching screenshot 2
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryTealDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryTeal.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.primaryTeal, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Verification Check',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Our specialized panel reviews experience history to maintain corporate ledger integrity.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Tiny avatar stack visual from mockup 2
                Row(
                  children: [
                    ...List.generate(3, (index) => const Padding(
                      padding: EdgeInsets.only(right: 6.0),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.accentBlueDark,
                        child: Icon(Icons.person, size: 12, color: AppColors.textSecondary),
                      ),
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+12',
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.backgroundDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pro tip card
          _buildInfoBanner(
            icon: Icons.lightbulb_outline,
            text: 'Pro Tip: Experts who include quantifiable metrics (e.g. "Increased revenue by 20%") have a 45% higher verification speed.',
          ),
        ],
      ),
    );
  }

  // --- STEP 3: SKILLS & EXPERTISE ---
  Widget _buildStep3Form() {
    return Column(
      key: const ValueKey('step_3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Skills',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Select the core competencies you provide as an expert.',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Interactive skills chips grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._skillsList.map((skill) => Chip(
                  label: Text(
                    skill,
                    style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: AppColors.cardBackground,
                  deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.textSecondary),
                  onDeleted: () {
                    setState(() {
                      _skillsList.remove(skill);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                )),

            // Add Skill Trigger chip button
            GestureDetector(
              onTap: _showAddSkillDialog,
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
        const SizedBox(height: 32),

        // Tools List section
        Text(
          'Tools & Software Expertise',
          style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'List the enterprise systems you are proficient in.',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Dynamic tools list view
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _toolsList.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  // Tool Name field
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      initialValue: _toolsList[index]['name'],
                      onChanged: (val) {
                        _toolsList[index]['name'] = val;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Software Name (e.g. SAP)',
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Level dropdown selection
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _toolsList[index]['level'],
                      items: ['Beginner', 'Intermediate', 'Expert']
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _toolsList[index]['level'] = val;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Delete button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _toolsList.removeAt(index);
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        OutlinedButton.icon(
          icon: const Icon(Icons.add, size: 16, color: AppColors.primaryTeal),
          label: Text('Add another tool', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
          onPressed: () {
            setState(() {
              _toolsList.add({'name': '', 'level': 'Expert'});
            });
          },
        ),
        const SizedBox(height: 32),

        // Languages spoken section
        Text(
          'Languages Spoken',
          style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        Text(
          'Your capability to handle international clients.',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Interactive languages cards matching mockup 3
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _languagesList.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.translate, color: AppColors.textMuted, size: 18),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _languagesList[index]['name']!,
                          style: GoogleFonts.outfit(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          _languagesList[index]['level']!,
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 18),
                    onPressed: () {
                      setState(() {
                        _languagesList.removeAt(index);
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),

        OutlinedButton.icon(
          icon: const Icon(Icons.translate, size: 16, color: AppColors.primaryTeal),
          label: Text('Add language proficiency', style: GoogleFonts.outfit(fontSize: 13, color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
          onPressed: _showAddLanguageDialog,
        ),
        const SizedBox(height: 24),

        _buildInfoBanner(
          icon: Icons.info_outline,
          text: 'Detailed skill profiles increase your visibility to premium corporate clients by up to 40%. Be as specific as possible.',
        ),
      ],
    );
  }

  // --- STEP 4: PRICING & RATES ---
  Widget _buildStep4Form() {
    return Form(
      key: _step4Key,
      child: Column(
        key: const ValueKey('step_4'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing & Rates',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Define your compensation expectations and availability to help us match you with the right corporate partners.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Hourly Rate field
          Text(
            'Hourly Rate',
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
              if (val == null || val.trim().isEmpty) return 'Please enter hourly rate';
              if (double.tryParse(val) == null) return 'Please enter a valid rate';
              return null;
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Recommended: \$150 - \$350 for your seniority level.',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 24),

          // Preferred Project Type Dropdown
          Text(
            'Preferred Project Type',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedProjectType,
            hint: Text('Select an engagement type', style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14)),
            items: ['Fractional', 'Interim', 'Advisory']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _selectedProjectType = val;
              });
            },
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
          ),
          const SizedBox(height: 24),

          // Availability cards grid matching mockup 4
          Text(
            'Availability (Hours per week)',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: [
              _buildAvailabilityCard(id: '0-5', title: '0-5', subtitle: 'Casual'),
              _buildAvailabilityCard(id: '5-15', title: '5-15', subtitle: 'Part-time'),
              _buildAvailabilityCard(id: '15-30', title: '15-30', subtitle: 'Focused'),
              _buildAvailabilityCard(id: '30+', title: '30+', subtitle: 'Full-time'),
            ],
          ),
          const SizedBox(height: 24),

          _buildInfoBanner(
            icon: Icons.info_outline,
            text: 'Your rates are visible only to matched partners and remain confidential until an engagement is proposed.',
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard({required String id, required String title, required String subtitle}) {
    bool isSelected = _selectedAvailability == id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvailability = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTealDark : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryTeal : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryTeal : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isSelected ? AppColors.primaryTeal : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- STEP 5: ACCOUNT SETUP ---
  Widget _buildStep5Form() {
    return Form(
      key: _step5Key,
      child: Column(
        key: const ValueKey('step_5'),
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
            'Secure your expert profile and finalize your application to the professional ledger network.',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Account Email Address
          Text(
            'Account Email',
            style: GoogleFonts.outfit(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'expert@domain.com',
              suffixIcon: Icon(Icons.mail_outline, color: AppColors.textMuted, size: 20),
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) return 'Please enter account email';
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
            decoration: const InputDecoration(hintText: '********'),
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

          // Vetting / compliance info cards matching bottom of mockup 5
          _buildInfoBanner(
            icon: Icons.lock_outline,
            text: 'AES-256 Encryption - Banking-grade data protection locks all professional history logs securely.',
          ),
          const SizedBox(height: 12),
          _buildInfoBanner(
            icon: Icons.verified_user_outlined,
            text: 'Identity Verified - KYC/AML Compliant setup ensures institutional governance standards.',
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
                  text: isLastStep ? 'Complete Registration' : 'Next',
                  icon: Icon(
                    isLastStep ? Icons.verified_user : Icons.arrow_forward,
                    color: AppColors.backgroundDark,
                    size: 16,
                  ),
                  onTap: _nextStep,
                  width: 175,
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
}
