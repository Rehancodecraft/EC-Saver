import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/emergency.dart';
import '../models/off_day.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class EmergencyFormScreen extends StatefulWidget {
  final String? preSelectedType;

  const EmergencyFormScreen({
    super.key,
    this.preSelectedType,
  });

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

  // Entry type: 'emergency', 'off-day', 'leave', 'gazetted-day'
  String _entryType = 'emergency';

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
      // For emergency entries, check EC number and type
      // For off days/leave/gazetted, only check if date is selected
      if (_entryType == 'emergency') {
        _hasInput = _ecNumberController.text.isNotEmpty ||
            _emergencyTypeController.text.isNotEmpty ||
            _notesController.text.isNotEmpty;
      } else {
        _hasInput = _selectedDate != null;
      }
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
    // For emergency entries: no future dates allowed
    // For off days/leaves/gazetted holidays: allow future dates (up to 1 year ahead)
    final DateTime maxDate = _entryType == 'emergency' 
        ? DateTime.now() 
        : DateTime.now().add(const Duration(days: 365));
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: maxDate,
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
      // Check if selected date is an off day (only for emergency entries)
      if (_entryType == 'emergency') {
        final isOffDay = await _databaseService.isOffDay(picked);
        if (isOffDay) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'This date (${picked.day}/${picked.month}/${picked.year}) is marked as an off day. Cannot add emergency entry on this date.',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return; // Don't set the date if it's an off day
        }
        // Allow multiple emergency entries on the same date
      } else {
        // For off days/leave/gazetted: Check if date already has an emergency entry
        final emergencies = await _databaseService.getAllEmergencies();
        final hasEmergency = emergencies.any((e) {
          final eDate = e.emergencyDate;
          return eDate.year == picked.year &&
                 eDate.month == picked.month &&
                 eDate.day == picked.day;
        });
        
        if (hasEmergency) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'This date already has an emergency entry. Cannot mark as ${_entryType == 'off-day' ? 'day-off' : _entryType == 'leave' ? 'leave' : 'gazetted holiday'}.',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        // Note: We allow updating existing off days (no check needed)
      }

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
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate emergency entry fields
    if (_entryType == 'emergency') {
      if (!_formKey.currentState!.validate()) {
        print('DEBUG: Form validation failed');
        return;
      }

      // Check if selected date is an off day (cannot add emergency on off days)
      final isOffDay = await _databaseService.isOffDay(_selectedDate!);
      if (isOffDay) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Cannot add entry on ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} - This day is marked as an off day',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      // Allow multiple emergency entries on the same date
    } else {
      // For off days, check if date already has an emergency entry
      final emergencies = await _databaseService.getAllEmergencies();
      final hasEmergency = emergencies.any((e) {
        final eDate = e.emergencyDate;
        return eDate.year == _selectedDate!.year &&
               eDate.month == _selectedDate!.month &&
               eDate.day == _selectedDate!.day;
      });
      
      if (hasEmergency) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This date already has an emergency entry. Cannot mark as off day.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      if (_entryType == 'emergency') {
        // Save as emergency entry
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
          Navigator.pop(context, true);
        }
      } else {
        // Save as off day
        String typeLabel = '';
        switch (_entryType) {
          case 'off-day':
            typeLabel = 'Day-off';
            break;
          case 'leave':
            typeLabel = 'Leave';
            break;
          case 'gazetted-day':
            typeLabel = 'Gazetted Holiday';
            break;
        }

        final offDay = OffDay(
          offDate: _selectedDate!,
          notes: typeLabel + (_notesController.text.trim().isNotEmpty 
              ? ' - ${_notesController.text.trim()}' 
              : ''),
          createdAt: DateTime.now(),
        );

        // Check if off day already exists for this date
        final existingOffDay = await _databaseService.getOffDayByDate(_selectedDate!);
        if (existingOffDay != null) {
          // Update existing off day
          await _databaseService.deleteOffDay(existingOffDay.id!);
        }

        final id = await _databaseService.saveOffDay(offDay);
        
        print('DEBUG: Off day saved successfully with ID: $id');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$typeLabel saved successfully!'),
              backgroundColor: AppColors.secondaryGreen,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('DEBUG: Error in _saveEmergency: $e');
      print('DEBUG: Error type: ${e.runtimeType}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
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
                // Entry Type Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _entryType,
                  decoration: InputDecoration(
                    labelText: 'Entry Type',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'emergency',
                      child: Text('Emergency Entry'),
                    ),
                    DropdownMenuItem(
                      value: 'off-day',
                      child: Text('Day-off'),
                    ),
                    DropdownMenuItem(
                      value: 'leave',
                      child: Text('Leave'),
                    ),
                    DropdownMenuItem(
                      value: 'gazetted-day',
                      child: Text('Gazetted Holiday'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _entryType = value!;
                      // Clear EC number when switching to off day types
                      if (_entryType != 'emergency') {
                        _ecNumberController.clear();
                        _emergencyTypeController.clear();
                      }
                      _checkFormInput();
                    });
                  },
                ),

                const SizedBox(height: 16),

                // EC Number (Disabled for off days)
                TextFormField(
                  controller: _ecNumberController,
                  enabled: _entryType == 'emergency',
                  decoration: InputDecoration(
                    labelText: 'EC Number',
                    prefixIcon: const Icon(Icons.numbers),
                    hintText: _entryType == 'emergency' ? '123456' : 'Not required for ${_entryType == 'off-day' ? 'Day-off' : _entryType == 'leave' ? 'Leave' : 'Gazetted Holiday'}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: _entryType != 'emergency',
                    fillColor: _entryType != 'emergency' ? Colors.grey[200] : null,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (_entryType == 'emergency') {
                      if (value == null || value.isEmpty) {
                        return 'Please enter EC number';
                      }
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

                // Emergency Type (Only for emergency entries)
                if (_entryType == 'emergency')
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
                      if (_entryType == 'emergency') {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter emergency type';
                        }
                        final words = value.trim().split(' ');
                        if (words.length > 2) {
                          return 'Maximum 2 words allowed';
                        }
                      }
                      return null;
                    },
                  ),

                if (_entryType == 'emergency') const SizedBox(height: 16),

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
                                _entryType == 'emergency'
                                    ? (_hasInput ? 'SAVE EMERGENCY' : 'FILL FORM TO SAVE')
                                    : (_hasInput ? 'SAVE ${_entryType == 'off-day' ? 'DAY-OFF' : _entryType == 'leave' ? 'LEAVE' : 'GAZETTED HOLIDAY'}' : 'SELECT DATE TO SAVE'),
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
