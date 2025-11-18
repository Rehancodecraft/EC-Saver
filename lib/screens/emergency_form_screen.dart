import 'package:flutter/material.dart';
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
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now();
  String? _selectedType;
  bool _isLoading = false;
  bool _isLateEntry = false;

  @override
  void initState() {
    super.initState();
    // Pre-select emergency type if provided
    _selectedType = widget.preSelectedType;
    _checkIfLateEntry();
  }

  @override
  void dispose() {
    _ecNumberController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _checkIfLateEntry() {
    final now = DateTime.now();
    final selectedDate = DateTime(
      _selectedDateTime.year,
      _selectedDateTime.month,
      _selectedDateTime.day,
    );
    final today = DateTime(now.year, now.month, now.day);

    setState(() {
      _isLateEntry = selectedDate.isBefore(today);
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select Emergency Date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryRed,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = picked;
        _checkIfLateEntry();
      });
    }
  }

  Future<void> _saveEmergency() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select emergency type'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final emergency = Emergency(
        ecNumber: _ecNumberController.text.trim(),
        emergencyDate: _selectedDateTime,
        emergencyType: _selectedType!,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isLateEntry: _isLateEntry,
        createdAt: DateTime.now(),
        createdBy: 1,
      );

      await DatabaseService().saveEmergency(emergency);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency saved successfully!'),
          backgroundColor: AppColors.successGreen,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formTitle = widget.preSelectedType != null
        ? 'New ${widget.preSelectedType}'
        : 'Enter New Emergency';

    return Scaffold(
      appBar: AppBar(
        title: Text(formTitle),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // EC Number
                    TextFormField(
                      controller: _ecNumberController,
                      decoration: const InputDecoration(
                        labelText: 'EC Number *',
                        hintText: 'Enter 6-digit EC number',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter EC number';
                        }
                        if (value.length != 6) {
                          return 'EC number must be 6 digits';
                        }
                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                          return 'EC number must contain only digits';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Date Picker
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Emergency Date *',
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: _isLateEntry
                              ? const Tooltip(
                                  message: 'Late Entry',
                                  child: Icon(Icons.warning, color: AppColors.errorRed),
                                )
                              : null,
                        ),
                        child: Text(
                          DateFormat('dd-MMM-yyyy').format(_selectedDateTime),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    if (_isLateEntry) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.errorRed),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning, color: AppColors.errorRed, size: 20),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'This is a late entry (past date)',
                                style: TextStyle(
                                  color: AppColors.errorRed,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // Emergency Type - CHECKBOXES
                    const Text(
                      'Emergency Type *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    ...EmergencyType.getAll().map((type) {
                      final isDisabled = widget.preSelectedType != null &&
                          widget.preSelectedType != type;
                      return CheckboxListTile(
                        value: _selectedType == type,
                        onChanged: isDisabled
                            ? null
                            : (bool? value) {
                                setState(() {
                                  _selectedType = value == true ? type : null;
                                });
                              },
                        title: Row(
                          children: [
                            Icon(
                              EmergencyType.getIcon(type),
                              color: EmergencyType.getColor(type),
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              type,
                              style: TextStyle(
                                color: isDisabled
                                    ? AppColors.textLight
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        activeColor: EmergencyType.getColor(type),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),

                    const SizedBox(height: AppSpacing.md),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location (Optional)',
                        hintText: 'Enter location details',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLength: 200,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Additional information',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveEmergency,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: Text(
                        widget.preSelectedType != null
                            ? 'Save ${widget.preSelectedType}'
                            : 'Save Emergency',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
