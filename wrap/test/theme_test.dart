import 'dart:ui';

import 'package:data_anno/data_anno.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrap/wrap.dart';
import 'package:wrap_test/wrap_test.dart';

void main() {
  testWidgets('adapt platform brightness', (t) async {
    await builder(
      (context) => [
        platformBrightness(MediaQuery.of(context).platformBrightness).asText,
        themeBrightness(context.findAndTrust<Theme>().brightness).asText,
        themeMode(context.findAndTrust<Settings>().themeMode).asText,
      ].asColumn(),
    )
        .render((context, child) => child.theme(
              duration: duration,
              light: const Theme.light(),
              dark: const Theme.dark(),
              mode: context.findAndTrust<Settings>().themeMode,
            ))
        .render((context, child) => child
            .handle(const Settings())
            .ensureDirection(context)
            .ensureMedia(context))
        .pump(t);

    // Initial value (system theme mode).
    await t.setPlatformBrightness(Brightness.light, duration);
    t.platformBrightness.expect(Brightness.light);
    platformBrightness(Brightness.light).expectFound;
    themeBrightness(Brightness.light).expectFound;
    themeMode(ThemeMode.system).expectFound;

    // Platform brightness change.
    await t.setPlatformBrightness(Brightness.dark, duration);
    t.platformBrightness.expect(Brightness.dark);
    platformBrightness(Brightness.dark).expectFound;
    themeBrightness(Brightness.dark).expectFound;
    themeMode(ThemeMode.system).expectFound;
  });

  testWidgets('theme mode change', (t) async {
    await builder(
      (context) => [
        platformBrightness(MediaQuery.of(context).platformBrightness).asText,
        themeBrightness(context.findAndTrust<Theme>().brightness).asText,
        themeMode(context.findAndTrust<ThemeMode>()).asText,
        toSystem.asText.onGesture(tap: () => context.update(ThemeMode.system)),
        toLight.asText.onGesture(tap: () => context.update(ThemeMode.light)),
        toDark.asText.onGesture(tap: () => context.update(ThemeMode.dark)),
      ].asColumn(),
    )
        .render((context, child) => child.theme(
              duration: duration,
              light: const Theme.light(),
              dark: const Theme.dark(),
              mode: context.findAndTrust<ThemeMode>(),
            ))
        .render((context, child) => child
            .handle(ThemeMode.system)
            .ensureDirection(context)
            .ensureMedia(context))
        .pump(t);

    // Initial value (system theme mode, brightness light).
    await t.setPlatformBrightness(Brightness.light, duration);
    t.platformBrightness.expect(Brightness.light);
    platformBrightness(Brightness.light).expectFound;
    themeBrightness(Brightness.light).expectFound;
    themeMode(ThemeMode.system).expectFound;

    // Brightness to dark.
    await t.tapText(toDark, duration);
    t.platformBrightness.expect(Brightness.light);
    platformBrightness(Brightness.light).expectFound;
    themeBrightness(Brightness.dark).expectFound;
    themeMode(ThemeMode.dark).expectFound;

    // Brightness to light.
    await t.tapText(toLight, duration);
    t.platformBrightness.expect(Brightness.light);
    platformBrightness(Brightness.light).expectFound;
    themeBrightness(Brightness.light).expectFound;
    themeMode(ThemeMode.light).expectFound;
  });
}

const duration = Duration(milliseconds: 123);

String platformBrightness(Brightness brightness) =>
    'Platform brightness: ${brightness.name}';

String themeBrightness(Brightness brightness) =>
    'Theme brightness: ${brightness.name}';

String themeMode(ThemeMode mode) => 'Theme mode: ${mode.name}';

const toSystem = 'to System';
const toLight = 'to Light';
const toDark = 'to Dark';

class Settings {
  const Settings({this.themeMode = ThemeMode.system});

  final ThemeMode themeMode;
}

class Theme with Lerp<Theme>, ThemeMixin<Theme> {
  const Theme.light({
    this.brightness = Brightness.light,
    this.background = const Color(0xffdedcda),
    this.foreground = const Color(0xff454648),
  });

  const Theme.dark({
    this.brightness = Brightness.dark,
    this.background = const Color(0xff121415),
    this.foreground = const Color(0xffcdcecf),
  });

  @override
  final Brightness brightness;

  @override
  final Color background;

  @override
  final Color foreground;

  @override
  String toString() => 'Theme(${brightness.name}: '
      '${foreground.value.toRadixString(16)} '
      'on ${background.value.toRadixString(16)})';

  Theme copyWith({
    Brightness? brightness,
    Color? background,
    Color? foreground,
  }) =>
      Theme.light(
        brightness: brightness ?? this.brightness,
        background: background ?? this.background,
        foreground: foreground ?? this.foreground,
      );

  @override
  Theme lerpTo(Theme another, double t) => copyWith(
        brightness: t < 0.5 ? brightness : another.brightness,
        background: Color.lerp(background, another.background, t),
        foreground: Color.lerp(foreground, another.foreground, t),
      );
}
