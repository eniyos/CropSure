import 'package:cropsure/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('email rejects empty and invalid', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('farmer@cropsure.app'), isNull);
    });

    test('password enforces minimum length', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('password123'), isNull);
    });

    test('confirmPassword matches', () {
      expect(Validators.confirmPassword('a', 'b'), isNotNull);
      expect(Validators.confirmPassword('same', 'same'), isNull);
    });

    test('fullName requires meaningful value', () {
      expect(Validators.fullName(' '), isNotNull);
      expect(Validators.fullName('Ravi Kumar'), isNull);
    });
  });
}
