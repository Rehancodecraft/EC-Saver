import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../utils/districts_data.dart';
import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  String? _selectedDesignation;
  String? _selectedDistrict;
  String? _selectedTehsil;
  List<String> _tehsils = [];

  bool _showOtpField = false;
  bool _isLoading = false;
  int _otpTimer = ValidationConstants.otpTimeoutSeconds;
  Timer? _timer;
  String _generatedOtp = '';

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onDistrictChanged(String? district) {
    setState(() {
      _selectedDistrict = district;
      _selectedTehsil = null;
      _tehsils = district != null ? getTehsils(district) : [];
    });
  }

  void _startOtpTimer() {
    _timer?.cancel();
    setState(() {
      _otpTimer = ValidationConstants.otpTimeoutSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_otpTimer > 0) {
          _otpTimer--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _generateOtp() {
    // In production, this would be sent via SMS
    // For demo, we generate a random 6-digit code
    return '123456'; // Simplified for demo - always returns same OTP
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate SMS sending delay
    await Future.delayed(const Duration(seconds: 1));

    _generatedOtp = _generateOtp();
    
    setState(() {
      _showOtpField = true;
      _isLoading = false;
    });

    _startOtpTimer();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to ${_mobileController.text}\nDemo OTP: $_generatedOtp'),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _verifyAndRegister() async {
    if (_otpController.text != _generatedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final profile = UserProfile(
        fullName: _nameController.text.trim(),
        designation: _selectedDesignation!,
        district: _selectedDistrict!,
        tehsil: _selectedTehsil!,
        mobileNumber: _mobileController.text.trim(),
        registrationDate: DateTime.now(),
        isVerified: true,
      );

      await DatabaseService().insertUserProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful! Welcome to Rescue 1122'),
            backgroundColor: AppColors.successGreen,
            duration: Duration(seconds: 3),
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Registration'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Heading
                const Text(
                  'Register as Rescue 1122 Personnel',
                  style: AppTextStyles.subheading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Complete your profile to start using the app',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Full Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !_showOtpField,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < ValidationConstants.minNameLength) {
                      return 'Name must be at least ${ValidationConstants.minNameLength} characters';
                    }
                    if (value.trim().length > ValidationConstants.maxNameLength) {
                      return 'Name must not exceed ${ValidationConstants.maxNameLength} characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Designation
                DropdownButtonFormField<String>(
                  value: _selectedDesignation,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                    hintText: 'Select your designation',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  items: Designations.all.map((designation) {
                    return DropdownMenuItem(
                      value: designation,
                      child: Text(designation),
                    );
                  }).toList(),
                  onChanged: _showOtpField ? null : (value) {
                    setState(() {
                      _selectedDesignation = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your designation';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // District
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    hintText: 'Select your district',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: getDistricts().map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: _showOtpField ? null : _onDistrictChanged,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your district';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Tehsil
                DropdownButtonFormField<String>(
                  value: _selectedTehsil,
                  decoration: const InputDecoration(
                    labelText: 'Tehsil',
                    hintText: 'Select your tehsil',
                    prefixIcon: Icon(Icons.place),
                  ),
                  items: _tehsils.map((tehsil) {
                    return DropdownMenuItem(
                      value: tehsil,
                      child: Text(tehsil),
                    );
                  }).toList(),
                  onChanged: _showOtpField ? null : (value) {
                    setState(() {
                      _selectedTehsil = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your tehsil';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Mobile Number
                TextFormField(
                  controller: _mobileController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: '+92 3XX XXXXXXX',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  enabled: !_showOtpField,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.length != ValidationConstants.mobileNumberLength) {
                      return 'Mobile number must be ${ValidationConstants.mobileNumberLength} digits';
                    }
                    if (!value.startsWith('03')) {
                      return 'Mobile number must start with 03';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // OTP Field (shown after sending OTP)
                if (_showOtpField) ...[
                  TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      hintText: '6-digit verification code',
                      prefixIcon: const Icon(Icons.lock),
                      suffixText: _otpTimer > 0 ? '${_otpTimer}s' : 'Expired',
                      suffixStyle: TextStyle(
                        color: _otpTimer > 0 ? AppColors.secondaryGreen : AppColors.errorRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(ValidationConstants.otpLength),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      if (value.length != ValidationConstants.otpLength) {
                        return 'OTP must be ${ValidationConstants.otpLength} digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Resend OTP
                  if (_otpTimer == 0)
                    TextButton(
                      onPressed: _sendOtp,
                      child: const Text('Resend OTP'),
                    ),

                  const SizedBox(height: AppSpacing.md),

                  // Verify Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyAndRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Verify & Register'),
                  ),
                ] else ...[
                  // Send OTP Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Send OTP'),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                // Note
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: AppColors.textLight),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'This is a one-time registration. Your profile will be saved locally.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
