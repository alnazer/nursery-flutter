import 'package:flutter_test/flutter_test.dart';
import 'package:nursery/app/app_config.dart';

void main() {
  test('AppConfig يبني بادئة المسارات لكل نسخة', () {
    final AppConfig parent = AppConfig.fromEnvironment(AppFlavor.parent);
    final AppConfig staff = AppConfig.fromEnvironment(AppFlavor.staff);

    expect(parent.portalPrefix, '/api/v1/parent');
    expect(staff.portalPrefix, '/api/v1/staff');
    expect(parent.commonPrefix, '/api/v1');
    expect(parent.baseUrl.endsWith('/'), isFalse);
  });
}
