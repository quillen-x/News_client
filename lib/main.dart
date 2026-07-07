import 'dart:async';
import 'dart:io';

import 'package:data_statistics/db/db_helper.dart';
import 'package:data_statistics/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS || Platform.isMacOS) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  }
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      WindowOptions windowOptions = const WindowOptions(
          size: Size(1280, 768), center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,);
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }

  runApp(const MyApp());

  // 数据库初始化放到 UI 启动之后，避免阻塞首帧
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    unawaited(DbHelper().getDb());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 768),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: false,
          ),
          theme: ThemeData(
            fontFamily: 'AlibabaPuHuiTi',
            textTheme: TextTheme(
              labelSmall: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w300,
              ),
              bodyLarge: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
              bodyMedium: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
