import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import '../utils/districts_data.dart';
import '../models/user_profile.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  
  String? _selectedDesignation;
  String? _selectedDistrict;
  String? _selectedTehsil;
  
  bool _isRegistering = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _onDistrictChanged(String? district) {
    setState(() {
      _selectedDistrict = district;
      _selectedTehsil = null;
    });
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isRegistering = true);

    try {
      // Check if user already registered locally
      final existingProfile = await _databaseService.getUserProfile();
      if (existingProfile != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are already registered!'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.of(context).pushReplacementNamed('/home');
        }
        return;
      }

      // Try to sync to Supabase FIRST to check for duplicates
      try {
        print('DEBUG: Checking central database for duplicate phone...');
        final result = await SupabaseService.registerUser(
          fullName: _fullNameController.text.trim(),
          designation: _selectedDesignation!,
          district: _selectedDistrict!,
          tehsil: _selectedTehsil!,
          mobileNumber: _mobileController.text.trim(),
        );

        print('DEBUG: Supabase result: $result');

        // If phone number already exists, STOP registration
        if (result['isDuplicate'] == true) {
          if (mounted) {
            setState(() => _isRegistering = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '❌ ${result['message']}\nThis phone number is already in use.',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          return; // STOP - Don't save locally
        }

        // Phone number is unique - proceed with local save
        if (result['success']) {
          print('DEBUG: Phone unique, saving to local database');
          
          final userProfile = UserProfile(
            fullName: _fullNameController.text.trim(),
            designation: _selectedDesignation!,
            district: _selectedDistrict!,
            tehsil: _selectedTehsil!,
            mobileNumber: _mobileController.text.trim(),
            registrationDate: DateTime.now(),
            isVerified: true,
          );
          
          await _databaseService.saveUserProfile(userProfile);
          print('DEBUG: Saved to local database');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(child: Text('✅ Registration successful!')),
                  ],
                ),
                backgroundColor: AppColors.secondaryGreen,
                duration: Duration(seconds: 2),
              ),
            );
            Navigator.of(context).pushReplacementNamed('/home');
          }
        } else {
          // Supabase failed (network issue) - allow offline registration
          print('DEBUG: Network error, registering offline');
          
          final userProfile = UserProfile(
            fullName: _fullNameController.text.trim(),
            designation: _selectedDesignation!,
            district: _selectedDistrict!,
            tehsil: _selectedTehsil!,
            mobileNumber: _mobileController.text.trim(),
            registrationDate: DateTime.now(),
            isVerified: true,
          );
          
          await _databaseService.saveUserProfile(userProfile);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.offline_bolt, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text('⚠️ ${result['message']}\nRegistered offline.')),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.of(context).pushReplacementNamed('/home');
          }
        }
      } catch (e) {
        print('DEBUG: Exception during registration: $e');
        
        if (mounted) {
          setState(() => _isRegistering = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
    } catch (e) {
      print('DEBUG: Local database error: $e');
      if (mounted) {
        setState(() => _isRegistering = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rescue 1122 Logo at top
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Image.asset(
                      'assets/image/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.local_hospital,
                          size: 60,
                          color: AppColors.primaryRed,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Rescue 1122',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please register to continue',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Designation Dropdown (Short forms only)
                DropdownButtonFormField<String>(
                  value: _selectedDesignation,
                  decoration: InputDecoration(
                    labelText: 'Designation *',
                    prefixIcon: const Icon(Icons.work),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: Designations.all.map((designation) {
                    return DropdownMenuItem(
                      value: designation,
                      child: Text(designation),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedDesignation = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your designation';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // District Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: InputDecoration(
                    labelText: 'District *',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: () {
                    final districts = Districts.getAllDistricts();
                    districts.sort(); // Sort in place
                    return districts.map((district) => DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    )).toList();
                  }(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedTehsil = null;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a district';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Tehsil Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedTehsil,
                  decoration: InputDecoration(
                    labelText: 'Tehsil *',
                    prefixIcon: const Icon(Icons.map),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _selectedDistrict != null
                      ? Districts.getTehsilsByDistrict(_selectedDistrict!)
                          .map((tehsil) => DropdownMenuItem(
                                value: tehsil,
                                child: Text(tehsil),
                              ))
                          .toList()
                      : [],
                  onChanged: _selectedDistrict != null
                      ? (value) {
                          setState(() {
                            _selectedTehsil = value;
                          });
                        }
                      : null,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a tehsil';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Mobile Number with +92 prefix
                TextFormField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number *',
                    prefixIcon: const Icon(Icons.phone),
                    prefixText: '+92 ',
                    hintText: '3001234567',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
                    if (!value.startsWith('3')) {
                      return 'Mobile number must start with 3';
                    }
                    // Check if it's a valid Pakistani mobile number
                    final validPrefixes = ['30', '31', '32', '33', '34', '35'];
                    if (!validPrefixes.any((prefix) => value.startsWith(prefix))) {
                      return 'Invalid Pakistani mobile number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isRegistering ? null : _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryGreen,
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isRegistering
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'REGISTER',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Internet Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Internet Recommended',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Registration works offline. Internet needed for central database sync.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
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
          ),
        ),
      ),
    );
  }
}
