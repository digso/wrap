/// 链式编程的语法糖以提升编程效率和代码可读性。
///
/// 所有封装都相当于是一层函数封装，虽然 Dart 编译时会优化代码,
/// 但这种封装可能会阻止或外移静态优化标识(const)的使用,
/// 因此在经常使用的场景要注意优化，以避免不必要性能开销。
///
/// 使用之后代码可以简化成这样:
///
/// ```dart
/// import 'package:wrap/wrap.dart';
/// import 'package:flutter_test/flutter_test.dart';
///
/// void main() {
///   testWidgets('on build-in types', (t) async {
///     await t.pumpWidget(
///       builder((context) => 'message'.asText
///           .center
///           .ensureDirection(context)
///           .ensureMedia(context))
///     );
///     expect(find.text(message), findsOneWidget);
///   });
/// }
/// ```
///
/// 而使用前代码要写这么多:
///
/// ```dart
/// import 'package:flutter/widgets.dart';
/// import 'package:flutter_test/flutter_test.dart';
///
/// void main() {
///   testWidgets('ensure text', (t) async {
///     await t.pumpWidget(
///       Builder(
///         builder: (context) {
///           return MediaQuery(
///             data: MediaQuery.maybeOf(context) ??
///                 MediaQueryData.fromView(View.of(context)),
///             child: Directionality(
///               textDirection: Directionality.maybeOf(context) ??
///                   TextDirection.ltr,
///               child: const Center(
///                 child: Text('message'),
///               ),
///             ),
///           );
///         },
///       ),
///     );
///     expect(find.text('message'), findsOneWidget);
///   });
/// }
/// ```
library encapsulate;

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

/// 将[Builder]组件封装为函数以为内部组件提供当前位置的[BuildContext]。
/// 不必担心封装带来的性能问题，因为[Builder]自身也没有静态优化(`const`)。
Widget builder(Widget Function(BuildContext context) builder) =>
    Builder(builder: builder);

extension WrapContext on Widget {
  /// 类似于[builder]，但是包裹在某个组件之外。
  /// 例如这样就能在同一个组件的`build`方法中多次获取更新的[BuildContext]。
  ///
  /// ```dart
  /// class App extends StatelessWidget {
  ///   const App({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return builder((context) {
  ///       final message = context.findAndTrust<String>();
  ///       return 'message is: $message'.asText.center;
  ///     })
  ///         .render((context, child) => child.inherit('message'))
  ///         .theme(light: const Theme.light(), dark: const Theme.dark())
  ///         .ensureDirection(context)
  ///         .ensureMedia(context);
  ///   }
  /// }
  /// ```
  Widget render(Widget Function(BuildContext context, Widget child) render) =>
      Builder(builder: (context) => render(context, this));
}

extension WrapMedia on Widget {
  /// 在当前组件外根指定的[data]参数包裹媒体序列[MediaQuery]的环境
  /// (能使用`MediaQuery.of(context)`)。
  ///
  /// ```dart
  /// MediaQuery(data: media, child: const Example()); // 使用前
  /// const Example().wrapMedia(media); // 使用后
  /// ```
  Widget media(MediaQueryData data) => MediaQuery(data: data, child: this);

  /// 确保当前组件被包裹在媒体序列[MediaQuery]环境中
  /// (能使用`MediaQuery.of(context)`),
  /// 如果没有指定[MediaQueryData]的默认值([defaultValue]),
  /// 则会从[View]中获取平台的默认值。
  /// 若有确定的[MediaQueryData]则更推荐使用[media]方法。
  ///
  /// ```dart
  /// MediaQuery(data: View.of(context), child: const Example()); // 使用前
  /// const Example().ensureMedia(context); // 使用后
  /// ```
  Widget ensureMedia(BuildContext context, {MediaQueryData? defaultValue}) {
    final contextMedia = MediaQuery.maybeOf(context);
    return contextMedia == null
        ? media(defaultValue ?? MediaQueryData.fromView(View.of(context)))
        : this;
  }
}

extension WrapDirection on Widget {
  /// 在当前组件外根据指定的文字方向([TextDirection])参数([direction])
  /// 包裹[Directionality]的环境(能使用`Directionality.of(context)`)。
  ///
  /// ```dart
  /// // 使用前
  /// Directionality(textDirection: direction, child: const Example());
  /// const Example().direction(direction); // 使用后
  /// ```
  Widget direction(TextDirection direction) =>
      Directionality(textDirection: direction, child: this);

  /// 确保当前组件被包裹在文字方向[Directionality]环境中
  /// (能使用`Directionality.of(context)`),
  /// 如果没有指定[TextDirection]的默认值([defaultValue]),
  /// 则默认为文字方向从左到右([TextDirection.ltr]),
  /// 若有确定的[TextDirection]则更推荐使用[direction]方法。
  ///
  /// ```dart
  /// MediaQuery(data: View.of(context), child: const Example()); // 使用前
  /// const Example().ensureMedia(context); // 使用后
  /// ```
  Widget ensureDirection(
    BuildContext context, {
    TextDirection defaultValue = TextDirection.ltr,
  }) {
    final contextDirection = Directionality.maybeOf(context);
    return contextDirection == null ? direction(defaultValue) : this;
  }
}

extension WrapColor on Widget {
  ColoredBox background(Color color) => ColoredBox(color: color, child: this);

  Widget foreground(BuildContext context, Color color) =>
      textForeground(context, color).iconForeground(context, color);

  IconTheme iconForeground(BuildContext context, Color color) => IconTheme(
      data: IconTheme.of(context).copyWith(color: color), child: this);

  DefaultTextStyle textForeground(BuildContext context, Color color) =>
      DefaultTextStyle(
          style: DefaultTextStyle.of(context).style.copyWith(color: color),
          child: this);
}

extension WrapLayout on Widget {
  /// 将当前组件居中布局。
  ///
  /// ```dart
  /// const Center(child: Example()); // 使用前
  /// const Example().center; // 使用后
  /// ```
  Center get center => Center(child: this);

  Align align(
    AlignmentGeometry alignment, {
    double? widthFactor,
    double? heightFactor,
  }) {
    return Align(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      child: this,
    );
  }

  /// 在当前组件外包裹尺寸修饰(使用[SizedBox]),
  /// 使用前请确保您已经了解[SizedBox]组件的约束特性。
  ///
  /// ```dart
  /// SizedBox(width: 123, height: 456, child: ExampleWidget()); // 使用前
  /// ExampleWidget().size(123, 456); // 使用后
  /// ```
  SizedBox size(double width, double height) =>
      SizedBox(width: width, height: height, child: this);

  ConstrainedBox constrain({
    double minWidth = 0,
    double maxWidth = double.infinity,
    double minHeight = 0,
    double maxHeight = double.infinity,
  }) =>
      ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          maxWidth: maxWidth,
          minHeight: minHeight,
          maxHeight: maxHeight,
        ),
        child: this,
      );
}

extension WrapClip on Widget {
  ClipRect clipRect({
    CustomClipper<Rect>? clipper,
    Clip clipBehavior = Clip.hardEdge,
  }) =>
      ClipRect(clipper: clipper, clipBehavior: clipBehavior, child: this);

  ClipRRect clipRRect({
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    CustomClipper<RRect>? clipper,
    Clip clipBehavior = Clip.antiAlias,
  }) =>
      ClipRRect(
        borderRadius: borderRadius,
        clipper: clipper,
        clipBehavior: clipBehavior,
        child: this,
      );
}

extension AsText on String {
  /// 将字符串(`String`)转换为文本组件([Text])。
  ///
  /// ```dart
  /// const Text('message'); // 使用前
  /// 'message'.asText; // 使用后
  /// ```
  Text get asText => Text(this);
}

extension AsList on List<Widget> {
  /// 将组件列表包裹为列组件([Column])，此方法参数列表和原[Column]相同。
  ///
  /// ```dart
  /// const Column(children: [Example1(), Example2()]); // 使用前
  /// const [Example1(), Example2()].asColumn(); // 使用后
  /// ```
  Column asColumn({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
  }) =>
      Column(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: this,
      );

  /// 将组件列表包裹为行组件([Row])，此方法参数列表和原[Row]相同。
  ///
  /// ```dart
  /// const Row(children: [Example1(), Example2()]); // 使用前
  /// const [Example1(), Example2()].asRow(); // 使用后
  /// ```
  Row asRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    TextBaseline? textBaseline,
  }) =>
      Row(
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: this,
      );
}
