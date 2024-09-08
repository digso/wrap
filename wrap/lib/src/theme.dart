import 'package:data_anno/data_anno.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wrap/src/animation.dart';
import 'package:wrap/src/encapsulate.dart';
import 'package:wrap/src/inherit.dart';

/// 定义颜色主题的混合(mixin)，自定义颜色主题时须包含(with)此混合。
///
/// 1. 必要的属性在此处受到语法限制是用 getter 和 setter 定义的,
///    但在重写(override)的时候建议设定为不可变属性(final parameter)，
///    这样可以避免不必要的性能下降。
/// 2. 此混合基于[Lerp]，因此包含此混合的类须实现[Lerp]混合。
///
/// ```dart
/// class Theme with Lerp<Theme>, ThemeMixin<Theme> {
///   const Theme({
///     this.brightness = Brightness.light,
///     this.background = const Color(0xfffefdfa),
///     this.foreground = const Color(0xff353638),
///   });
///
///   @override
///   final Brightness brightness;
///
///   @override
///   final Color background;
///
///   @override
///   final Color foreground;
///
///   Theme copyWith({
///     Brightness? brightness,
///     Color? background,
///     Color? foreground,
///   }) =>
///       Theme(
///         brightness: brightness ?? this.brightness,
///         background: background ?? this.background,
///         foreground: foreground ?? this.foreground,
///       );
///
///   @override
///   Theme lerpTo(Theme another, double t) => copyWith(
///         brightness: t < 0.5 ? brightness : another.brightness,
///         background: Color.lerp(background, another.background, t),
///         foreground: Color.lerp(foreground, another.foreground, t),
///       );
/// }
/// ```
mixin ThemeMixin<T> on Lerp<T> {
  Brightness get brightness;
  Color get background;
  Color get foreground;
}

/// 这和`material`库中已经提供了`ThemeMode`枚举一摸一样,
/// 只是这里为了避免强行引入`material`库而写了一份,
/// 虽然代码一模一样，但毕竟不是同一个，所以不要混用。
enum ThemeMode { system, light, dark }

extension WrapTheme on Widget {
  ThemeHandler theme<T extends ThemeMixin<T>>({
    required T light,
    required T dark,
    ThemeMode mode = ThemeMode.system,
    Duration duration = Durations.theme,
    Curve curve = Curves.easeInOut,
  }) =>
      ThemeHandler<T>(
        light: light,
        dark: dark,
        mode: mode,
        duration: duration,
        curve: curve,
        child: this,
      );
}

class ThemeHandler<T extends ThemeMixin<T>> extends StatefulWidget {
  const ThemeHandler({
    super.key,
    required this.light,
    required this.dark,
    this.mode = ThemeMode.system,
    this.duration = Durations.theme,
    this.curve = Curves.easeInOut,
    required this.child,
  });

  final T light;
  final T dark;
  final ThemeMode mode;
  final Duration duration;
  final Curve curve;
  final Widget child;

  @override
  State<ThemeHandler<T>> createState() => _ThemeHandlerState<T>();
}

class _ThemeHandlerState<T extends ThemeMixin<T>>
    extends State<ThemeHandler<T>> {
  /// 根据颜色模式([ThemeMode])和当前设备的颜色主题,
  /// 获取当前应当使用的明暗模式([Brightness])。
  Brightness get adaptBrightness => widget.mode == ThemeMode.system
      ? MediaQuery.of(context).platformBrightness
      : widget.mode == ThemeMode.light
          ? Brightness.light
          : Brightness.dark;

  @override
  void didUpdateWidget(covariant ThemeHandler<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode) setState(() {});
  }

  @override
  Widget build(BuildContext context) => widget.child.animate<T>(
        duration: widget.duration,
        curve: widget.curve,
        adaptBrightness == Brightness.dark ? widget.dark : widget.light,
        (context, data, child) => child
            .inherit(data)
            .foreground(context, data.foreground)
            .background(data.background),
      );
}
