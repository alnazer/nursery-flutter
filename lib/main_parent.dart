import 'package:flutter/material.dart';

import 'app/app_config.dart';
import 'app/nursery_app.dart';

/// تطبيق ولي الأمر:
/// flutter run --flavor parent -t lib/main_parent.dart \
///   --dart-define=API_BASE_URL=https://nursery.local \
///   --dart-define=PARENT_API_KEY=... --dart-define=PARENT_API_SECRET=...
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NurseryApp(flavor: AppFlavor.parent));
}
