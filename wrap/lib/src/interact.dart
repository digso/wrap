import 'package:flutter/widgets.dart';
import 'package:wrap/src/encapsulate.dart';
import 'package:wrap/src/gesture.dart';
import 'package:wrap/src/transform.dart';

extension WrapInteractiveContainer on Widget {
  InteractiveContainer interact() {
    return InteractiveContainer(child: this);
  }
}

class InteractiveContainer extends StatefulWidget {
  const InteractiveContainer({
    super.key,
    this.background = const Color(0x00000000), // Transparent.
    required this.child,
  });

  /// There must be a background layer to ensure the gesture will be detected.
  /// Even if this background is not specified,
  /// it will use transparent as default value.
  final Color background;
  final Widget child;

  @override
  State<InteractiveContainer> createState() => _InteractiveContainerState();
}

class _InteractiveContainerState extends State<InteractiveContainer> {
  final _transform = Matrix4.identity();

  var _deltaPosition = Offset.zero;

  void _panStart(DragStartDetails details) {
    _deltaPosition = details.localPosition - _transform.offset;
  }

  void _panUpdate(DragUpdateDetails details) {
    setState(() => _transform..offset = details.localPosition - _deltaPosition);
  }

  void _panEnd(DragEndDetails details) {
    _deltaPosition = Offset.zero;
  }

  @override
  Widget build(BuildContext context) => widget.child.center
      .transform(_transform)
      .clipRect(clipBehavior: Clip.antiAlias)
      .background(widget.background)
      .onGesture(
        panStart: _panStart,
        panUpdate: _panUpdate,
        panEnd: _panEnd,
      );
}
