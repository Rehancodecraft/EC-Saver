import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import '../utils/districts_data.dart';
import '../models/user_profile.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

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
      // CRITICAL: Check internet connectivity FIRST - no offline registration allowed
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = connectivityResult.contains(ConnectivityResult.mobile) ||
                          connectivityResult.contains(ConnectivityResult.wifi) ||
                          connectivityResult.contains(ConnectivityResult.ethernet);
      
      if (!hasInternet) {
        if (mounted) {
          setState(() => _isRegistering = false);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.red),
                  SizedBox(width: 12),
                  Text('No Internet Connection'),
                ],
              ),
              content: const Text(
                'Registration requires an active internet connection to verify your details in the central database.\n\nPlease connect to the internet and try again.',
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

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

        // If phone number already exists, load existing account and continue
        if (result['isDuplicate'] == true && result['existingUser'] != null) {
          print('DEBUG: Account already exists, loading existing user data');
          
          try {
            // Get existing user data from Supabase
            final existingUserData = result['existingUser'] as Map<String, dynamic>;
            
            // Convert Supabase format (snake_case) to UserProfile format
            // Use existing user data from Supabase as source of truth
            final userProfile = UserProfile(
              fullName: (existingUserData['full_name'] as String?)?.trim() ?? _fullNameController.text.trim(),
              designation: (existingUserData['designation'] as String?) ?? _selectedDesignation ?? '',
              district: (existingUserData['district'] as String?) ?? _selectedDistrict ?? '',
              tehsil: (existingUserData['tehsil'] as String?) ?? _selectedTehsil ?? '',
              mobileNumber: (existingUserData['mobile_number'] as String?) ?? _mobileController.text.trim(),
              registrationDate: existingUserData['registration_date'] != null
                  ? DateTime.parse(existingUserData['registration_date'] as String)
                  : DateTime.now(),
              isVerified: true,
            );
            
            // Save existing user to local database
            await _databaseService.saveUserProfile(userProfile);
            print('DEBUG: ✅ Existing user profile saved to local database');
            
            if (mounted) {
              setState(() => _isRegistering = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '✅ ${result['message']}\nContinuing with your existing account.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.medicalBlue,
                  duration: const Duration(seconds: 3),
                ),
              );
              Navigator.of(context).pushReplacementNamed('/home');
            }
            return; // Continue with existing account
          } catch (e) {
            print('DEBUG: Error loading existing user: $e');
            if (mounted) {
              setState(() => _isRegistering = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading existing account: ${e.toString()}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
            return;
          }
        }
        
        // If duplicate but no existing user data, show error
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
                        '❌ ${result['message']}\nUnable to load existing account.',
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
          return;
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
          // Network error - should not happen since we checked connectivity above
          // But if it does, block offline registration
          print('DEBUG: Network error during Supabase sync');
          
          if (mounted) {
            setState(() => _isRegistering = false);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Registration Failed'),
                  ],
                ),
                content: Text(
                  'Unable to connect to the central database.\n\n${result['message']}\n\nPlease check your internet connection and try again.',
                  style: const TextStyle(fontSize: 15),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
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
                        'Welcome to Emergency Cases Saver',
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
                  initialValue: _selectedDesignation,
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
                  initialValue: _selectedDistrict,
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
                  initialValue: _selectedTehsil,
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
                
                // Internet Required Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi, color: Colors.red[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Internet Required',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Active internet connection is required for registration to verify details in central database.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[700],
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
