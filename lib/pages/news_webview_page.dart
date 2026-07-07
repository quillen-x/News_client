import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class NewsWebViewHost extends StatefulWidget {
  final Widget child;

  const NewsWebViewHost({
    super.key,
    required this.child,
  });

  static void open(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    context.findAncestorStateOfType<_NewsWebViewHostState>()?.open(
          title: title,
          url: url,
        );
  }

  @override
  State<NewsWebViewHost> createState() => _NewsWebViewHostState();
}

class _NewsWebViewHostState extends State<NewsWebViewHost> {
  String? _title;
  WebViewController? _controller;
  int _loadingProgress = 0;

  void open({required String title, required String url}) {
    setState(() {
      _title = title;
      _loadingProgress = 0;
      _controller = _createController(url);
    });
  }

  void close() {
    if (_controller == null) return;
    setState(() {
      _controller = null;
      _title = null;
      _loadingProgress = 0;
    });
  }

  WebViewController _createController(String url) {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_defaultUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted && _controller != null) {
              setState(() => _loadingProgress = progress);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return controller;
  }

  static String get _defaultUserAgent {
    if (Platform.isMacOS) {
      return 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';
    }
    return 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller != null && _title != null)
          Positioned.fill(
            child: Material(
              color: Colors.white,
              child: Column(
                children: [
                  _buildToolbar(context),
                  if (_loadingProgress < 100)
                    LinearProgressIndicator(
                      value: _loadingProgress / 100,
                      minHeight: 2.h,
                    ),
                  Expanded(
                    child: WebViewWidget(controller: _controller!),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
         
          Expanded(
            child: SizedBox(
             
            ),
          ),
           IconButton(
            tooltip: '关闭页面',
            icon: const Icon(Icons.close, size: 18),
            onPressed: close,
          ),
       
        ],
      ),
    );
  }
}

class NewsWebViewPage {
  static void open(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    NewsWebViewHost.open(context, title: title, url: url);
  }
}
