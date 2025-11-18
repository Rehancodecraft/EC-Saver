import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/emergency.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/emergency_card.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  Map<String, List<Emergency>> _groupedEmergencies = {};
  bool _isLoading = true;
  String? _selectedFilter;
  String? _selectedMonth;
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  List<String> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _loadEmergencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmergencies() async {
    setState(() => _isLoading = true);

    try {
      final dbService = DatabaseService();
      List<Emergency> emergencies;

      // Apply search
      if (_searchController.text.isNotEmpty) {
        emergencies = await dbService.searchEmergencies(_searchController.text);
      } else if (_selectedFilter != null && _selectedFilter != 'All') {
        emergencies = await dbService.filterEmergenciesByType(_selectedFilter!);
      } else {
        emergencies = await dbService.getAllEmergencies();
      }

      // Apply month filter
      if (_selectedMonth != null) {
        emergencies = emergencies.where((e) => e.getMonthYear() == _selectedMonth).toList();
      }

      // Apply date filter
      if (_selectedDate != null) {
        final filterDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        emergencies = emergencies.where((e) {
          final eDate = DateTime(
            e.emergencyDate.year,
            e.emergencyDate.month,
            e.emergencyDate.day,
          );
          return eDate == filterDate;
        }).toList();
      }

      // Group by month
      final Map<String, List<Emergency>> grouped = {};
      final Set<String> months = {};
      
      for (var emergency in emergencies) {
        final monthYear = emergency.getMonthYear();
        months.add(monthYear);
        
        if (!grouped.containsKey(monthYear)) {
          grouped[monthYear] = [];
        }
        grouped[monthYear]!.add(emergency);
      }

      // Sort months descending
      _availableMonths = months.toList()..sort((a, b) => b.compareTo(a));

      setState(() {
        _groupedEmergencies = grouped;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectMonth() async {
    if (_availableMonths.isEmpty) {
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
            itemCount: _availableMonths.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return ListTile(
                  title: const Text('All Months'),
                  onTap: () => Navigator.pop(context, 'all'),
                );
              }
              final month = _availableMonths[index - 1];
              return ListTile(
                title: Text(_formatMonthYear(month)),
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
      _loadEmergencies();
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
      });
      _loadEmergencies();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedMonth = null;
      _selectedDate = null;
      _selectedFilter = null;
      _searchController.clear();
    });
    _loadEmergencies();
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
        _loadEmergencies();
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

  @override
  Widget build(BuildContext context) {
    final hasFilters = _selectedMonth != null || 
                      _selectedDate != null || 
                      _selectedFilter != null ||
                      _searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmergencies,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by EC number, location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadEmergencies();
                        },
                      )
                    : null,
              ),
              onChanged: (value) => _loadEmergencies(),
            ),
          ),

          // Filter Buttons Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectMonth,
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(
                      _selectedMonth != null 
                          ? _formatMonthYear(_selectedMonth!)
                          : 'Filter by Month',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _selectedMonth != null 
                          ? AppColors.primaryRed 
                          : AppColors.textDark,
                      side: BorderSide(
                        color: _selectedMonth != null 
                            ? AppColors.primaryRed 
                            : AppColors.dividerColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.event, size: 18),
                    label: Text(
                      _selectedDate != null
                          ? DateFormat('dd-MMM-yyyy').format(_selectedDate!)
                          : 'Filter by Date',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _selectedDate != null 
                          ? AppColors.primaryRed 
                          : AppColors.textDark,
                      side: BorderSide(
                        color: _selectedDate != null 
                            ? AppColors.primaryRed 
                            : AppColors.dividerColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                if (hasFilters)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ActionChip(
                      label: const Text('Clear All'),
                      onPressed: _clearFilters,
                      backgroundColor: AppColors.errorRed.withOpacity(0.1),
                      side: const BorderSide(color: AppColors.errorRed),
                    ),
                  ),
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == null || _selectedFilter == 'All',
                  onSelected: () {
                    setState(() => _selectedFilter = 'All');
                    _loadEmergencies();
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                ...EmergencyType.getAll().map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _FilterChip(
                      label: type,
                      icon: EmergencyType.getIcon(type),
                      color: EmergencyType.getColor(type),
                      isSelected: _selectedFilter == type,
                      onSelected: () {
                        setState(() => _selectedFilter = type);
                        _loadEmergencies();
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),

          // Records List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _groupedEmergencies.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadEmergencies,
                        child: ListView.builder(
                          itemCount: _groupedEmergencies.length,
                          itemBuilder: (context, index) {
                            final monthYear = _groupedEmergencies.keys.elementAt(index);
                            final emergencies = _groupedEmergencies[monthYear]!;

                            return _MonthSection(
                              monthYear: monthYear,
                              emergencies: emergencies,
                              formatMonthYear: _formatMonthYear,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 100,
              color: AppColors.textLight.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No emergencies found',
              style: AppTextStyles.subheading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_selectedMonth != null || _selectedDate != null)
              const Text(
                'Try changing the filter',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              )
            else
              const Text(
                'Tap the button below to record your first emergency',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: (color ?? AppColors.primaryRed).withOpacity(0.2),
      checkmarkColor: color ?? AppColors.primaryRed,
    );
  }
}

class _MonthSection extends StatefulWidget {
  final String monthYear;
  final List<Emergency> emergencies;
  final String Function(String) formatMonthYear;

  const _MonthSection({
    required this.monthYear,
    required this.emergencies,
    required this.formatMonthYear,
  });

  @override
  State<_MonthSection> createState() => _MonthSectionState();
}

class _MonthSectionState extends State<_MonthSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Column(
        children: [
          // Month Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.formatMonthYear(widget.monthYear),
                          style: AppTextStyles.subheading,
                        ),
                        Text(
                          'Total: ${widget.emergencies.length} Emergencies',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),

          // Emergency List
          if (_isExpanded) ...[
            const Divider(height: 1),
            ...widget.emergencies.map((emergency) {
              return EmergencyCard(emergency: emergency);
            }).toList(),
          ],
        ],
      ),
    );
  }
}
