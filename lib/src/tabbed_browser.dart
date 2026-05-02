import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Represents a single tab in the [TabbedBrowser].
class WebTab {
  /// The unique ID of the tab.
  final String id;

  /// The initial URL of the tab.
  final String initialUrl;

  /// The current URL of the tab.
  String currentUrl;

  /// The title of the tab.
  String title;

  /// The controller for this tab's web view.
  InAppWebViewController? controller;

  /// Creates a new [WebTab].
  WebTab({
    required this.id,
    required this.initialUrl,
    this.currentUrl = '',
    this.title = 'New Tab',
  });
}

/// A browser widget that supports multiple tabs.
class TabbedBrowser extends StatefulWidget {
  /// The initial URL to load when the browser opens.
  final String initialUrl;

  /// Creates a new [TabbedBrowser] widget.
  const TabbedBrowser({super.key, this.initialUrl = 'https://google.com'});

  /// Opens the [TabbedBrowser] in a new route.
  static Future<void> open(
    BuildContext context, {
    String initialUrl = 'https://google.com',
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TabbedBrowser(initialUrl: initialUrl),
      ),
    );
  }

  @override
  State<TabbedBrowser> createState() => _TabbedBrowserState();
}

class _TabbedBrowserState extends State<TabbedBrowser> {
  final List<WebTab> _tabs = [];
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _addNewTab(widget.initialUrl);
  }

  void _addNewTab(String url) {
    setState(() {
      final newTab = WebTab(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        initialUrl: url,
        currentUrl: url,
      );
      _tabs.add(newTab);
      _activeTabIndex = _tabs.length - 1;
    });
  }

  void _closeTab(int index) {
    if (_tabs.length <= 1) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _tabs.removeAt(index);
      if (_activeTabIndex >= _tabs.length) {
        _activeTabIndex = _tabs.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabbed Browser'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tab),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '${_tabs.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: _showTabSwitcher,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNewTab('https://google.com'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _activeTabIndex,
        children: _tabs.map((tab) => _buildTabWebView(tab)).toList(),
      ),
    );
  }

  Widget _buildTabWebView(WebTab tab) {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(tab.initialUrl)),
      onWebViewCreated: (controller) => tab.controller = controller,
      onLoadStop: (controller, url) async {
        final title = await controller.getTitle();
        setState(() {
          tab.currentUrl = url.toString();
          tab.title = title ?? 'No Title';
        });
      },
    );
  }

  void _showTabSwitcher() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tabs',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      _addNewTab('https://google.com');
                      Navigator.pop(context);
                    },
                    child: const Text('New Tab'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final tab = _tabs[index];
                    final isActive = index == _activeTabIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _activeTabIndex = index);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? Colors.blue
                                : Colors.grey.shade300,
                            width: isActive ? 3 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: isActive
                                  ? Colors.blue.withValues(alpha: 0.1)
                                  : Colors.grey.shade100,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      tab.title,
                                      style: const TextStyle(fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _closeTab(index);
                                      setModalState(() {});
                                    },
                                    child: const Icon(Icons.close, size: 14),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                child: const Center(
                                  child: Icon(
                                    Icons.language,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
