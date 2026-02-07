import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:courses_app/services/api_service.dart';
import 'package:courses_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStatusPage extends StatefulWidget {
  const OnboardingStatusPage({Key? key}) : super(key: key);

  @override
  _OnboardingStatusPageState createState() => _OnboardingStatusPageState();
}

class _OnboardingStatusPageState extends State<OnboardingStatusPage> {
  String _selectedStatus = 'student';
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  int? _graduationYear;
  bool _isLoading = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'student', 'label': 'طالب', 'icon': 'school'},
    {'value': 'graduate', 'label': 'خريج جامعي', 'icon': 'graduation_cap'},
    {'value': 'employee', 'label': 'موظف', 'icon': 'work'},
    {'value': 'other', 'label': 'أخرى', 'icon': 'more_horiz'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentStatus();
  }

  Future<void> _loadCurrentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    
    if (userId != null) {
      try {
        final response = await ApiService.get('/onboarding/profile?user_id=$userId');
        if (response['success']) {
          final data = response['data'];
          setState(() {
            _selectedStatus = data['status'] ?? 'student';
            _universityController.text = data['university'] ?? '';
            _majorController.text = data['major'] ?? '';
            _graduationYear = data['graduation_year'];
          });
        }
      } catch (e) {
        print('Error loading profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ما هو وضعك الحالي؟',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر الوضع الذي يناسبك',
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              
              // Status Options
              ..._statusOptions.map((status) => _buildStatusCard(status)).toList(),
              
              const SizedBox(height: 20),
              
              // Additional Fields
              if (_selectedStatus == 'graduate') ...[
                _buildTextField('الجامعة', _universityController, Icons.school),
                const SizedBox(height: 15),
                _buildYearField(),
                const SizedBox(height: 15),
                _buildTextField('التخصص', _majorController, Icons.science),
              ],
              
              const Spacer(),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'متابعة',
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(Map<String, String> status) {
    final isSelected = _selectedStatus == status['value'];
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status['value']!),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667EEA) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF667EEA) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(status['icon']!),
              color: isSelected ? Colors.white : const Color(0xFF667EEA),
              size: 30,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                status['label']!,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.tajawal(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: const Color(0xFF667EEA)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF667EEA)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        style: GoogleFonts.tajawal(),
      ),
    );
  }

  Widget _buildYearField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'سنة التخرج',
          labelStyle: GoogleFonts.tajawal(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF667EEA)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF667EEA)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        style: GoogleFonts.tajawal(),
        onChanged: (value) {
          if (value.isNotEmpty) {
            _graduationYear = int.tryParse(value);
          }
        },
      ),
    );
  }

  IconData _getStatusIcon(String iconKey) {
    switch (iconKey) {
      case 'school':
        return Icons.school;
      case 'graduation_cap':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.person;
    }
  }

  Future<void> _saveStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId != null) {
        final response = await ApiService.post('/onboarding/status', {
          'user_id': userId,
          'status': _selectedStatus,
          'university': _selectedStatus == 'graduate' ? _universityController.text.trim() : null,
          'major': _selectedStatus == 'graduate' ? _majorController.text.trim() : null,
          'graduation_year': _graduationYear,
        });
        
        if (response['success']) {
          Navigator.pushNamed(context, '/onboarding/interests');
        } else {
          _showErrorSnackBar(response['message'] ?? 'فشل حفظ البيانات');
        }
      }
    } catch (e) {
      _showErrorSnackBar('حدث خطأ ما. يرجى المحاولة مرة أخرى');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(color: Colors.white),
        ),
        backgroundColor: Colors.red[600],
      ),
    );
  }
}
