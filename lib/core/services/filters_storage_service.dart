import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для сохранения и загрузки фильтров заказов
class FiltersStorageService {
  static const String _filtersKey = 'orders_filters';
  
  final SharedPreferences _prefs;
  
  FiltersStorageService(this._prefs);
  
  /// Сохранить фильтры заказов
  Future<void> saveFilters({
    String? search,
    int? orderStatusId,
    List<int>? selectedStatusIds,
    String? dateFrom,
    String? dateTo,
  }) async {
    final filtersData = {
      'search': search,
      'orderStatusId': orderStatusId,
      'selectedStatusIds': selectedStatusIds,
      'dateFrom': dateFrom,
      'dateTo': dateTo,
    };
    
    final jsonString = jsonEncode(filtersData);
    await _prefs.setString(_filtersKey, jsonString);
    
    print('💾 FiltersStorageService: Сохранены фильтры: $filtersData');
  }
  
  /// Загрузить фильтры заказов
  Map<String, dynamic>? loadFilters() {
    final jsonString = _prefs.getString(_filtersKey);
    if (jsonString == null) {
      print('💾 FiltersStorageService: Фильтры не найдены');
      return null;
    }
    
    try {
      final filtersData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Преобразуем selectedStatusIds из List<dynamic> в List<int>
      if (filtersData['selectedStatusIds'] != null) {
        filtersData['selectedStatusIds'] = List<int>.from(
          filtersData['selectedStatusIds'] as List<dynamic>
        );
      }
      
      print('💾 FiltersStorageService: Загружены фильтры: $filtersData');
      return filtersData;
    } catch (e) {
      print('💾 FiltersStorageService: Ошибка загрузки фильтров: $e');
      return null;
    }
  }
  
  /// Очистить сохраненные фильтры
  Future<void> clearFilters() async {
    await _prefs.remove(_filtersKey);
    print('💾 FiltersStorageService: Фильтры очищены');
  }
  
  /// Проверить, есть ли сохраненные фильтры
  bool hasSavedFilters() {
    return _prefs.containsKey(_filtersKey);
  }
}
