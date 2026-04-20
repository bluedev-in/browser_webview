import 'package:flutter_test/flutter_test.dart';
import 'package:browser_webview/browser_webview.dart';

void main() {
  test('EnhancedInAppBrowser can be instantiated', () {
    final browser = EnhancedInAppBrowser();
    expect(browser, isNotNull);
  });
}
