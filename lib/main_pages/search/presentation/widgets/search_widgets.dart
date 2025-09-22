import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchSuggestionsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;

  const SearchSuggestionsGrid({super.key, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Increased vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 20), // Increased bottom padding
            child: Text(
              'اقتراحات بحث شائعة',
              style: GoogleFonts.tajawal(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),

          // Grid of search suggestions
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive grid - 2 columns on mobile, 4 on tablet/desktop
              final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
              final itemSpacing = constraints.maxWidth < 600 ? 12.0 : 16.0;

              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: suggestions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: itemSpacing,
                  crossAxisSpacing: itemSpacing,
                  childAspectRatio: 3.5, // Wider containers for text
                ),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return _buildSuggestionItem(suggestion, context);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> suggestion, BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: suggestion['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (suggestion['gradient'] as List<Color>).last.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    suggestion['text'],
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12), // Space between text and icon
                Icon(
                  suggestion['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SuggestedSearch extends StatelessWidget {
  final List<String> recentSearches;

  const SuggestedSearch({super.key, required this.recentSearches});

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // Reduced vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 16), // Reduced bottom padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'البحوث المقترحة',
                  style: GoogleFonts.tajawal(
                    fontSize: 16, // Slightly smaller font
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          // Recent searches list
          Column(
            children: recentSearches.map((search) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8), // Reduced bottom padding
                child: Material(
                  elevation: 1,
                  borderRadius: BorderRadius.circular(8), // Smaller border radius
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8), // Smaller border radius
                    ),
                    child: ListTile(
                      dense: true, // Makes the ListTile more compact
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF6B7280),
                        size: 14, // Smaller icon
                      ),
                      title: Text(
                        search,
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF374151),
                          fontSize: 14, // Slightly smaller font
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Reduced padding
                      onTap: () {},
                      minLeadingWidth: 0, // Reduces leading space
                      minVerticalPadding: 8, // Controls vertical density
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class PopularCategories extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const PopularCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), // Increased vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 20), // Increased bottom padding
            child: Text(
              'الأقسام الأكثر بحثًا',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),

          // Horizontal scrollable categories
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16), // Increased spacing
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: category['gradient'] as List<Color>,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (category['gradient'] as List<Color>).last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'],
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}