import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wrap_test/wrap_test.dart';

void main() {
  testWidgets('pump', (t) async {
    await const Center().pump(t);
  });
}
