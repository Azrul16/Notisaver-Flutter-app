import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _onboardingKey = 'onboarding_completed';
  static const String _permissionsSetupKey = 'permissions_setup_completed';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _autoDeleteDaysKey = 'auto_delete_days';
  static const String _excludedPackagesKey = 'excluded_packages';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> getOnboardingCompleted() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingKey, value);
  }

  Future<bool> getPermissionsSetupCompleted() async {
    final prefs = await _prefs;
    return prefs.getBool(_permissionsSetupKey) ?? false;
  }

  Future<void> setPermissionsSetupCompleted(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_permissionsSetupKey, value);
  }

  Future<bool> getDarkModeEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_darkModeKey) ?? true;
  }

  Future<void> setDarkModeEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_darkModeKey, value);
  }

  Future<int> getAutoDeleteDays() async {
    final prefs = await _prefs;
    return prefs.getInt(_autoDeleteDaysKey) ?? 30;
  }

  Future<void> setAutoDeleteDays(int value) async {
    final prefs = await _prefs;
    await prefs.setInt(_autoDeleteDaysKey, value);
  }

  Future<Set<String>> getExcludedPackages() async {
    final prefs = await _prefs;
    return prefs.getStringList(_excludedPackagesKey)?.toSet() ?? <String>{};
  }

  Future<void> setExcludedPackages(Set<String> packages) async {
    final prefs = await _prefs;
    await prefs.setStringList(_excludedPackagesKey, packages.toList()..sort());
  }
}
