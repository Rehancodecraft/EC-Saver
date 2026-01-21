import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  double? _bmiResult;
  String _bmiCategory = '';
  Color _categoryColor = Colors.grey;
  
  // Height unit selection: 'cm', 'inches', 'feet'
  String _heightUnit = 'cm';
  
  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
  
  void _calculateBMI() {
    if (_formKey.currentState!.validate()) {
      double heightInMeters;
      
      // Convert height to meters based on selected unit
      if (_heightUnit == 'cm') {
        heightInMeters = double.parse(_heightController.text) / 100;
      } else if (_heightUnit == 'inches') {
        heightInMeters = double.parse(_heightController.text) * 0.0254; // 1 inch = 0.0254 meters
      } else { // feet
        heightInMeters = double.parse(_heightController.text) * 0.3048; // 1 foot = 0.3048 meters
      }
      
      final weight = double.parse(_weightController.text);
      
      setState(() {
        _bmiResult = weight / (heightInMeters * heightInMeters);
        _updateBMICategory();
      });
    }
  }
  
  void _updateBMICategory() {
    if (_bmiResult == null) return;
    
    if (_bmiResult! < 18.5) {
      _bmiCategory = 'Underweight';
      _categoryColor = Colors.blue;
    } else if (_bmiResult! < 25) {
      _bmiCategory = 'Normal';
      _categoryColor = Colors.green;
    } else if (_bmiResult! < 30) {
      _bmiCategory = 'Overweight';
      _categoryColor = Colors.orange;
    } else {
      _bmiCategory = 'Obese';
      _categoryColor = Colors.red;
    }
  }
  
  void _resetForm() {
    setState(() {
      _heightController.clear();
      _weightController.clear();
      _bmiResult = null;
      _bmiCategory = '';
      _categoryColor = Colors.grey;
      _heightUnit = 'cm'; // Reset to default unit
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Body Mass Index Calculator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Enter your height and weight to calculate your BMI',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Height Unit Selector
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Height Unit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('cm', style: TextStyle(fontSize: 14)),
                            value: 'cm',
                            groupValue: _heightUnit,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() {
                                _heightUnit = value!;
                                _heightController.clear();
                                _bmiResult = null;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Inch', style: TextStyle(fontSize: 14)),
                            value: 'inches',
                            groupValue: _heightUnit,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() {
                                _heightUnit = value!;
                                _heightController.clear();
                                _bmiResult = null;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Feet', style: TextStyle(fontSize: 14)),
                            value: 'feet',
                            groupValue: _heightUnit,
                            activeColor: Colors.orange,
                            onChanged: (value) {
                              setState(() {
                                _heightUnit = value!;
                                _heightController.clear();
                                _bmiResult = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Height Input
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Height ($_heightUnit)',
                  hintText: _heightUnit == 'cm' 
                      ? 'e.g., 170' 
                      : _heightUnit == 'inches' 
                          ? 'e.g., 67' 
                          : 'e.g., 5.6',
                  prefixIcon: const Icon(Icons.height, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  final height = double.tryParse(value);
                  if (height == null) {
                    return 'Please enter a valid number';
                  }
                  
                  // Validate based on selected unit
                  if (_heightUnit == 'cm') {
                    if (height < 50 || height > 300) {
                      return 'Please enter height between 50-300 cm';
                    }
                  } else if (_heightUnit == 'inches') {
                    if (height < 20 || height > 120) {
                      return 'Please enter height between 20-120 inch';
                    }
                  } else { // feet
                    if (height < 1.5 || height > 10) {
                      return 'Please enter height between 1.5-10 feet';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Weight Input
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  hintText: 'e.g., 70',
                  prefixIcon: const Icon(Icons.monitor_weight, color: Colors.orange),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight < 20 || weight > 300) {
                    return 'Please enter a valid weight (20-300 kg)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Calculate Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Calculate BMI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Reset Button
              SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: _resetForm,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Result Card
              if (_bmiResult != null)
                AnimatedOpacity(
                  opacity: _bmiResult != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _categoryColor.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your BMI',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _bmiResult!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: _categoryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: _categoryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _bmiCategory,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BMI Categories:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildCategoryRow('Underweight', '< 18.5', Colors.blue),
                              _buildCategoryRow('Normal', '18.5 - 24.9', Colors.green),
                              _buildCategoryRow('Overweight', '25 - 29.9', Colors.orange),
                              _buildCategoryRow('Obese', '≥ 30', Colors.red),
                            ],
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
    );
  }
  
  Widget _buildCategoryRow(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
