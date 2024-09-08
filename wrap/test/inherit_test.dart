import 'package:flutter_test/flutter_test.dart';
import 'package:wrap/wrap.dart';
import 'package:wrap_test/wrap_test.dart';

void main() {
  group('inherit', () {
    const message = 'it works';

    testWidgets('on build-in types', (t) async {
      await builder((context) => context
          .findAndTrust<String>()
          .asText
          .center
          .ensureDirection(context)
          .ensureMedia(context)).inherit(message).pump(t);

      expect(find.text(message), findsOneWidget);
    });

    testWidgets('on customized types', (t) async {
      await builder((context) => context
              .findAndTrust<MessageExample>()
              .message
              .asText
              .ensureDirection(context)
              .ensureMedia(context))
          .center
          .inherit(const MessageExample(message))
          .pump(t);

      expect(find.text(message), findsOneWidget);
    });
  });

  group('handle', () {
    const message1 = 'message1';
    const message2 = 'message2';

    testWidgets('inner update', (t) async {
      const change = 'change';
      var counter = 0;

      await builder((context) => [
                context.findAndTrust<String>().asText,
                change.asText.onGesture(
                  tap: () => context.checkAndUpdate(message2),
                )
              ].asColumn())
          .render((context, child) => child
              .handle(message1, onUpdate: (data) => counter++)
              .ensureDirection(context)
              .ensureMedia(context))
          .pump(t);

      // Initial value.
      expect(find.text(message1), findsOneWidget);
      expect(counter, 0);

      // Update the value.
      await t.tap(find.text(change));
      await t.pump();
      expect(find.text(message2), findsOneWidget);
      expect(counter, 1);
    });

    testWidgets('outer update', (t) async {
      String inner(String message) => 'inner: $message';
      String outer(String message) => 'outer: $message';
      const updateInner = 'update inner';
      const updateOuter = 'update outer';
      const message3 = 'message3';

      var counter = 0;

      await builder((context) {
        return [
          inner(context.findAndTrust<String>()).asText,
          outer(context.findAndTrust<MessageExample>().message).asText,
          updateInner.asText.onGesture(tap: () => context.update(message2)),
          updateOuter.asText.onGesture(
            tap: () => context.update(const MessageExample(message3)),
          )
        ].asColumn();
      })
          .render((context, child) => child.handle(
                context.findAndTrust<MessageExample>().message,
                onUpdate: (data) => counter++,
              ))
          .render((context, child) => child
              .handle(const MessageExample(message1))
              .ensureDirection(context)
              .ensureMedia(context))
          .pump(t);

      // Initial value.
      expect(find.text(inner(message1)), findsOneWidget);
      expect(find.text(outer(message1)), findsOneWidget);
      expect(find.text(updateInner), findsOneWidget);
      expect(find.text(updateOuter), findsOneWidget);
      expect(counter, 0);

      // Update inner, the outer won't change.
      await t.tap(find.text(updateInner));
      await t.pump();
      expect(find.text(inner(message2)), findsOneWidget);
      expect(find.text(outer(message1)), findsOneWidget);
      expect(counter, 1);

      // Update outer, the inner will change.
      await t.tap(find.text(updateOuter));
      await t.pump();
      expect(find.text(inner(message3)), findsOneWidget);
      expect(find.text(outer(message3)), findsOneWidget);
      expect(counter, 2);
    });
  });
}

class MessageExample {
  /// Wrapping a single text message for demonstration.
  ///
  /// 1. An encapsulation to avoid inherit the commonly used [String] type.
  /// 2. Also helps testing when there's need
  ///    to provide a type other than string.
  const MessageExample(this.message);

  final String message;
}
