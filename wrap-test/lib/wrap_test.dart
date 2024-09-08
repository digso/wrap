import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' as t show expect;
import 'package:flutter_test/flutter_test.dart' hide expect;

export 'package:wrap_expect/wrap_expect.dart';

extension WrapTestedWidget on Widget {
  /// 刷新测试环境的语法糖。
  ///
  /// ```dart
  /// testWidget('xxx', (t) async {
  ///   await t.pumpWidget(ExampleWidget()); // 使用前
  ///   await ExampleWidget().pump(t); // 使用后
  /// });
  /// ```
  Future<void> pump(WidgetTester t) async => t.pumpWidget(this);
}

extension WrapWidgetTester on WidgetTester {
  /// 获取当前测试环境下的平台颜色主题。
  ///
  /// ```dart
  /// testWidget('xxx', (t) async {
  ///   print(t.platformDispatcher.platformBrightness); // 使用前
  ///   print(t.platformBrightness); // 使用后
  /// });
  /// ```
  Brightness get platformBrightness => platformDispatcher.platformBrightness;

  /// 设置当前测试环境下的平台颜色主题。
  /// 1. 设置生效之前需要进行测试环境刷新。
  /// 2. 也可考虑使用更方便的[setPlatformBrightness]方法。
  ///
  /// ```dart
  /// testWidget('xxx', (t) async {
  ///   // 使用前
  ///   t.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
  ///
  ///   t.platformBrightness = Brightness.dark; // 使用后
  ///   await t.pump(); // 别忘了刷新测试环境
  /// });
  /// ```
  set platformBrightness(Brightness brightness) =>
      platformDispatcher.platformBrightnessTestValue = brightness;

  /// 设置当前测试环境下的平台颜色主题并等待刷新时间。
  /// 刷新时间([duration])主要是用于测试动画的情况。
  ///
  /// ```dart
  /// const duration = Duration(milliseconds: 123);
  /// testWidget('xxx', (t) async {
  ///   // 使用前
  ///   t.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
  ///   await t.pumpAndSettle(duration);
  ///
  ///   // 使用后
  ///   await t.setPlatformBrightness(Brightness.dark, duration);
  /// });
  /// ```
  Future<void> setPlatformBrightness(
    Brightness brightness, [
    Duration? duration,
  ]) async {
    platformDispatcher.platformBrightnessTestValue = brightness;
    return duration == null ? pump() : pumpAndSettle(duration);
  }

  /// 点击屏幕上制定文字的语法糖。
  ///
  /// 1. 点击之后会自动刷新，不需要额外手动刷新。
  /// 2. 可以专门设置刷新之后所需要等待的时间([duration], 常用于动画)。
  /// 3. 当指定的[target]文字不能在屏幕上找到时，会抛出异常并测试失败。
  ///
  /// ```dart
  /// const duration = Duration(milliseconds: 123);
  /// testWidget('xxx', (t) async {
  ///   // 使用前
  ///   await t.tap(find.text('message'));
  ///   await t.pumpAndSettle(duration);
  ///
  ///   // 使用后
  ///   await t.tapText('message', duration);
  /// });
  /// ```
  Future<void> tapText(String target, [Duration? duration]) async {
    await tap(find.text(target));
    return duration == null ? pump() : pumpAndSettle(duration);
  }
}

extension WrapFindText on String {
  /// 在测试中期望当前文字可以在组件树中被找到。
  ///
  /// 注意：该扩展可能会降低代码可读性，但可以简化代码编写。
  /// 如果这段代码阅读比编写更加重要，就不建议使用这种语法糖。
  ///
  /// ```dart
  /// expect(find.text('message'), findsOneWidget); // 使用前
  /// 'message'.expectFound; // 使用后
  /// ```
  void get expectFound => t.expect(find.text(this), findsOneWidget);

  /// 在测试中期望此文字无法在组件树中被找到。
  ///
  /// 注意：该扩展可能会降低代码可读性，但可以简化代码编写。
  /// 如果这段代码阅读比编写更加重要，就不建议使用这种语法糖。
  ///
  /// ```dart
  /// expect(find.text('message'), findsNothing); // 使用前
  /// 'message'.expectNotFound; // 使用后
  /// ```
  void get expectNotFound => t.expect(find.text(this), findsNothing);
}
