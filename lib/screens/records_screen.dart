import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emergency.dart';
import '../models/off_day.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';
import '../utils/constants.dart';
import '../widgets/emergency_card.dart';
import '../widgets/drawer_menu.dart'; // Import DrawerMenu

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  Map<String, List<Emergency>> _groupedEmergencies = {};
  Map<String, List<OffDay>> _groupedOffDays = {};
  bool _isLoading = true;
  String? _selectedFilter;
  String? _selectedMonth;
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  List<String> _availableMonths = [];
  bool _isSelectionMode = false;
  Set<String> _selectedMonths = {};
  List<String> _allMonths = [];

  final DatabaseService _databaseService = DatabaseService(); // Initialize here

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _generateAllMonths();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _generateAllMonths() {
    // Don't generate default months - leave empty
    // Months will only show if they have data
    setState(() {
      _allMonths = [];
    });
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);

    try {
      final dbService = DatabaseService();
      List<Emergency> emergencies;

      // Get all emergencies first
      if (_searchController.text.isNotEmpty) {
        emergencies = await dbService.searchEmergencies(_searchController.text);
      } else if (_selectedFilter != null) {
        emergencies = await dbService.filterEmergenciesByType(_selectedFilter!);
      } else {
        emergencies = await dbService.getAllEmergencies();
      }

      // Apply date filter if selected
      if (_selectedDate != null) {
        final selectedDate = _selectedDate!;
        final startOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
        final endOfDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day, 23, 59, 59);
        emergencies = emergencies.where((e) {
          return e.emergencyDate.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                 e.emergencyDate.isBefore(endOfDay.add(const Duration(seconds: 1)));
        }).toList();
      }

      // Apply month filter if selected
      if (_selectedMonth != null) {
        final monthYear = _selectedMonth!;
        emergencies = emergencies.where((e) {
          return e.getMonthYear() == monthYear;
        }).toList();
      }

      // Group by month
      final Map<String, List<Emergency>> grouped = {};
      for (final emergency in emergencies) {
        final monthYear = emergency.getMonthYear();
        if (!grouped.containsKey(monthYear)) {
          grouped[monthYear] = [];
        }
        grouped[monthYear]!.add(emergency);
      }

      // Load off days and group by month
      final offDays = await _databaseService.getOffDays();
      final Map<String, List<OffDay>> groupedOffDays = {};
      for (final offDay in offDays) {
        final monthYear = offDay.getMonthYear();
        if (!groupedOffDays.containsKey(monthYear)) {
          groupedOffDays[monthYear] = [];
        }
        groupedOffDays[monthYear]!.add(offDay);
      }

      // Extract months that have data and sort DESCENDING (newest first)
      final uniqueMonths = grouped.keys.toList();
      uniqueMonths.sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA); // DESCENDING order (Nov 2025 before Jul 2024)
      });

      setState(() {
        _groupedEmergencies = grouped;
        _groupedOffDays = groupedOffDays;
        _allMonths = uniqueMonths;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading records: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _selectMonth() async {
    // Load all records first to get available months
    final dbService = DatabaseService();
    final allEmergencies = await dbService.getAllEmergencies();
    
    // Get unique months
    final Set<String> uniqueMonths = {};
    for (final emergency in allEmergencies) {
      uniqueMonths.add(emergency.getMonthYear());
    }
    
    final availableMonths = uniqueMonths.toList()..sort((a, b) {
      try {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA); // Newest first
      } catch (e) {
        return b.compareTo(a);
      }
    });

    if (availableMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No months available')),
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
        _selectedDate = null; // Clear date filter when month is selected
      });
      _loadRecords();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
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
        _selectedDate = picked;
        _selectedMonth = null; // Clear month filter when date is selected
      });
      _loadRecords();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedMonth = null;
      _selectedDate = null;
      _selectedFilter = null;
      _searchController.clear();
    });
    _loadRecords();
  }

  String _formatMonthYear(String monthYear) {
    final parts = monthYear.split('-');
    if (parts.length != 2) return monthYear;

    final year = parts[0];
    final month = int.parse(parts[1]);

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return '${monthNames[month - 1]} $year';
  }

  Future<void> _deleteMonthRecords(String monthYear) async {
    final monthStats = _groupedEmergencies[monthYear];
    if (monthStats == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Month Records'),
        content: Text(
          'Are you sure you want to delete all ${monthStats.length} emergencies from '
          '${_formatMonthYear(monthYear)}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Second confirmation
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'This will permanently delete all records. Are you absolutely sure?',
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
            child: const Text('Yes, Delete'),
          ),
        ],
      ),
    );

    if (doubleConfirmed != true) return;

    try {
      await DatabaseService().deleteEmergenciesByMonth(monthYear);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_formatMonthYear(monthYear)} records deleted'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        _loadRecords();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting records: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedMonths.clear();
      }
    });
  }

  void _toggleMonthSelection(String month) {
    setState(() {
      if (_selectedMonths.contains(month)) {
        _selectedMonths.remove(month);
      } else {
        _selectedMonths.add(month);
      }
    });
  }

  Future<void> _deleteSelectedMonths() async {
    if (_selectedMonths.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Records'),
        content: Text('Delete ${_selectedMonths.length} month(s) of records?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        for (final month in _selectedMonths) {
          await DatabaseService().deleteEmergenciesByMonth(month);
        }
        
        setState(() {
          _selectedMonths.clear();
          _isSelectionMode = false;
        });
        
        _loadRecords();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected months deleted successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteEmergency(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record'),
        content: const Text('Are you sure you want to delete this emergency record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteEmergency(id);
        await _loadRecords(); // Reload after delete
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record deleted successfully'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  Future<void> _showPrintDialog() async {
    if (_allMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records to print')),
      );
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Print Records'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.select_all, color: AppColors.primaryRed),
              title: const Text('Print All Months'),
              onTap: () => Navigator.pop(context, 'all'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: AppColors.secondaryGreen),
              title: const Text('Select Month(s)'),
              onTap: () => Navigator.pop(context, 'select'),
            ),
          ],
        ),
      ),
    );

    if (result == 'all') {
      _printAllMonths();
    } else if (result == 'select') {
      _selectMonthsToPrint();
    }
  }

  Future<void> _printAllMonths() async {
    try {
      await PdfService.generateAndPrintPdf(
        groupedEmergencies: _groupedEmergencies,
        selectedMonths: _allMonths,
        title: 'All Records',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _selectMonthsToPrint() async {
    final selectedMonths = <String>[];
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Months to Print'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _allMonths.length,
              itemBuilder: (context, index) {
                final month = _allMonths[index];
                final isSelected = selectedMonths.contains(month);
                return CheckboxListTile(
                  title: Text(month),
                  subtitle: Text('${_groupedEmergencies[month]?.length ?? 0} records'),
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        selectedMonths.add(month);
                      } else {
                        selectedMonths.remove(month);
                      }
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedMonths.isEmpty 
                  ? null 
                  : () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
              ),
              child: const Text('Print'),
            ),
          ],
        ),
      ),
    );

    if (result == true && selectedMonths.isNotEmpty) {
      try {
        await PdfService.generateAndPrintPdf(
          groupedEmergencies: _groupedEmergencies,
          selectedMonths: selectedMonths,
          title: 'Selected Months',
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating PDF: $e'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters = _selectedMonth != null || 
                      _selectedDate != null || 
                      _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _showPrintDialog,
            tooltip: 'Print Records',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecords,
          ),
        ],
      ),
      drawer: const DrawerMenu(currentRoute: '/records'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _loadRecords(),
                    decoration: InputDecoration(
                      hintText: 'Search by EC',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _loadRecords();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Filter Buttons - ONLY Month and Date
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    children: [
                      // Filter by Month Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectMonth,
                          icon: const Icon(Icons.calendar_month, size: 18),
                          label: Text(
                            _selectedMonth != null 
                                ? _formatMonthYear(_selectedMonth!) 
                                : 'Filter by Month',
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
                      
                      // Filter by Date Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.event, size: 18),
                          label: Text(
                            _selectedDate != null 
                                ? DateFormat('dd MMM yyyy').format(_selectedDate!) 
                                : 'Filter by Date',
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _selectedDate != null 
                                ? AppColors.primaryRed 
                                : Colors.grey[700],
                            side: BorderSide(
                              color: _selectedDate != null 
                                  ? AppColors.primaryRed 
                                  : Colors.grey[400]!,
                            ),
                          ),
                        ),
                      ),
                      
                      // Clear Filters Button (if any filter is active)
                      if (hasFilters) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear),
                          color: AppColors.errorRed,
                          tooltip: 'Clear Filters',
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.md),

                // Records List
                Expanded(
                  child: _allMonths.isEmpty
                      ? const Center(
                          child: Text(
                            'No records found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _allMonths.length,
                          itemBuilder: (context, index) {
                            final month = _allMonths[index];
                            final emergencies = _groupedEmergencies[month] ?? [];
                            final hasRecords = emergencies.isNotEmpty;

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  // Month Header with Delete Button
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: hasRecords 
                                          ? AppColors.primaryRed.withOpacity(0.1)
                                          : Colors.grey[100],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_month,
                                          color: hasRecords ? AppColors.primaryRed : Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            month,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: hasRecords ? AppColors.textDark : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: hasRecords ? AppColors.primaryRed : Colors.grey,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${emergencies.length}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Delete Button
                                        if (hasRecords)
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline),
                                            color: AppColors.errorRed,
                                            onPressed: () => _deleteMonthRecords(month),
                                            tooltip: 'Delete Month',
                                          ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Records List
                                  if (hasRecords)
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        children: _buildDateWiseRecords(emergencies, month),
                                      ),
                                    )
                                  else
                                    const Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text(
                                        'No records for this month',
                                        style: TextStyle(color: Colors.grey, fontSize: 14),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
    );
  }

  // Build date-wise records method
  List<Widget> _buildDateWiseRecords(List<Emergency> emergencies, String monthYear) {
    // Group emergencies by date
    final Map<String, List<Emergency>> dateGroups = {};
    
    for (final emergency in emergencies) {
      final dateKey = DateFormat('dd MMM yyyy').format(emergency.emergencyDate);
      if (!dateGroups.containsKey(dateKey)) {
        dateGroups[dateKey] = [];
      }
      dateGroups[dateKey]!.add(emergency);
    }

    // Get off days for this month
    final offDaysForMonth = _groupedOffDays[monthYear] ?? [];
    final Map<String, OffDay> offDaysByDate = {};
    for (final offDay in offDaysForMonth) {
      final dateKey = offDay.getFormattedDate();
      offDaysByDate[dateKey] = offDay;
    }

    // Combine dates (emergencies + off days)
    final Set<String> allDates = {};
    allDates.addAll(dateGroups.keys);
    allDates.addAll(offDaysByDate.keys);

    // Sort dates in descending order (latest first)
    final sortedDates = allDates.toList()
      ..sort((a, b) {
        final dateA = DateFormat('dd MMM yyyy').parse(a);
        final dateB = DateFormat('dd MMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    // Build widgets
    final List<Widget> widgets = [];

    for (final dateKey in sortedDates) {
      final records = dateGroups[dateKey] ?? [];
      final offDay = offDaysByDate[dateKey];

      // Date Header
      widgets.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.only(bottom: 8, top: 12),
          decoration: BoxDecoration(
            color: offDay != null 
                ? Colors.orange.withOpacity(0.1)
                : AppColors.primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                offDay != null ? Icons.event_busy : Icons.calendar_today,
                size: 16,
                color: offDay != null ? Colors.orange : AppColors.primaryRed,
              ),
              const SizedBox(width: 8),
              Text(
                dateKey,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: offDay != null ? Colors.orange : AppColors.primaryRed,
                ),
              ),
              if (offDay != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'OFF DAY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (records.isNotEmpty)
                Text(
                  '${records.length} record${records.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      );

      // Show off day info if it's an off day
      if (offDay != null) {
        widgets.add(
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_busy, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Off Day - No Entries',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      if (offDay.notes != null && offDay.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          offDay.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Table for this date (only if there are records)
      if (records.isNotEmpty) {
        widgets.add(
          Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'EC Number',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Type',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Table Rows
              ...records.asMap().entries.map((entry) {
                final index = entry.key;
                final emergency = entry.value;
                final isLast = index == records.length - 1;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : Colors.grey[50],
                    border: Border(
                      bottom: isLast 
                          ? BorderSide.none 
                          : BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          emergency.ecNumber,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          emergency.emergencyType,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        );
      }
    }

    return widgets;
  }
}
