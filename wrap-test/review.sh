flutter pub get || exit 1
dart format --output=none --set-exit-if-changed . || exit 1
dart analyze --fatal-infos || exit 1
flutter test || exit 1
