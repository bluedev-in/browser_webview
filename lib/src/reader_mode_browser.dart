import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ReaderModeBrowser extends StatefulWidget {
  final String url;

  const ReaderModeBrowser({super.key, required this.url});

  static Future<void> open(BuildContext context, String url) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ReaderModeBrowser(url: url)),
    );
  }

  @override
  State<ReaderModeBrowser> createState() => _ReaderModeBrowserState();
}

class _ReaderModeBrowserState extends State<ReaderModeBrowser> {
  bool _isReaderMode = false;
  InAppWebViewController? _webViewController;
  String? _extractedContent;
  bool _isLoadingContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader Browser'),
        actions: [
          IconButton(
            icon: Icon(_isReaderMode ? Icons.article : Icons.article_outlined),
            onPressed: _toggleReaderMode,
            tooltip: 'Toggle Reader Mode',
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onWebViewCreated: (controller) => _webViewController = controller,
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
            ),
          ),
          if (_isReaderMode)
            Container(
              color: Colors.white,
              child: _isLoadingContent
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reader Mode',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 32),
                          Text(
                            _extractedContent ?? 'Failed to extract content.',
                            style: const TextStyle(fontSize: 18, height: 1.6, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggleReaderMode() async {
    setState(() {
      _isReaderMode = !_isReaderMode;
    });

    if (_isReaderMode && _extractedContent == null) {
      setState(() => _isLoadingContent = true);
      
      // Simple JS injection to get main text content
      final content = await _webViewController?.evaluateJavascript(source: """
        (function() {
          var main = document.querySelector('main') || document.querySelector('article') || document.body;
          return main.innerText;
        })()
      """);

      setState(() {
        _extractedContent = content;
        _isLoadingContent = false;
      });
    }
  }
}
