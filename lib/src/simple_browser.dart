import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SimpleBrowser extends StatefulWidget {
  final String url;
  final String? title;
  final bool showProgressBar;

  const SimpleBrowser({
    super.key,
    required this.url,
    this.title,
    this.showProgressBar = true,
  });

  static Future<void> open(BuildContext context, String url, {String? title}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SimpleBrowser(url: url, title: title),
      ),
    );
  }

  @override
  State<SimpleBrowser> createState() => _SimpleBrowserState();
}

class _SimpleBrowserState extends State<SimpleBrowser> {
  double _progress = 0;
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _webViewController?.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.showProgressBar && _progress < 1.0)
            LinearProgressIndicator(value: _progress),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              onWebViewCreated: (controller) => _webViewController = controller,
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
