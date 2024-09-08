import 'dart:ui';

/// 灰度颜色，常用于背景或主要文字显示。
extension MonoColors on Color {
  /// 纯白(不常用)。
  static const white = Color(0xffffffff);

  /// 纯黑(不常用)。
  static const black = Color(0xff000000);

  /// 雪白，略为有一点偏蓝色，模仿晴空之下雪地的光影效果。
  static const snow = Color(0xfffcfdfe);

  /// 纸白，略为有一点微黄，模仿没有添加漂白剂的纸张。
  static const paper = Color(0xffefedea);

  /// 月色灰白。
  static const lunar = Color(0xffdcdcdc);

  /// 墨水的颜色，有点偏深蓝的色调，黑的也不是特别深，模仿老式钢笔的颜色。
  static const ink = Color(0xff343637);

  /// 夜黑，略为带一点蓝色，模仿深夜的色调。
  static const night = Color(0xff232526);

  /// 煤炭般的黑色，略为偏红，模仿蜂窝煤或是炭笔的颜色。
  static const coal = Color(0xff100e0d);
}

/// 透明度颜色，常用于蒙版或阴影效果。
extension MaskColors on Color {
  /// 完全透明，常用语占位以确保区域点击可以被识别,
  /// 除此以外为避免不必要性能开销不建议使用。
  static const transparent = Color(0x00000000);
}
