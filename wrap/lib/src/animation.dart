import 'package:data_anno/data_anno.dart';
import 'package:flutter/widgets.dart';

extension Durations on Duration {
  static const animationDefault = Duration(milliseconds: 265);
  static const theme = Duration(milliseconds: 325);
}

extension WrapAnimationBuilder on Widget {
  AnimationBuilder animate<T extends Lerp<T>>(
    T data,
    Widget Function(BuildContext context, T data, Widget child) builder, {
    Duration duration = Durations.animationDefault,
    Curve curve = Curves.ease,
  }) =>
      AnimationBuilder<T>(
        duration: duration,
        curve: curve,
        data: data,
        builder: builder,
        child: this,
      );
}

class AnimationBuilder<T extends Lerp<T>> extends StatefulWidget {
  const AnimationBuilder({
    super.key,
    this.duration = Durations.animationDefault,
    this.curve = Curves.easeInOut,
    required this.builder,
    required this.data,
    required this.child,
  });

  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext context, T data, Widget child) builder;
  final T data;
  final Widget child;

  @override
  State<AnimationBuilder<T>> createState() => _AnimationBuilderState<T>();
}

class _AnimationBuilderState<T extends Lerp<T>>
    extends State<AnimationBuilder<T>> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late T _previousData = widget.data;
  late T _data = _previousData;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(() {
        setState(() {
          _data = _previousData.lerpTo(widget.data, _controller.value);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AnimationBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_data != widget.data) {
      _previousData = _data;
      _controller
        ..reset()
        ..animateTo(
          _controller.upperBound,
          duration: widget.duration,
          curve: widget.curve,
        );
    }
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _data, widget.child);
}
