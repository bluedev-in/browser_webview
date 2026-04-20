import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class BrowserOptions {
  final bool javaScriptEnabled;
  final bool supportZoom;
  final bool useOnDownloadStart;
  final bool mediaPlaybackRequiresUserGesture;
  final bool allowsInlineMediaPlayback;
  final bool allowsBackForwardNavigationGestures;
  final UserPreferredContentMode preferredContentMode;
  
  // UI Options
  final Color? toolbarColor;
  final Color? iconColor;
  final Color? progressBarColor;
  final bool showAddressBar;
  final bool showBottomToolbar;
  final bool showCloseButton;
  final String? customUserAgent;

  const BrowserOptions({
    this.javaScriptEnabled = true,
    this.supportZoom = true,
    this.useOnDownloadStart = true,
    this.mediaPlaybackRequiresUserGesture = false,
    this.allowsInlineMediaPlayback = true,
    this.allowsBackForwardNavigationGestures = true,
    this.preferredContentMode = UserPreferredContentMode.MOBILE,
    this.toolbarColor,
    this.iconColor,
    this.progressBarColor,
    this.showAddressBar = true,
    this.showBottomToolbar = true,
    this.showCloseButton = true,
    this.customUserAgent,
  });
}

class CustomizableBrowser extends StatefulWidget {
  final String url;
  final String? title;
  final BrowserOptions options;

  const CustomizableBrowser({
    super.key,
    required this.url,
    this.title,
    this.options = const BrowserOptions(),
  });

  static Future<void> open(
    BuildContext context,
    String url, {
    String? title,
    BrowserOptions options = const BrowserOptions(),
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CustomizableBrowser(
          url: url,
          title: title,
          options: options,
        ),
      ),
    );
  }

  @override
  State<CustomizableBrowser> createState() => _CustomizableBrowserState();
}

class _CustomizableBrowserState extends State<CustomizableBrowser> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  String _currentUrl = '';
  late BrowserOptions _currentOptions;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _currentOptions = widget.options;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toolbarColor = _currentOptions.toolbarColor ?? theme.primaryColor;
    final iconColor = _currentOptions.iconColor ?? Colors.white;
    final progressBarColor = _currentOptions.progressBarColor ?? theme.colorScheme.secondary;

    return Scaffold(
      appBar: _currentOptions.showAddressBar
          ? AppBar(
              backgroundColor: toolbarColor,
              foregroundColor: iconColor,
              leading: _currentOptions.showCloseButton
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title ?? 'Browser',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    _currentUrl,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _webViewController?.reload(),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => Share.share(_currentUrl),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          if (_progress < 1.0)
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
              minHeight: 3,
            ),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: _currentOptions.javaScriptEnabled,
                supportZoom: _currentOptions.supportZoom,
                useOnDownloadStart: _currentOptions.useOnDownloadStart,
                mediaPlaybackRequiresUserGesture: _currentOptions.mediaPlaybackRequiresUserGesture,
                allowsInlineMediaPlayback: _currentOptions.allowsInlineMediaPlayback,
                allowsBackForwardNavigationGestures: _currentOptions.allowsBackForwardNavigationGestures,
                preferredContentMode: _currentOptions.preferredContentMode,
                userAgent: _currentOptions.customUserAgent,
              ),
              onWebViewCreated: (controller) => _webViewController = controller,
              onLoadStart: (controller, url) {
                setState(() {
                  _currentUrl = url.toString();
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _currentUrl = url.toString();
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _currentOptions.showBottomToolbar
          ? BottomAppBar(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () async {
                      if (await _webViewController?.canGoBack() ?? false) {
                        _webViewController?.goBack();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () async {
                      if (await _webViewController?.canGoForward() ?? false) {
                        _webViewController?.goForward();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showSettingsDialog,
                  ),
                  IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () => launchUrl(Uri.parse(_currentUrl), mode: LaunchMode.externalApplication),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Browser Customization', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SwitchListTile(
              title: const Text('JavaScript'),
              value: _currentOptions.javaScriptEnabled,
              onChanged: (val) {
                // In a real app, you'd update settings on the controller
                // For this demo, we'll just show the UI change as a "customization" example
              },
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: const Text('Theme Color'),
              trailing: const CircleAvatar(backgroundColor: Colors.blue, radius: 10),
              onTap: () {
                // Implement color picker
              },
            ),
          ],
        ),
      ),
    );
  }
}
