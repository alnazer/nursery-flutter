import '../api/parent_api.dart';
import '../models/parent_models.dart';

/// أبناء ولي الأمر — يُحمَّلون مرة واحدة ويُعاد استعمالهم في شرائط التصفية.
/// تُمسح عند تسجيل الخروج أو انتهاء الجلسة.
class ChildrenCache {
  ChildrenCache._();

  static List<Child>? _items;

  static List<Child> get items => _items ?? const <Child>[];

  static Future<List<Child>> load(ParentApi api) async {
    final List<Child>? cached = _items;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    final List<Child> rows = await api.children();
    _items = rows;

    return rows;
  }

  static void clear() => _items = null;
}
