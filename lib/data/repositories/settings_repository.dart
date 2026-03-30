import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const int defaultAutoDeleteDays = 30;
  static const String _permissionsSetupKey = 'permissions_setup_completed';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _excludedPackagesKey = 'excluded_packages';
  static const String _savedOnlyDefaultKey = 'saved_only_default';
  static const String _unreadFirstKey = 'unread_first_enabled';
  static const String _appGroupingKey = 'app_grouping_enabled';
  static const String _searchScopeKey = 'search_scope';
  static const String _exactMatchSearchKey = 'exact_match_search_enabled';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

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

  Future<bool> getSavedOnlyDefault() async {
    final prefs = await _prefs;
    return prefs.getBool(_savedOnlyDefaultKey) ?? false;
  }

  Future<void> setSavedOnlyDefault(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_savedOnlyDefaultKey, value);
  }

  Future<bool> getUnreadFirstEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_unreadFirstKey) ?? true;
  }

  Future<void> setUnreadFirstEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_unreadFirstKey, value);
  }

  Future<bool> getAppGroupingEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_appGroupingKey) ?? true;
  }

  Future<void> setAppGroupingEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_appGroupingKey, value);
  }

  Future<String> getSearchScope() async {
    final prefs = await _prefs;
    return prefs.getString(_searchScopeKey) ?? 'fullContent';
  }

  Future<void> setSearchScope(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_searchScopeKey, value);
  }

  Future<bool> getExactMatchSearchEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_exactMatchSearchKey) ?? false;
  }

  Future<void> setExactMatchSearchEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_exactMatchSearchKey, value);
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
