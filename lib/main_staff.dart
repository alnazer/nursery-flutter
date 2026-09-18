import 'package:flutter/material.dart';

import 'app/app_config.dart';
import 'app/nursery_app.dart';

/// تطبيق المشرفات:
/// flutter run --flavor staff -t lib/main_staff.dart \
///   --dart-define=API_BASE_URL=https://nursery.local \
///   --dart-define=STAFF_API_KEY=... --dart-define=STAFF_API_SECRET=...
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NurseryApp(flavor: AppFlavor.staff));
}
