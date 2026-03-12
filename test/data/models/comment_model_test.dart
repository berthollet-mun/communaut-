import 'package:community/data/models/comment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CommentModel parses created_at and updated_at as local instants', () {
    final model = CommentModel.fromJson({
      'id': 1,
      'content': 'Bonjour',
      'nom': 'Doe',
      'prenom': 'Jane',
      'email': 'jane@example.com',
      'created_at': '2026-03-11 10:15:30',
      'updated_at': '2026-03-11 10:20:00',
    });

    expect(model.created_at.toUtc(), DateTime.utc(2026, 3, 11, 10, 15, 30));
    expect(model.updated_at, isNotNull);
    expect(model.updated_at!.toUtc(), DateTime.utc(2026, 3, 11, 10, 20, 0));
  });
}
