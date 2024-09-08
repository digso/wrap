import 'package:flutter/widgets.dart';

extension WrapTransform on Widget {
  /// Syntax sugar for [Transform].
  ///
  /// ```dart
  /// Transform(transform: xxx, child: ExampleWidget()); // before
  /// ExampleWidget().transform(xxx); // after
  /// ```
  Transform transform(
    Matrix4 transform, {
    AlignmentGeometry? alignment,
    bool transformHitTests = true,
    FilterQuality? filterQuality,
  }) =>
      Transform(
        transform: transform,
        alignment: alignment,
        transformHitTests: transformHitTests,
        filterQuality: filterQuality,
        child: this,
      );
}

extension Matrix4Optimization on Matrix4 {
  // Getter and setters for the translation components.
  double get dx => this[12];
  double get dy => this[13];
  set dx(double value) => this[12] = value;
  set dy(double value) => this[13] = value;

  /// ```dart
  /// ```
  Offset get offset => Offset(this[12], this[13]);

  /// Syntax sugar for transform on 2D plane.
  ///
  /// - You may refer to [offsetAs] if you are using doubles of x and y.
  /// - You may also use the getter and setter of [dx] and [dy].
  /// - This extension method is here to avoid unnecessary encapsulation
  ///   that will cause memory waste when using [Transform] with [Matrix4].
  ///
  /// ```dart
  /// matrix.setTranslation(Vector3(123, 456, 0)); // before
  /// matrix.offset = Offset(123, 456); // after
  /// ```
  set offset(Offset offset) => offsetAs(offset.dx, offset.dy);

  /// Syntax sugar for transform on 2D plane.
  ///
  /// - You may refer to the [offset] getter and setter
  ///   if you are using an [Offset] instance.
  /// - You may also use the getter and setter of [dx] and [dy].
  /// - This extension method is here to avoid unnecessary encapsulation
  ///   that will cause memory waste when using [Transform] with [Matrix4].
  ///
  /// ```dart
  /// matrix.setTranslation(Vector3(123, 456, 0)); // before
  /// matrix.offsetAs(123, 456); // after
  /// ```
  void offsetAs(double x, double y) {
    this[12] = x;
    this[13] = y;
  }
}
