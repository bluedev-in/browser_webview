import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InlineWebView extends StatefulWidget {
  final String url;
  final double height;
  final bool enableZoom;
  final void Function(InAppWebViewController)? onWebViewCreated;
  final void Function(int)? onProgressChanged;

  const InlineWebView({
    super.key,
    required this.url,
    this.height = 300,
    this.enableZoom = false,
    this.onWebViewCreated,
    this.onProgressChanged,
  });

  @override
  State<InlineWebView> createState() => _InlineWebViewState();
}

class _InlineWebViewState extends State<InlineWebView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        initialSettings: InAppWebViewSettings(
          supportZoom: widget.enableZoom,
          displayZoomControls: widget.enableZoom,
        ),
        gestureRecognizers: {
          Factory<VerticalDragGestureRecognizer>(
            () => VerticalDragGestureRecognizer(),
          ),
          Factory<ScaleGestureRecognizer>(
            () => ScaleGestureRecognizer(),
          ),
          Factory<TapGestureRecognizer>(
            () => TapGestureRecognizer(),
          ),
          Factory<HorizontalDragGestureRecognizer>(
            () => HorizontalDragGestureRecognizer(),
          ),
        },
        onWebViewCreated: widget.onWebViewCreated,
        onProgressChanged: (controller, progress) {
          if (widget.onProgressChanged != null) {
            widget.onProgressChanged!(progress);
          }
        },
      ),
    );
  }
}
