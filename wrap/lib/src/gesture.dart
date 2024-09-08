import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

extension WrapGesture on Widget {
  /// 对手势监测([GestureDetector])的封装。
  GestureDetector onGesture({
    // 点击(tap)
    void Function(TapDownDetails details)? tapDown,
    void Function(TapUpDetails details)? tapUp,
    void Function()? tap,
    void Function()? tapCancel,

    // 平移(pan)
    void Function(DragDownDetails details)? panDown,
    void Function(DragStartDetails details)? panStart,
    void Function(DragUpdateDetails details)? panUpdate,
    void Function(DragEndDetails details)? panEnd,
    void Function()? panCancel,

    // 缩放(scale)
    void Function(ScaleStartDetails details)? scaleStart,
    void Function(ScaleUpdateDetails details)? scaleUpdate,
    void Function(ScaleEndDetails details)? scaleEnd,
  }) =>
      GestureDetector(
        // 点击(tap)
        onTapDown: tapDown,
        onTapUp: tapUp,
        onTap: tap,
        onTapCancel: tapCancel,

        // 平移(pan)
        onPanDown: panDown,
        onPanStart: panStart,
        onPanUpdate: panUpdate,
        onPanEnd: panEnd,
        onPanCancel: panCancel,

        // 缩放(scale)
        onScaleStart: scaleStart,
        onScaleUpdate: scaleUpdate,
        onScaleEnd: scaleEnd,

        // 子组件封装
        child: this,
      );

  /// 对鼠标监测([MouseRegion])的封装
  MouseRegion onMouse() => MouseRegion(child: this);

  /// 对交互监听([Listener])的封装,
  /// 相较于[GestureDetector]和[MouseRegion]更加底层,
  /// 也能够支持更丰富连贯的手势。
  Listener onPointer({
    // 原生光标指针(pointer)封装
    void Function(PointerDownEvent event)? down,
    void Function(PointerMoveEvent event)? move,
    void Function(PointerUpEvent event)? up,
    void Function(PointerHoverEvent event)? hover,
    void Function(PointerCancelEvent event)? cancel,

    // 平移(pan)和缩放(zoom)
    void Function(PointerPanZoomStartEvent event)? panZoomStart,
    void Function(PointerPanZoomUpdateEvent event)? panZoomUpdate,
    void Function(PointerPanZoomEndEvent event)? panZoomEnd,

    // 信号传递控制
    void Function(PointerSignalEvent event)? signal,
    HitTestBehavior behavior = HitTestBehavior.deferToChild,
  }) =>
      Listener(
        // 原生光标指针(pointer)封装
        onPointerDown: down,
        onPointerMove: move,
        onPointerUp: up,
        onPointerHover: hover,
        onPointerCancel: cancel,

        // 平移(pan)和缩放(zoom)
        onPointerPanZoomStart: panZoomStart,
        onPointerPanZoomUpdate: panZoomUpdate,
        onPointerPanZoomEnd: panZoomEnd,

        // 信号传递控制
        onPointerSignal: signal,
        behavior: behavior,

        // 子组件封装
        child: this,
      );
}
