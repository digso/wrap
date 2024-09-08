import 'package:flutter_test/flutter_test.dart';
import 'package:wrap/wrap.dart';
import 'package:wrap_test/wrap_test.dart';

void main() {
  testWidgets('text without material', (t) async {
    const message = 'it works';
    await builder((context) => message
        .asText // line break.
        .center
        .ensureDirection(context)
        .ensureMedia(context)).pump(t);

    expect(find.text(message), findsOneWidget);
  });
}
