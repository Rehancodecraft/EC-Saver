import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/emergency.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class EmergencyFormScreen extends StatefulWidget {
  final String? preSelectedType;

  const EmergencyFormScreen({
    Key? key,
    this.preSelectedType,
  }) : super(key: key);

  @override
  State<EmergencyFormScreen> createState() => _EmergencyFormScreenState();
}

class _EmergencyFormScreenState extends State<EmergencyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ecNumberController = TextEditingController();
  final _emergencyTypeController = TextEditingController();
  final _notesController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();

  DateTime? _selectedDate;
  bool _isLateEntry = false;
  bool _isSaving = false;

  // Track if form has any input
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // Listen to form changes
    _ecNumberController.addListener(_checkFormInput);
    _emergencyTypeController.addListener(_checkFormInput);
    _notesController.addListener(_checkFormInput);
  }

  void _checkFormInput() {
    setState(() {
      _hasInput = _ecNumberController.text.isNotEmpty ||
          _emergencyTypeController.text.isNotEmpty ||
          _notesController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _ecNumberController.dispose();
    _emergencyTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final selectedDay = DateTime(picked.year, picked.month, picked.day);
        _isLateEntry = selectedDay.isBefore(today);
      });
    }
  }

  Future<void> _saveEmergency() async {
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    setState(() => _isSaving = true);

    try {
      print('DEBUG: Creating emergency object');
      
      final emergency = Emergency(
        ecNumber: _ecNumberController.text.trim(),
        emergencyDate: _selectedDate!,
        emergencyType: _emergencyTypeController.text.trim(),
        location: null,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
        isLateEntry: _isLateEntry,
        createdAt: DateTime.now(),
        createdBy: null,
      );

      print('DEBUG: Emergency object created - EC: ${emergency.ecNumber}, Type: ${emergency.emergencyType}');
      print('DEBUG: Date: ${emergency.emergencyDate}, Late Entry: ${emergency.isLateEntry}');

      final id = await _databaseService.saveEmergency(emergency);
      
      print('DEBUG: Emergency saved successfully with ID: $id');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emergency case saved successfully! (ID: $id)'),
            backgroundColor: AppColors.secondaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      print('DEBUG: Error in _saveEmergency: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save emergency: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('New Emergency Case'),
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
                // EC Number (Remove * from label)
                TextFormField(
                  controller: _ecNumberController,
                  decoration: InputDecoration(
                    labelText: 'EC Number',
                    prefixIcon: const Icon(Icons.numbers),
                    hintText: '123456',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter EC number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Emergency Date (Change calendar icon color to match others)
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today), // Removed color to match other fields
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Emergency Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Select date',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (_isLateEntry)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Late Entry',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Emergency Type (Remove * from label)
                TextFormField(
                  controller: _emergencyTypeController,
                  decoration: InputDecoration(
                    labelText: 'Emergency Type',
                    prefixIcon: const Icon(Icons.emergency),
                    hintText: 'e.g., Road Accident',
                    helperText: 'Max 2 words, 20 characters',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter emergency type';
                    }
                    final words = value.trim().split(' ');
                    if (words.length > 2) {
                      return 'Maximum 2 words allowed';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Notes (Remove "Optional" text)
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    prefixIcon: const Icon(Icons.note_alt),
                    hintText: 'Additional details...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 4,
                  maxLength: 500,
                ),

                const SizedBox(height: 32),

                // Save Button (Red if no input, Green if has input)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveEmergency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasInput
                          ? AppColors.secondaryGreen
                          : AppColors.primaryRed,
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasInput ? Icons.check_circle_outline : Icons.save,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _hasInput ? 'SAVE EMERGENCY' : 'FILL FORM TO SAVE',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
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
