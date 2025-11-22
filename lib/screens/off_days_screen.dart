import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/off_day.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/drawer_menu.dart';

class OffDaysScreen extends StatefulWidget {
  const OffDaysScreen({super.key});

  @override
  State<OffDaysScreen> createState() => _OffDaysScreenState();
}

class _OffDaysScreenState extends State<OffDaysScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<OffDay> _offDays = [];
  bool _isLoading = true;
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _loadOffDays();
  }

  Future<void> _loadOffDays() async {
    setState(() => _isLoading = true);
    try {
      final offDays = await _databaseService.getOffDays();
      setState(() {
        _offDays = offDays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading off days: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _addOffDay() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
      // Check if already exists
      final existing = await _databaseService.isOffDay(picked);
      if (existing) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This date is already marked as an off day'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Show notes dialog
      final notes = await showDialog<String>(
        context: context,
        builder: (context) {
          final notesController = TextEditingController();
          return AlertDialog(
            title: const Text('Add Off Day'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Date: ${DateFormat('dd MMM yyyy').format(picked)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'e.g., Leave, Holiday, etc.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, notesController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                ),
                child: const Text('Add'),
              ),
            ],
          );
        },
      );

      if (notes != null) {
        try {
          final offDay = OffDay(
            offDate: DateTime(picked.year, picked.month, picked.day),
            notes: notes.isEmpty ? null : notes,
            createdAt: DateTime.now(),
          );
          await _databaseService.saveOffDay(offDay);
          await _loadOffDays();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Off day added successfully'),
                backgroundColor: AppColors.successGreen,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error adding off day: $e'),
                backgroundColor: AppColors.errorRed,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteOffDay(OffDay offDay) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Off Day'),
        content: Text(
          'Are you sure you want to remove ${offDay.getFormattedDate()} as an off day?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && offDay.id != null) {
      try {
        await _databaseService.deleteOffDay(offDay.id!);
        await _loadOffDays();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Off day removed successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting off day: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _selectMonth() async {
    final allOffDays = await _databaseService.getOffDays();
    final Set<String> uniqueMonths = {};
    for (final offDay in allOffDays) {
      uniqueMonths.add(offDay.getMonthYear());
    }

    final availableMonths = uniqueMonths.toList()..sort((a, b) {
      try {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      } catch (e) {
        return b.compareTo(a);
      }
    });

    if (availableMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No off days available')),
      );
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableMonths.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('All Months'),
                  onTap: () => Navigator.pop(context, 'all'),
                );
              }
              final month = availableMonths[index - 1];
              return ListTile(
                title: Text(month),
                onTap: () => Navigator.pop(context, month),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedMonth = selected == 'all' ? null : selected;
      });
      _loadOffDays();
    }
  }

  List<OffDay> get _filteredOffDays {
    if (_selectedMonth == null) return _offDays;
    return _offDays.where((offDay) => offDay.getMonthYear() == _selectedMonth).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Off Days'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOffDays,
          ),
        ],
      ),
      drawer: const DrawerMenu(currentRoute: '/off-days'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter and Add Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectMonth,
                          icon: const Icon(Icons.calendar_month, size: 18),
                          label: Text(
                            _selectedMonth ?? 'Filter by Month',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _selectedMonth != null
                                ? AppColors.primaryRed
                                : Colors.grey[700],
                            side: BorderSide(
                              color: _selectedMonth != null
                                  ? AppColors.primaryRed
                                  : Colors.grey[400]!,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _addOffDay,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Off Day'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryRed,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Off Days List
                Expanded(
                  child: _filteredOffDays.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No off days found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap "Add Off Day" to mark a day as off',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredOffDays.length,
                          itemBuilder: (context, index) {
                            final offDay = _filteredOffDays[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.event_busy,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                                title: Text(
                                  offDay.getFormattedDate(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: offDay.notes != null && offDay.notes!.isNotEmpty
                                    ? Text(offDay.notes!)
                                    : null,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: AppColors.errorRed,
                                  onPressed: () => _deleteOffDay(offDay),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addOffDay,
        backgroundColor: AppColors.primaryRed,
        child: const Icon(Icons.add),
      ),
    );
  }
}

