import 'package:courses_app/data/notifiers.dart';
import 'package:flutter/material.dart';

class NavBarWidget extends StatefulWidget {
  const NavBarWidget({super.key});

  @override
  State<NavBarWidget> createState() => _NavBarWidgetState();
}

class _NavBarWidgetState extends State<NavBarWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = Theme.of(context).colorScheme.surface;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              // Make sure the nav uses the theme surface so light/dark match the app
              backgroundColor: surface,
              // remove default indicator so only our gradient is visible
              indicatorColor: Colors.transparent,
              // label style adapts to selected/unselected + brightness
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle?>((
                states,
              ) {
                final selected = states.contains(MaterialState.selected);
                return TextStyle(
                  color: selected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.grey.shade700),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                );
              }),
              // fallback icon theme (we use explicit colors in the icon, but this is good to have)
              iconTheme: MaterialStateProperty.resolveWith<IconThemeData?>((
                states,
              ) {
                final selected = states.contains(MaterialState.selected);
                return IconThemeData(
                  color: selected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.grey.shade700),
                  size: selected ? 28 : 26,
                );
              }),
            ),
            child: NavigationBar(
              height: 70,
              elevation: 6,
              // set background to surface as well (theme + explicit)
              backgroundColor: surface,
              // safety: make sure the built-in indicator is not visible
              // (some Flutter versions don't expose indicator here, but theme covers it)
              // indicatorColor: Colors.transparent, // optional if supported
              selectedIndex: selectedPage,
              onDestinationSelected: (value) {
                selectedPageNotifier.value = value;
              },
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                _buildNavItem(
                  Icons.home_rounded,
                  'الرئيسية',
                  0,
                  selectedPage,
                  isDark,
                ),
                _buildNavItem(Icons.search, 'البحث', 1, selectedPage, isDark),
                _buildNavItem(
                  Icons.local_offer_outlined,
                  'كورساتي',
                  2,
                  selectedPage,
                  isDark,
                ),
                _buildNavItem(
                  Icons.account_circle_outlined,
                  'حسابي',
                  3,
                  selectedPage,
                  isDark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  NavigationDestination _buildNavItem(
    IconData icon,
    String label,
    int index,
    int selectedPage,
    bool isDark,
  ) {
    final bool isSelected = index == selectedPage;

    // Use your gradient when selected; otherwise keep no decoration.
    final decoration = isSelected
        ? BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // subtle shadow, slightly stronger on light backgrounds
                color: const Color(
                  0xFF667EEA,
                ).withOpacity(isDark ? 0.18 : 0.30),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : null;

    return NavigationDestination(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(8),
        decoration: decoration,
        child: Icon(
          icon,
          // selected icons are white to contrast the gradient; unselected adapt to theme
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.grey.shade700),
          size: isSelected ? 28 : 26,
        ),
      ),
      label: label,
    );
  }
}
