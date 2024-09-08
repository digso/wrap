import 'package:test/test.dart' as t;

extension WrapExpect on Object? {
  void expect(Object? actual) => t.expect(this, actual);
}
