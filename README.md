# browser_webview

A comprehensive Flutter package providing multiple types of in-app webview experiences, from minimal wrappers to full-featured browsers with modern aesthetics.

[![pub package](https://img.shields.io/pub/v/browser_webview.svg)](https://pub.dev/packages/browser_webview)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📁 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center"><b>Enhanced Browser</b><br/><img src="https://raw.githubusercontent.com/bluedev-in/browser_webview/main/screenshots/enhanced_browser.jpeg" width="200"/></td>
      <td align="center"><b>Tabbed Browser</b><br/><img src="https://raw.githubusercontent.com/bluedev-in/browser_webview/main/screenshots/tabbed_browser.jpeg" width="200"/></td>
      <td align="center"><b>Glass Browser</b><br/><img src="https://raw.githubusercontent.com/bluedev-in/browser_webview/main/screenshots/glass_browser.jpeg" width="200"/></td>
    </tr>
    <tr>
      <td align="center"><b>Reader Mode</b><br/><img src="https://raw.githubusercontent.com/bluedev-in/browser_webview/main/screenshots/reader_browser.jpeg" width="200"/></td>
      <td align="center"><b>Customizable</b><br/><img src="https://raw.githubusercontent.com/bluedev-in/browser_webview/main/screenshots/customizable_browser.jpeg" width="200"/></td>
      <td align="center"><b>Simple Browser</b><br/><img src="https://raw.githubusercontent.com/bluedev-in/browser_webview/main/screenshots/simple_browser.jpeg" width="200"/></td>
    </tr>
    <tr>
      <td align="center"><b>Bottom Sheet</b><br/><img src="https://raw.githubusercontent.com/bluedev-in/browser_webview/main/screenshots/bottom_sheet_browser.jpeg" width="200"/></td>
      <td align="center"><b>Inline WebView</b><br/><img src="https://raw.githubusercontent.com/bluedev-in/browser_webview/main/screenshots/inline_browser.jpeg" width="200"/></td>
      <td></td>
    </tr>
  </table>
</div>

## ✨ Features

- **EnhancedInAppBrowser**: Full-featured browser with address bar, history, search, and desktop/mobile switching.
- **TabbedBrowser**: Support for multiple tabs with a beautiful tab switcher.
- **GlassBrowser**: Modern, premium look with frosted glass effects (Glassmorphism).
- **ReaderModeBrowser**: Focus on content by extracting text and removing distractions.
- **CustomizableBrowser**: Highly configurable theme colors, toolbars, and functional settings.
- **SimpleBrowser**: Clean, standard Material UI browser for simple links.
- **ModalBrowser**: Quick link previews in a draggable bottom sheet.
- **InlineWebView**: A widget that can be embedded directly into your existing layouts.
- **Fixed Scrolling**: Smooth scrolling experience even when nested inside other scroll views.

## 🚀 Getting started

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  browser_webview: ^0.0.1
```

## 🛠️ Usage

### Enhanced Browser
```dart
EnhancedInAppBrowser.open(context, 'https://flutter.dev');
```

### Tabbed Browser (Multi-tab)
```dart
TabbedBrowser.open(context, initialUrl: 'https://google.com');
```

### Glass Browser (Modern UI)
```dart
GlassBrowser.open(context, 'https://dart.dev', title: 'Dart Language');
```

### Reader Mode
```dart
ReaderModeBrowser.open(context, 'https://blog.flutter.dev');
```

### Customizable Browser
```dart
CustomizableBrowser.open(
  context,
  'https://flutter.dev',
  options: BrowserOptions(
    toolbarColor: Colors.deepOrange,
    progressBarColor: Colors.yellow,
    showBottomToolbar: true,
  ),
);
```

### Modal Preview
```dart
ModalBrowser.show(context, 'https://pub.dev');
```

### Inline Widget
```dart
InlineWebView(url: 'https://flutter.dev', height: 400);
```

## 💖 Sponsors

If you find this package helpful, consider supporting its development!

<a href="https://github.com/sponsors/bluedev-in">
  <img src="https://img.shields.io/badge/Sponsor-GitHub-ea4aaa?style=for-the-badge&logo=github-sponsors" alt="Sponsor" />
</a>

<br/>


## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Check the `example` & `screenshots` directory for a complete demonstration. Contributions are welcome!
