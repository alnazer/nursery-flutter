/// صفحة من قائمة مع بيانات الترقيم وأي عدادات في meta.
class Paged<T> {
  const Paged({
    required this.items,
    required this.page,
    required this.hasMore,
    this.meta = const <String, dynamic>{},
  });

  final List<T> items;
  final int page;
  final bool hasMore;
  final Map<String, dynamic> meta;

  static Paged<T> fromEnvelope<T>(
    Map<String, dynamic> envelope,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final List<dynamic> data = envelope['data'] is List ? envelope['data'] as List<dynamic> : <dynamic>[];
    final Map<String, dynamic> meta =
        envelope['meta'] is Map ? Map<String, dynamic>.from(envelope['meta'] as Map) : <String, dynamic>{};
    final Map<String, dynamic> pagination =
        meta['pagination'] is Map ? Map<String, dynamic>.from(meta['pagination'] as Map) : <String, dynamic>{};

    return Paged<T>(
      items: data
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => parse(Map<String, dynamic>.from(item)))
          .toList(),
      page: (pagination['current_page'] as int?) ?? 1,
      hasMore: pagination['has_more'] == true,
      meta: meta,
    );
  }
}
