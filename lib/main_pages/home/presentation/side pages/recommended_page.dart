import 'package:courses_app/main_pages/home/presentation/side_pages_widgets/recommended_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendedPage extends StatelessWidget {
  RecommendedPage({super.key});

  final List<Map<String, dynamic>> recommended = List.generate(5, (i) {
    return {
      'title': 'كورس ${i + 1} لتعلم مهارة متقدمة في البرمجة',
      'teacher': 'د. أحمد محمد ${i + 1}',
      'rating': 4.5 - (i * 0.2),
      'students': (1500 + i * 200).toString(),
      'image': 'https://picsum.photos/seed/course${i}/200/120',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ' الأقسام المقترحة',
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: RecommendedCoursesWidget(recommended: recommended),
        ),
      ),
    );
  }
}
