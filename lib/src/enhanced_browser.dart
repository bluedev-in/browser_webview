import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Enhanced In-App Browser with real browser-like features
class EnhancedInAppBrowser {
  static final EnhancedInAppBrowser _instance =
      EnhancedInAppBrowser._internal();
  /// Provides access to the singleton instance of [EnhancedInAppBrowser].
  factory EnhancedInAppBrowser() => _instance;
  /// Private constructor for singleton
  EnhancedInAppBrowser._internal();

  /// Opens URL in enhanced browser
  static Future<void> open(
    BuildContext context,
    String url, {
    String? title,
    Color? backgroundColor,
    Color? foregroundColor,
    bool showProgressBar = true,
    bool enableShare = true,
    bool enableRefresh = true,
    bool enableBackForward = true,
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            _EnhancedBrowserScreen(
              url: url,
              title: title,
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              showProgressBar: showProgressBar,
              enableShare: enableShare,
              enableRefresh: enableRefresh,
              enableBackForward: enableBackForward,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _EnhancedBrowserScreen extends StatefulWidget {
  final String url;
  final String? title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showProgressBar;
  final bool enableShare;
  final bool enableRefresh;
  final bool enableBackForward;

  const _EnhancedBrowserScreen({
    required this.url,
    this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.showProgressBar = true,
    this.enableShare = true,
    this.enableRefresh = true,
    this.enableBackForward = true,
  });

  @override
  State<_EnhancedBrowserScreen> createState() => _EnhancedBrowserScreenState();
}

class _EnhancedBrowserScreenState extends State<_EnhancedBrowserScreen>
    with TickerProviderStateMixin {
  InAppWebViewController? _webViewController;
  String _currentUrl = '';
  String _pageTitle = '';
  bool _isLoading = true;
  double _progress = 0.0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  bool _isSecure = false;
  bool _isDesktopMode = false;
  bool _showAddressBar = false;
  bool _isFindInPage = false;
  int _findCurrentMatch = 0;
  int _findTotalMatches = 0;

  // Text controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _findController = TextEditingController();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _findFocusNode = FocusNode();

  // History
  final List<String> _history = [];

  // Animation controllers
  late AnimationController _toolbarAnimationController;

  late FindInteractionController _findInteractionController;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
    _pageTitle = widget.title ?? 'Loading...';
    _addressController.text = widget.url;

    _findInteractionController = FindInteractionController(
      onFindResultReceived: (
        controller,
        activeMatchOrdinal,
        numberOfMatches,
        isDoneCounting,
      ) {
        setState(() {
          _findCurrentMatch = activeMatchOrdinal + 1;
          _findTotalMatches = numberOfMatches;
        });
      },
    );

    // Initialize animation controllers
    _toolbarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Start animations
    _toolbarAnimationController.forward();
  }

  @override
  void dispose() {
    _toolbarAnimationController.dispose();
    _addressController.dispose();
    _findController.dispose();
    _addressFocusNode.dispose();
    _findFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        widget.backgroundColor ?? theme.scaffoldBackgroundColor;
    final foregroundColor = widget.foregroundColor ?? theme.primaryColor;

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _canGoBack) {
          _goBack();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            // Top safe area
            Container(
              color: isDark ? Colors.grey[900] : Colors.white,
              height: MediaQuery.of(context).padding.top,
            ),

            // Main toolbar
            _buildMainToolbar(context, foregroundColor, isDark),

            // Address bar (expandable)
            if (_showAddressBar)
              _buildAddressBar(context, foregroundColor, isDark),

            // Find in page bar
            if (_isFindInPage)
              _buildFindInPageBar(context, foregroundColor, isDark),

            // Progress bar
            if (widget.showProgressBar && _isLoading)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                minHeight: 2,
              ),

            // WebView
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  useOnDownloadStart: true,
                  useOnLoadResource: true,
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                  transparentBackground: false,
                  verticalScrollBarEnabled: true,
                  horizontalScrollBarEnabled: true,
                  disableVerticalScroll: false,
                  disableHorizontalScroll: false,
                  supportZoom: true,
                  builtInZoomControls: true,
                  displayZoomControls: false,
                  useHybridComposition: true,
                  allowContentAccess: true,
                  allowFileAccess: true,
                  useWideViewPort: true,
                  loadWithOverviewMode: true,
                  mixedContentMode:
                      MixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  allowsInlineMediaPlayback: true,
                  allowsBackForwardNavigationGestures: true,
                  preferredContentMode: _isDesktopMode
                      ? UserPreferredContentMode.DESKTOP
                      : UserPreferredContentMode.MOBILE,
                ),
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _isLoading = true;
                    _currentUrl = url.toString();
                    _addressController.text = url.toString();
                    _isSecure = url.toString().startsWith('https://');
                  });
                },
                onLoadStop: (controller, url) async {
                  setState(() {
                    _isLoading = false;
                    _currentUrl = url.toString();
                    _addressController.text = url.toString();
                  });

                  final title = await controller.getTitle();
                  setState(() {
                    _pageTitle = title ?? _extractDomainFromUrl(_currentUrl);
                  });

                  // Add to history
                  if (_history.isEmpty || _history.last != _currentUrl) {
                    _history.add(_currentUrl);
                  }

                  _updateNavigationState();
                },
                onProgressChanged: (controller, progress) {
                  setState(() {
                    _progress = progress / 100.0;
                  });
                },
                onReceivedError: (controller, request, error) {
                  setState(() {
                    _isLoading = false;
                  });
                },
                onDownloadStartRequest: (controller, request) async {
                  _showDownloadDialog(request);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final url = navigationAction.request.url.toString();

                  // Handle special schemes
                  if (url.startsWith('mailto:') ||
                      url.startsWith('tel:') ||
                      url.startsWith('sms:') ||
                      url.startsWith('whatsapp:') ||
                      url.startsWith('instagram:') ||
                      url.startsWith('twitter:') ||
                      url.startsWith('fb:')) {
                    await _launchExternalUrl(url);
                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                findInteractionController: _findInteractionController,
                onScrollChanged: (controller, x, y) {
                  // Can be used for auto-hiding toolbar
                },
              ),
            ),

            // Bottom navigation bar
            _buildBottomNavigationBar(context, foregroundColor, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildMainToolbar(
    BuildContext context,
    Color foregroundColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            iconSize: 22,
            style: IconButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black87,
            ),
          ),

          // URL/Title bar (tappable to show address bar)
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showAddressBar = !_showAddressBar;
                  if (_showAddressBar) {
                    _addressController.text = _currentUrl;
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _addressFocusNode.requestFocus();
                      _addressController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _addressController.text.length,
                      );
                    });
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Security indicator
                    Icon(
                      _isSecure ? Icons.lock : Icons.lock_open,
                      size: 14,
                      color: _isSecure ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 6),

                    // Domain/Title
                    Expanded(
                      child: Text(
                        _showAddressBar
                            ? _currentUrl
                            : _extractDomainFromUrl(_currentUrl),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Loading indicator
                    if (_isLoading)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            foregroundColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Reload/Stop button
          IconButton(
            onPressed: _isLoading ? _stop : _refresh,
            icon: Icon(_isLoading ? Icons.close : Icons.refresh),
            iconSize: 22,
            style: IconButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black87,
            ),
          ),

          // More options menu
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white : Colors.black87,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'find',
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    const Text('Find in page'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'desktop',
                child: Row(
                  children: [
                    Icon(
                      _isDesktopMode
                          ? Icons.phone_android
                          : Icons.desktop_windows,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    Text(_isDesktopMode ? 'Mobile site' : 'Desktop site'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(
                      Icons.share,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    const Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(
                      Icons.copy,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    const Text('Copy link'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'external',
                child: Row(
                  children: [
                    Icon(
                      Icons.open_in_browser,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    const Text('Open in browser'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    const Text('History'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 12),
                    const Text('Settings'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressBar(
    BuildContext context,
    Color foregroundColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addressController,
              focusNode: _addressFocusNode,
              decoration: InputDecoration(
                hintText: 'Enter URL or search',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
                suffixIcon: _addressController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _addressController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onSubmitted: _navigateToUrl,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _showAddressBar = false;
              });
            },
            child: Text('Cancel', style: TextStyle(color: foregroundColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildFindInPageBar(
    BuildContext context,
    Color foregroundColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _findController,
              focusNode: _findFocusNode,
              decoration: InputDecoration(
                hintText: 'Find in page',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _findInteractionController.findAll(find: value);
                } else {
                  _findInteractionController.clearMatches();
                  setState(() {
                    _findCurrentMatch = 0;
                    _findTotalMatches = 0;
                  });
                }
              },
            ),
          ),
          if (_findTotalMatches > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$_findCurrentMatch/$_findTotalMatches',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, size: 20),
            onPressed: () => _findInteractionController.findNext(forward: false),
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            onPressed: () => _findInteractionController.findNext(forward: true),
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _isFindInPage = false;
                _findController.clear();
                _findCurrentMatch = 0;
                _findTotalMatches = 0;
              });
              _findInteractionController.clearMatches();
            },
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    Color foregroundColor,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Back button
          _buildNavButton(
            icon: Icons.arrow_back_ios_new,
            onPressed: _canGoBack ? _goBack : null,
            isDark: isDark,
          ),

          // Forward button
          _buildNavButton(
            icon: Icons.arrow_forward_ios,
            onPressed: _canGoForward ? _goForward : null,
            isDark: isDark,
          ),

          // Home button
          _buildNavButton(
            icon: Icons.home_outlined,
            onPressed: () => _navigateToUrl('https://www.google.com'),
            isDark: isDark,
          ),

          // Share button
          _buildNavButton(
            icon: Icons.share_outlined,
            onPressed: _shareUrl,
            isDark: isDark,
          ),

          // Tabs/Menu button
          _buildNavButton(
            icon: Icons.tab_outlined,
            onPressed: _showPageInfo,
            isDark: isDark,
            badge: '1',
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    VoidCallback? onPressed,
    required bool isDark,
    String? badge,
  }) {
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          iconSize: 24,
          style: IconButton.styleFrom(
            foregroundColor: onPressed != null
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white30 : Colors.black26),
          ),
        ),
        if (badge != null)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'find':
        setState(() {
          _isFindInPage = true;
          _showAddressBar = false;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          _findFocusNode.requestFocus();
        });
        break;
      case 'desktop':
        setState(() {
          _isDesktopMode = !_isDesktopMode;
        });
        // Reload with new user agent
        await _webViewController?.setSettings(
          settings: InAppWebViewSettings(
            preferredContentMode: _isDesktopMode
                ? UserPreferredContentMode.DESKTOP
                : UserPreferredContentMode.MOBILE,
          ),
        );
        _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isDesktopMode ? 'Desktop mode enabled' : 'Mobile mode enabled',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        }
        break;
      case 'share':
        _shareUrl();
        break;
      case 'copy':
        _copyUrl();
        break;
      case 'external':
        _openInExternalBrowser();
        break;
      case 'history':
        _showHistoryDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _navigateToUrl(String input) {
    String url = input.trim();

    // Check if it's a valid URL
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // Check if it looks like a domain
      if (url.contains('.') && !url.contains(' ')) {
        url = 'https://$url';
      } else {
        // Treat as search query
        url = 'https://www.google.com/search?q=${Uri.encodeComponent(url)}';
      }
    }

    setState(() {
      _showAddressBar = false;
    });

    _webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  void _refresh() {
    _webViewController?.reload();
  }

  void _stop() {
    _webViewController?.stopLoading();
    setState(() {
      _isLoading = false;
    });
  }

  void _goBack() {
    _webViewController?.goBack();
  }

  void _goForward() {
    _webViewController?.goForward();
  }

  void _shareUrl() async {
    await SharePlus.instance.share(
      ShareParams(text: _currentUrl, subject: _pageTitle),
    );
  }

  void _copyUrl() {
    Clipboard.setData(ClipboardData(text: _currentUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openInExternalBrowser() async {
    await _launchExternalUrl(_currentUrl);
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching external URL: $e');
    }
  }

  void _updateNavigationState() async {
    final canGoBack = await _webViewController?.canGoBack() ?? false;
    final canGoForward = await _webViewController?.canGoForward() ?? false;

    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  String _extractDomainFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  void _showDownloadDialog(DownloadStartRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Do you want to download this file?'),
            const SizedBox(height: 8),
            Text(
              request.suggestedFilename ?? 'Unknown file',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (request.contentLength > 0)
              Text(
                'Size: ${_formatFileSize(request.contentLength)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchExternalUrl(request.url.toString());
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showHistoryDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _history.clear();
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text('No history'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final url = _history[_history.length - 1 - index];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(
                            _extractDomainFromUrl(url),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _webViewController?.loadUrl(
                              urlRequest: URLRequest(url: WebUri(url)),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Browser Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Desktop mode'),
                subtitle: const Text('Request desktop version of websites'),
                value: _isDesktopMode,
                onChanged: (value) {
                  setModalState(() {
                    _isDesktopMode = value;
                  });
                  setState(() {
                    _isDesktopMode = value;
                  });
                  _webViewController?.setSettings(
                    settings: InAppWebViewSettings(
                      preferredContentMode: value
                          ? UserPreferredContentMode.DESKTOP
                          : UserPreferredContentMode.MOBILE,
                    ),
                  );
                  _refresh();
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text size'),
                subtitle: const Text('Normal'),
                onTap: () {
                  // Could implement text size adjustment
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear browsing data'),
                onTap: () async {
                  await InAppWebViewController.clearAllCache();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cache cleared')),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  void _showPageInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isSecure ? Icons.lock : Icons.lock_open,
                  color: _isSecure ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pageTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _currentUrl,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _isSecure ? Icons.verified_user : Icons.warning,
                  size: 16,
                  color: _isSecure ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  _isSecure
                      ? 'Connection is secure'
                      : 'Connection is not secure',
                  style: TextStyle(
                    color: _isSecure ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}
