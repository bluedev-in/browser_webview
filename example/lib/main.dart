import 'package:flutter/material.dart';
import 'package:browser_webview/browser_webview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Browser WebView Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browser WebView Showcase'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Standalone Browsers'),
            const SizedBox(height: 12),
            _buildBrowserCard(
              context,
              title: 'Enhanced Browser',
              description: 'Full-featured browser with address bar, history, and desktop mode.',
              icon: Icons.browser_updated,
              color: Colors.blue,
              onTap: () => EnhancedInAppBrowser.open(
                context,
                'https://flutter.dev',
                title: 'Flutter Dev',
              ),
            ),
            const SizedBox(height: 12),
            _buildBrowserCard(
              context,
              title: 'Simple Browser',
              description: 'Clean Material UI with standard AppBar and progress indicator.',
              icon: Icons.web,
              color: Colors.green,
              onTap: () => SimpleBrowser.open(
                context,
                'https://pub.dev',
                title: 'Pub.dev',
              ),
            ),
            const SizedBox(height: 12),
            _buildBrowserCard(
              context,
              title: 'Glass Browser',
              description: 'Modern premium look with frosted glass effects and blur.',
              icon: Icons.blur_on,
              color: Colors.purple,
              onTap: () => GlassBrowser.open(
                context,
                'https://dart.dev',
                title: 'Dart Language',
              ),
            ),
            const SizedBox(height: 12),
            _buildBrowserCard(
              context,
              title: 'Customizable Browser',
              description: 'Highly configurable with custom theme colors, toolbars, and settings.',
              icon: Icons.settings_applications,
              color: Colors.red,
              onTap: () => CustomizableBrowser.open(
                context,
                'https://flutter.dev',
                title: 'Custom Settings Demo',
                options: const BrowserOptions(
                  toolbarColor: Colors.deepOrange,
                  progressBarColor: Colors.yellow,
                  showBottomToolbar: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildBrowserCard(
              context,
              title: 'Tabbed Browser',
              description: 'Multi-tab support with a tab switcher and new tab capabilities.',
              icon: Icons.dynamic_feed,
              color: Colors.teal,
              onTap: () => TabbedBrowser.open(context),
            ),
            const SizedBox(height: 12),
            _buildBrowserCard(
              context,
              title: 'Reader Mode Browser',
              description: 'Focus on content by extracting text and removing distractions.',
              icon: Icons.chrome_reader_mode,
              color: Colors.brown,
              onTap: () => ReaderModeBrowser.open(context, 'https://blog.flutter.dev'),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Utilities & Widgets'),
            const SizedBox(height: 12),
            _buildBrowserCard(
              context,
              title: 'Modal Bottom Sheet',
              description: 'Quickly preview links in a draggable bottom sheet.',
              icon: Icons.vertical_align_bottom,
              color: Colors.orange,
              onTap: () => ModalBrowser.show(
                context,
                'https://github.com/flutter',
                title: 'GitHub Preview',
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Inline WebView Example'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: const Column(
                children: [
                   Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'The box below is an InlineWebView widget embedded directly in this scroll view.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ),
                  InlineWebView(
                    url: 'https://flutter.dev',
                    height: 300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildBrowserCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
