dart pub get || exit 1
dart format --output=none --set-exit-if-changed . || exit 1
dart analyze --fatal-infos || exit 1
dart test || exit 1
