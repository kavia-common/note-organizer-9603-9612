import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:notes_frontend/data/repository/note_repository.dart';
import 'package:notes_frontend/providers/notes_provider.dart';
import 'package:notes_frontend/screens/home_screen.dart';
import 'package:notes_frontend/theme/app_theme.dart';

Widget _buildTestApp({required INoteRepository repo}) {
  return MultiProvider(
    providers: [
      Provider<INoteRepository>.value(value: repo),
      ChangeNotifierProvider<NotesProvider>(
        create: (context) => NotesProvider(repository: context.read<INoteRepository>())..initialize(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const HomeScreen(),
    ),
  );
}

void main() {
  testWidgets('Home shows title and FAB', (WidgetTester tester) async {
    final INoteRepository repo = MemoryNoteRepository();

    await tester.pumpWidget(_buildTestApp(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsOneWidget);
    expect(find.byKey(const Key('fab_add_note')), findsOneWidget);
  });

  testWidgets('Creating a note updates the list', (WidgetTester tester) async {
    final INoteRepository repo = MemoryNoteRepository();

    await tester.pumpWidget(_buildTestApp(repo: repo));
    await tester.pumpAndSettle();

    // Add a note via FAB -> editor.
    await tester.tap(find.byKey(const Key('fab_add_note')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field_title')), 'Test note');
    await tester.enterText(find.byKey(const Key('field_content')), 'Hello world');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back to home: card should appear.
    expect(find.text('Test note'), findsOneWidget);
  });
}
