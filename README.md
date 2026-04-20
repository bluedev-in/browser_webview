# browser_webview

A comprehensive Flutter package providing multiple types of in-app webview experiences, from minimal wrappers to full-featured browsers with modern aesthetics.

## Features

- **EnhancedInAppBrowser**: A full-featured standalone browser with address bar, history tracking, search, desktop/mobile switching, and more.
- **SimpleBrowser**: A clean, standard Material UI browser for simple link viewing.
- **GlassBrowser**: A stunning, modern browser with frosted glass effects (Glassmorphism).
- **CustomizableBrowser**: A highly configurable browser with options for custom toolbars, colors, user agents, and functional settings.
- **ModalBrowser**: Easily preview links in a draggable bottom sheet.
- **InlineWebView**: A widget that can be embedded directly into your existing UI.

## Getting started

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  browser_webview: ^0.0.1
```

## Usage

### Enhanced Browser
```dart
EnhancedInAppBrowser.open(context, 'https://flutter.dev');
```

### Glass Browser (Modern UI)
```dart
GlassBrowser.open(context, 'https://dart.dev', title: 'Dart Language');
```

### Modal Preview
```dart
ModalBrowser.show(context, 'https://pub.dev');
```

### Inline Widget
```dart
InlineWebView(url: 'https://flutter.dev', height: 400);
```

## Example App

Check the `example` directory for a complete demonstration of all webview types.
