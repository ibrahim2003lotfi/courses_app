// lib/core/utils/onboarding_manager.dart
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager {
  static const String onboardingCompletedKey = 'onboarding_completed';

  static Future<bool> isOnboardingCompleted() async {
    // Temporarily always return false to show onboarding every time
    return false;

    // Later, when you want to enable persistence, uncomment below:
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool(onboardingCompletedKey) ?? false;
  }

  static Future<void> completeOnboarding() async {
    // Temporarily do nothing to keep showing onboarding
    print('Onboarding completed - but not saved (temporary mode)');

    // Later, when you want to enable persistence, uncomment below:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool(onboardingCompletedKey, true);
  }

  static Future<void> resetOnboarding() async {
    // Temporarily do nothing
    print('Onboarding reset - but not saved (temporary mode)');

    // Later, when you want to enable persistence, uncomment below:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setBool(onboardingCompletedKey, false);
  }
}
