import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/drawer_menu.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      // Save to local database
      await DatabaseService().insertFeedback(
        _nameController.text.trim(),
        _messageController.text.trim(),
      );

      // Prepare email content
      final name = _nameController.text.trim();
      final message = _messageController.text.trim();
      
      final subject = Uri.encodeComponent('EC Saver Feedback - $name');
      final body = Uri.encodeComponent(message);

      // Create mailto URL without queryParameters
      final emailUrl = 'mailto:nexivault@gmail.com?subject=$subject&body=$body';
      final Uri emailUri = Uri.parse(emailUrl);

      bool launched = false;
      
      try {
        launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        print('Error launching email: $e');
      }

      if (mounted) {
        if (launched) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Opening email client...'),
              backgroundColor: AppColors.secondaryGreen,
            ),
          );
          _nameController.clear();
          _messageController.clear();
        } else {
          // Fallback: Show email address to copy
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Email App Not Found'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please send your feedback to:'),
                  const SizedBox(height: 8),
                  const SelectableText(
                    'nexivault@gmail.com',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Subject: EC Saver Feedback - $name'),
                  const SizedBox(height: 8),
                  Text('Message:\n$message'),
                ],
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const DrawerMenu(currentRoute: '/feedback'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Icon(
                    Icons.feedback_outlined,
                    size: 50,
                    color: AppColors.primaryRed,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'We Value Your Feedback',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Help us improve by sharing your thoughts, suggestions, or reporting any issues.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Message Field
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Your Feedback',
                  hintText: 'Share your thoughts, suggestions, or report issues...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Icon(Icons.message_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
                  ),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your feedback';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide detailed feedback (min 10 characters)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendFeedback,
                  icon: _isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, size: 20),
                  label: Text(
                    _isSending ? 'Opening Email...' : 'Send Feedback via Email',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Contact Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.grey[700], size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'Contact Email',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'nexivault@gmail.com',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primaryRed, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your feedback helps us improve the app for all rescuers.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
