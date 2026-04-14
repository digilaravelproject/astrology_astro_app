import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';
import '../../../core/utils/custom_snackbar.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  final authController = Get.find<AuthController>();

  int _currentStep = 0;
  final int _totalSteps = 5;

  AnimationController? _progressController;

  // Step 1
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  String? _nameError;
  String? _mobileError;
  String? _cityError;
  String? _countryError;
  String? _experienceError;
  String? _expertiseError;
  String? _languageError;
  String? _idProofError;
  String? _certificateError;
  String? _docNumberError;
  String? _dobError;

  void _clearErrors() {
    setState(() {
      _nameError = null;
      _mobileError = null;
      _cityError = null;
      _countryError = null;
      _experienceError = null;
      _expertiseError = null;
      _languageError = null;
      _idProofError = null;
      _certificateError = null;
      _docNumberError = null;
      _dobError = null;
    });
  }

  // Step 2
  final _experienceController = TextEditingController();
  final List<String> _allExpertise = [
    'Vedic Astrology', 'Tarot', 'Numerology', 'Palmistry',
    'Vastu', 'KP Astrology', 'Nadi Astrology', 'Feng Shui',
    'Face Reading', 'Prashna',
  ];
  final List<String> _selectedExpertise = [];

  // Step 3
  final List<String> _allLanguages = [
    'Hindi', 'English', 'Bengali', 'Tamil',
    'Telugu', 'Marathi', 'Gujarati', 'Kannada',
    'Malayalam', 'Punjabi', 'Odia', 'Urdu',
  ];
  final List<String> _selectedLanguages = [];

  // Step 4
  final _bioController = TextEditingController();
  File? _profileImage;
  final _picker = ImagePicker();

  // Step 5
  final _docNumberController = TextEditingController();
  final _dobController = TextEditingController();
  File? _idProofImage;
  File? _certificateImage;

  final List<String> _countries = ['India', 'USA', 'UK', 'Australia', 'Canada', 'UAE', 'Singapore'];
  final List<String> _cities = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Ahmedabad', 'Chennai', 'Kolkata', 'Pune', 'Jaipur', 'Lucknow'];
  String _searchQuery = '';

  final _stepTitles = ['Basic Details', 'Expertise', 'Languages', 'Profile', 'Documents'];

  @override
  void initState() {
    super.initState();
    if (authController.mobileController.text.isNotEmpty) {
      _mobileController.text = authController.mobileController.text;
    }
    _progressController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    )..animateTo(1 / _totalSteps);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController?.dispose();
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _docNumberController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    _progressController?.animateTo(
      (step + 1) / _totalSteps,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    FocusScope.of(context).unfocus();
    if (!_isStepValid()) return;
    
    if (_currentStep < _totalSteps - 1) {
      _goToStep(_currentStep + 1);
    } else {
      _submit();
    }
  }

  bool _isStepValid() {
    _clearErrors();
    bool isValid = true;
    
    switch (_currentStep) {
      case 0: // Step 1: Basic Details
        if (_nameController.text.trim().isEmpty) {
          setState(() => _nameError = 'Please enter your full name');
          isValid = false;
        }
        if (_mobileController.text.trim().length != 10) {
          setState(() => _mobileError = 'Please enter a valid 10-digit mobile number');
          isValid = false;
        }
        if (_cityController.text.trim().isEmpty) {
          setState(() => _cityError = 'Please select your city');
          isValid = false;
        }
        if (_countryController.text.trim().isEmpty) {
          setState(() => _countryError = 'Please select your country');
          isValid = false;
        }
        break;

      case 1: // Step 2: Expertise
        if (_experienceController.text.trim().isEmpty) {
          setState(() => _experienceError = 'Please enter your years of experience');
          isValid = false;
        }
        if (_selectedExpertise.isEmpty) {
          setState(() => _expertiseError = 'Please select at least one area of expertise');
          isValid = false;
        }
        break;

      case 2: // Step 3: Languages
        if (_selectedLanguages.isEmpty) {
          setState(() => _languageError = 'Please select at least one language');
          isValid = false;
        }
        break;

      case 3: // Step 4: Profile
        // Optional
        break;

      case 4: // Step 5: Documents
        if (_idProofImage == null) {
          setState(() => _idProofError = 'Please upload your ID Proof');
          isValid = false;
        }
        if (_certificateImage == null) {
          setState(() => _certificateError = 'Please upload your Certificate');
          isValid = false;
        }
        if (_docNumberController.text.trim().isEmpty) {
          setState(() => _docNumberError = 'Please enter your ID Proof number');
          isValid = false;
        }
        if (_dobController.text.trim().isEmpty) {
          setState(() => _dobError = 'Please select your Date of Birth');
          isValid = false;
        }
        break;
    }
    
    return isValid;
  }

  void _submit() {
    final data = {
      'full_name': _nameController.text.trim(),
      'phone': _mobileController.text.trim(),
      'email': _emailController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'years_of_experience': _experienceController.text.trim(),
      'areas_of_expertise': _selectedExpertise,
      'languages': _selectedLanguages,
      'bio': _bioController.text.trim(),
      'id_proof_number': _docNumberController.text.trim(),
      'date_of_birth': _dobController.text.trim(),
      'profile_photo': _profileImage?.path,
      'id_proof': _idProofImage?.path,
      'certificate': _certificateImage?.path,
    };

    authController.astrologerSignup(data);
  }

  Future<void> _pickImage() async {
    final p = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (p != null) setState(() => _profileImage = File(p.path));
  }

  Future<void> _pickDocImage(bool isId) async {
    final p = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (p != null) {
      setState(() {
        if (isId) {
          _idProofImage = File(p.path);
          _idProofError = null;
        } else {
          _certificateImage = File(p.path);
          _certificateError = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      body: Column(
        children: [
          _buildHeader(),
          _buildProgressBar(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(), _buildStep2(), _buildStep3(),
                _buildStep4(), _buildStep5(),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _currentStep > 0 ? _goToStep(_currentStep - 1) : Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _currentStep > 0 ? Icons.arrow_back_ios_new_rounded : Icons.close_rounded,
                    size: 18, color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      _stepTitles[_currentStep],
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                    AppText(
                      'Step ${_currentStep + 1} of $_totalSteps',
                      fontSize: 12,
                      color: AppColors.textColorSecondary,
                    ),
                  ],
                ),
              ),
              // Step dots
              Row(
                children: List.generate(_totalSteps, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 4),
                  width: i == _currentStep ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: i <= _currentStep
                        ? AppColors.primaryColor
                        : AppColors.primaryColor.withOpacity(0.15),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PROGRESS BAR ──────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressController ?? kAlwaysCompleteAnimation,
      builder: (_, __) => LinearProgressIndicator(
        value: (_currentStep + 1) / _totalSteps,
        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
        minHeight: 3,
      ),
    );
  }

  // ── STEP 1 ────────────────────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _card([
            _label('Full Name'),
            _field(_nameController, 'e.g. Rajesh Kumar', Icons.person_outline_rounded,
                errorText: _nameError, onChanged: (v) => setState(() => _nameError = null)),
            const SizedBox(height: 16),
            _label('Mobile Number'),
            _field(_mobileController, 'e.g. 9876543210', Icons.phone_outlined,
                keyboard: TextInputType.phone,
                errorText: _mobileError,
                onChanged: (v) => setState(() => _mobileError = null),
                formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)]),
            const SizedBox(height: 16),
            _label('Email (Optional)'),
            _field(_emailController, 'example@email.com', Icons.email_outlined, keyboard: TextInputType.emailAddress),
          ]),
          const SizedBox(height: 14),
          _card([
            _label('City'),
            GestureDetector(
              onTap: () => _showSheet('Select City', _cities, (v) => setState(() { _cityController.text = v; _cityError = null; })),
              child: AbsorbPointer(child: _field(_cityController, 'Select city', Icons.location_city_outlined, 
                  errorText: _cityError,
                  trailing: const Icon(Icons.expand_more, color: AppColors.primaryColor, size: 20))),
            ),
            const SizedBox(height: 16),
            _label('Country'),
            GestureDetector(
              onTap: () => _showSheet('Select Country', _countries, (v) => setState(() { _countryController.text = v; _countryError = null; })),
              child: AbsorbPointer(child: _field(_countryController, 'Select country', Icons.flag_outlined, 
                  errorText: _countryError,
                  trailing: const Icon(Icons.expand_more, color: AppColors.primaryColor, size: 20))),
            ),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── STEP 2 ────────────────────────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _card([
            _label('Years of Experience'),
            _field(_experienceController, 'e.g. 5', Icons.timeline_outlined,
                keyboard: TextInputType.number,
                errorText: _experienceError,
                onChanged: (v) => setState(() => _experienceError = null),
                formatters: [FilteringTextInputFormatter.digitsOnly]),
          ]),
          const SizedBox(height: 14),
          _card([
            _label('Areas of Expertise'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: _allExpertise.map((e) {
                final sel = _selectedExpertise.contains(e);
                return GestureDetector(
                  onTap: () => setState(() {
                    sel ? _selectedExpertise.remove(e) : _selectedExpertise.add(e);
                    _expertiseError = null;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: sel ? AppColors.primaryColor : Colors.white,
                      border: Border.all(
                        color: sel ? AppColors.primaryColor : Colors.grey.shade300,
                      ),
                    ),
                    child: AppText(e, fontSize: 13, fontWeight: FontWeight.w500,
                        color: sel ? Colors.white : AppColors.textColorSecondary),
                  ),
                );
              }).toList(),
            ),
            _errorLabel(_expertiseError),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── STEP 3 ────────────────────────────────────────────────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _card([
        _label('Languages You Consult In'),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.4,
          ),
          itemCount: _allLanguages.length,
          itemBuilder: (_, i) {
            final lang = _allLanguages[i];
            final sel = _selectedLanguages.contains(lang);
            return GestureDetector(
              onTap: () => setState(() {
                sel ? _selectedLanguages.remove(lang) : _selectedLanguages.add(lang);
                _languageError = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: sel ? AppColors.primaryColor : Colors.white,
                  border: Border.all(color: sel ? AppColors.primaryColor : Colors.grey.shade300),
                ),
                child: Center(
                  child: AppText(lang, fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.textColorSecondary),
                ),
              ),
            );
          },
        ),
        _errorLabel(_languageError),
      ]),
    );
  }

  // ── STEP 4 ────────────────────────────────────────────────────────────────
  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _card([
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? Icon(Icons.person_outline_rounded, size: 44, color: AppColors.primaryColor)
                              : null,
                        ),
                        Positioned(
                          bottom: 2, right: 2,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.primaryColor,
                            child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText('Upload Profile Photo', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryColor),
                    AppText('Optional', fontSize: 11, color: AppColors.textColorSecondary),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          _card([
            _label('Short Bio (Optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 5,
              maxLength: 300,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Describe your experience and approach...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.textColorHint),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5)),
                contentPadding: const EdgeInsets.all(14),
                counterStyle: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── STEP 5 ────────────────────────────────────────────────────────────────
  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _card([
            _label('Upload Documents'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _docPicker('ID Proof', _idProofImage, () => _pickDocImage(true))),
                const SizedBox(width: 12),
                Expanded(child: _docPicker('Certificate', _certificateImage, () => _pickDocImage(false))),
              ],
            ),
            Row(
              children: [
                Expanded(child: _errorLabel(_idProofError)),
                const SizedBox(width: 12),
                Expanded(child: _errorLabel(_certificateError)),
              ],
            ),
          ]),
          const SizedBox(height: 14),
          _card([
            _label('ID Proof Number'),
            _field(_docNumberController, 'Aadhaar / PAN', Icons.badge_outlined,
                errorText: _docNumberError,
                onChanged: (v) => setState(() => _docNumberError = null)),
            const SizedBox(height: 16),
            _label('Date of Birth'),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(child: _field(_dobController, 'DD / MM / YYYY', Icons.calendar_today_outlined,
                  errorText: _dobError,
                  trailing: const Icon(Icons.expand_more, color: AppColors.primaryColor, size: 20))),
            ),
          ]),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.amber.shade800, size: 18),
                const SizedBox(width: 10),
                Expanded(child: AppText(
                  'Profile will be reviewed within 24–48 hours.',
                  fontSize: 12, color: Colors.amber.shade900, height: 1.5,
                )),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── BOTTOM BAR ────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: CustomButton(
        text: isLast ? 'Submit Application' : 'Continue',
        onPressed: _onNext,
        suffixIcon: Icon(
          isLast ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
          color: Colors.white, size: 20,
        ),
        backgroundColor: AppColors.primaryColor,
        borderRadius: 100,
      ),
    );
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  Widget _card(List<Widget> children) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AppText(text, fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
  );

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboard,
    List<TextInputFormatter>? formatters,
    Widget? trailing,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) =>
      TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboard,
        inputFormatters: formatters,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: AppColors.textColorHint),
          prefixIcon: Icon(icon, color: AppColors.primaryColor, size: 20),
          suffixIcon: trailing,
          errorText: errorText,
          errorStyle: const TextStyle(fontSize: 11, height: 0.8),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorColor)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.errorColor, width: 1.5)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );

  Widget _errorLabel(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: AppText(error, fontSize: 11, color: AppColors.errorColor),
    );
  }

  Widget _docPicker(String label, File? file, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: 12, fontWeight: FontWeight.w600),
        const SizedBox(height: 6),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: file != null ? AppColors.primaryColor : Colors.grey.shade200),
          ),
          child: file != null
              ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover))
              : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.upload_rounded, color: AppColors.primaryColor, size: 26),
                  const SizedBox(height: 4),
                  AppText('Tap to upload', fontSize: 10, color: AppColors.textColorHint),
                ]),
        ),
      ],
    ),
  );

  void _showSheet(String title, List<String> items, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final filtered = _searchQuery.isEmpty
            ? items
            : items.where((i) => i.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Row(children: [
                  AppText(title, fontSize: 17, fontWeight: FontWeight.w700),
                  const Spacer(),
                  GestureDetector(
                    onTap: () { setState(() => _searchQuery = ''); Navigator.pop(ctx); },
                    child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.close_rounded, size: 16)),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: TextField(
                  onChanged: (v) => setSheet(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryColor, size: 20),
                    filled: true, fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (_, i) => ListTile(
                    title: AppText(filtered[i], fontSize: 15),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCCCCCC)),
                    onTap: () { onSelect(filtered[i]); setState(() => _searchQuery = ''); Navigator.pop(ctx); },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ).then((_) => setState(() => _searchQuery = ''));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primaryColor, onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
        _dobError = null;
      });
    }
  }
}
