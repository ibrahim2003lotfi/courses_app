import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:courses_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingInterestsPage extends StatefulWidget {
  const OnboardingInterestsPage({Key? key}) : super(key: key);

  @override
  _OnboardingInterestsPageState createState() => _OnboardingInterestsPageState();
}

class _OnboardingInterestsPageState extends State<OnboardingInterestsPage> {
  final List<String> _selectedInterests = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _interestOptions = [
    {'id': 'programming', 'name': 'البرمجة', 'icon': 'code', 'color': '#3B82F6'},
    {'id': 'design', 'name': 'التصميم', 'icon': 'palette', 'color': '#8B5CF6'},
    {'id': 'business', 'name': 'الأعمال', 'icon': 'business', 'color': '#F97316'},
    {'id': 'marketing', 'name': 'التسويق', 'icon': 'trending_up', 'color': '#EC4899'},
    {'id': 'language', 'name': 'اللغات', 'icon': 'translate', 'color': '#10B981'},
    {'id': 'science', 'name': 'العلوم', 'icon': 'science', 'color': '#06B6D4'},
    {'id': 'art', 'name': 'الفن', 'icon': 'brush', 'color': '#F59E0B'},
    {'id': 'music', 'name': 'الموسيقى', 'icon': 'music_note', 'color': '#8B5A3D'},
    {'id': 'sports', 'name': 'الرياضة', 'icon': 'sports_soccer', 'color': '#EF4444'},
    {'id': 'technology', 'name': 'التكنولوجيا', 'icon': 'computer', 'color': '#6366F1'},
    {'id': 'health', 'name': 'الصحة', 'icon': 'favorite', 'color': '#F43F5E'},
    {'id': 'education', 'name': 'التعليم', 'icon': 'school', 'color': '#10B981'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'ما هي اهتماماتك؟',
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
                'اختر الاهتمامات التي تهمك (يمكن اختيار أكثر من واحدة)',
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              
              // Interest Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _interestOptions.length,
                  itemBuilder: (context, index) {
                    final interest = _interestOptions[index];
                    final isSelected = _selectedInterests.contains(interest['id']);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest['id']);
                          } else {
                            _selectedInterests.add(interest['id']);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? Color(int.parse(interest['color'])) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Color(int.parse(interest['color'])) : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getInterestIcon(interest['icon']),
                              color: isSelected ? Colors.white : Color(int.parse(interest['color'])),
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              interest['name'],
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Selected Interests Display
              if (_selectedInterests.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF667EEA), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الاهتمامات المختارة:',
                        style: GoogleFonts.tajawal(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF667EEA),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedInterests.map((interest) {
                          final interestData = _interestOptions.firstWhere((i) => i['id'] == interest);
                          return Chip(
                            label: interestData['name'],
                            backgroundColor: Color(int.parse(interestData['color'])).withOpacity(0.2),
                            side: BorderSide(color: Color(int.parse(interestData['color']))),
                            labelStyle: GoogleFonts.tajawal(
                              fontSize: 12,
                              color: Color(int.parse(interestData['color']),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedInterests.isEmpty || _isLoading ? null : _saveInterests,
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
                          'إكمال الاعدادات',
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

  IconData _getInterestIcon(String iconKey) {
    switch (iconKey) {
      case 'code':
        return Icons.code;
      case 'palette':
        return Icons.palette;
      case 'business':
        return Icons.business;
      case 'trending_up':
        return Icons.trending_up;
      case 'translate':
        return Icons.translate;
      case 'science':
        return Icons.science;
      case 'brush':
        return Icons.brush;
      case 'music_note':
        return Icons.music_note;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'computer':
        return Icons.computer;
      case 'favorite':
        return Icons.favorite;
      case 'school':
        return Icons.school;
      default:
        return Icons.interests;
    }
  }

  Future<void> _saveInterests() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      print('🎯 Starting interests save process...');
      print('🎯 User ID: $userId');
      print('🎯 Selected interests: $_selectedInterests');
      
      if (userId != null) {
        final response = await ApiService.post('/onboarding/interests', {
          'user_id': userId,
          'interests': _selectedInterests,
        });
        
        print('🎯 API Response: $response');
        
        if (response['success']) {
          print('🎯 Interests saved successfully');
          // Navigate to home page and clear onboarding state
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('completed_onboarding', true);
          
          print('🎯 Navigating to home page...');
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          print('🎯 Successfully navigated to home');
        } else {
          print('🎯 API Error: ${response['message']}');
          _showErrorSnackBar(response['message'] ?? 'فشل حفظ الاهتمامات');
        }
      } else {
        print('🎯 Error: User ID is null');
        _showErrorSnackBar('لم يتم العثور على معرف المستخدم');
      }
    } catch (e) {
      print('🎯 Exception occurred: $e');
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
