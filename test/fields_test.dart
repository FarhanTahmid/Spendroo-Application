import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/db/database.dart';
import 'package:spendroo/core/entitlements/entitlements.dart';
import 'package:spendroo/core/entitlements/plan_guard.dart';
import 'package:spendroo/features/cashbook/cashbook_pages.dart';
import 'package:spendroo/features/cashbook/cashbook_repository.dart';
import 'package:spendroo/features/fields/field_inputs.dart';
import 'package:spendroo/features/fields/field_repository.dart';
import 'package:spendroo/features/fields/fields_page.dart';
import 'package:spendroo/features/history/history_repository.dart';
import 'package:spendroo/features/history/history_text.dart';
import 'package:spendroo/features/profile/profile_repository.dart';

import 'cashbook_access_test.dart' show grant, shop, shopId;
import 'personal_screens_test.dart' show ScreenHarness;
import 'plan_test.dart' show answer;
import 'team_test.dart' show FixedProfile;

/// The owner's plan: Business has custom fields, Plus does not.
Entitlements fieldPlan({bool business = true}) => Entitlements(
      answer(plan: business ? 'business' : 'plus', features: {
        F.customFields: {'kind': 'flag', 'enabled': business},
      }),
      fetchedAt: DateTime.now().toUtc(),
    );

void main() {
  group('values', () {
    test('a typed number is kept the way the server keeps it', () {
      expect(canonicalNumber('1,250.50'), '1250.5');
      expect(canonicalNumber('১২৫০.৫'), '1250.5');
      expect(canonicalNumber(' -0012 '), '-12');
      expect(canonicalNumber('-0'), '0');
      expect(canonicalNumber('.5'), '0.5');
      expect(canonicalNumber('12.'), '12');
      for (final wrong in ['', 'abc', '1e3', '1.2.3', '--1', '1.1234567']) {
        expect(canonicalNumber(wrong), isNull, reason: wrong);
      }
    });

    test('values are saved tidied, blank ones dropped, unknown ones kept', () {
      final number = _field('n', FieldKind.number);
      final text = _field('t', FieldKind.text);
      expect(
        valuesToSave([number, text], {'n': '1,200', 't': ' INV-1 ', 'gone': 'kept', 'blank': '  '}),
        {'n': '1200', 't': 'INV-1', 'gone': 'kept'},
      );
      expect(decodeValues('{"a":"x","b":"","c":3}'), {'a': 'x'});
      expect(decodeValues('not json'), isEmpty);
    });
  });

  group('repository', () {
    late ScreenHarness h;
    late Cashbook book;
    late FieldRepository fields;
    late CashbookRepository cashbook;

    Future<void> start(WidgetTester tester, {bool business = true}) async {
      h = ScreenHarness(tester);
      await h.run(() => h.db.into(h.db.workspaces).insert(shop('owner')));
      final plan = PlanGuard(h.db, () => fieldPlan(business: business));
      cashbook = CashbookRepository(h.db, h.store, plan);
      fields = FieldRepository(h.db, h.store, plan);
      final id = await h.run(() => CashbookRepository(h.db, h.store).createCashbook(shopId, 'Till', 'BDT'));
      book = (await h.run(() => cashbook.watchCashbook(id).first))!.book;
      await h.run(() => h.db.delete(h.db.outbox).go());
    }

    Future<List<OutboxData>> sent() => h.run(() => h.db.select(h.db.outbox).get());

    testWidgets('fields are made in order, and pinning one unpins the one before', (tester) async {
      await start(tester);
      final invoice = await h.run(() => fields.add(book, name: ' Invoice no ', kind: FieldKind.text, showInList: true));
      await h.run(() => fields.add(book, name: 'Party', kind: FieldKind.choice, options: ['Rahim', 'Karim']));
      var list = await h.run(() => fields.fieldsOf(book.id));
      expect([for (final f in list) (f.name, f.position, f.showInList)], [('Invoice no', 0, true), ('Party', 1, false)]);
      expect(optionsOf(list[1]), ['Rahim', 'Karim']);
      expect(await h.run(() => fields.nameTaken(book.id, 'INVOICE NO')), isTrue);
      expect(await h.run(() => fields.nameTaken(book.id, 'Invoice no', except: invoice)), isFalse);

      await h.run(() => h.db.delete(h.db.outbox).go());
      await h.run(() => fields.update(book, list[1], name: 'Party', options: ['Rahim', 'Karim'], isRequired: false, showInList: true));
      list = await h.run(() => fields.fieldsOf(book.id));
      expect([for (final f in list) f.showInList], [false, true]);
      expect([for (final m in await sent()) jsonDecode(m.data)], [{'show_in_list': false}, {'show_in_list': true}]);

      // Only the fields that moved go out
      await h.run(() => h.db.delete(h.db.outbox).go());
      final third = await h.run(() => fields.add(book, name: 'Due', kind: FieldKind.date));
      await h.run(() => h.db.delete(h.db.outbox).go());
      list = await h.run(() => fields.fieldsOf(book.id));
      await h.run(() => fields.reorder(book, [list[0], list[2], list[1]]));
      expect({for (final m in await sent()) m.rowId: jsonDecode(m.data)}, {third: {'position': 1}, list[1].id: {'position': 2}});
      await h.stop();
    });

    testWidgets('values go with a new entry, and later as a change of their own', (tester) async {
      await start(tester);
      final invoice = await h.run(() => fields.add(book, name: 'Invoice no', kind: FieldKind.text));
      await h.run(() => h.db.delete(h.db.outbox).go());
      final id = await h.run(() => cashbook.addEntry(book,
          entryType: 'cash_in', amountMinor: 500, entryDate: '2026-10-01', customValues: {invoice: 'INV-1', 'x': ' '}));
      expect(jsonDecode((await sent()).single.data)['custom_values'], {invoice: 'INV-1'});

      await h.run(() => h.db.delete(h.db.outbox).go());
      var entry = await h.run(() => (h.db.select(h.db.entries)..where((e) => e.id.equals(id))).getSingle());
      expect(customValuesOf(entry), {invoice: 'INV-1'});
      await h.run(() => cashbook.updateEntry(entry, amountMinor: 600, entryDate: '2026-10-01', customValues: {invoice: 'INV-2'}));
      expect([for (final m in await sent()) jsonDecode(m.data)], [
        {'amount_minor': 600},
        {'custom_values': {invoice: 'INV-2'}},
      ]);

      // Unchanged values send nothing more
      await h.run(() => h.db.delete(h.db.outbox).go());
      entry = await h.run(() => (h.db.select(h.db.entries)..where((e) => e.id.equals(id))).getSingle());
      await h.run(() => cashbook.updateEntry(entry, amountMinor: 700, entryDate: '2026-10-01', customValues: {invoice: 'INV-2'}));
      expect([for (final m in await sent()) jsonDecode(m.data)], [{'amount_minor': 700}]);
      await h.stop();
    });

    testWidgets('without the plan nothing is made or filled in, but a field can still go', (tester) async {
      await start(tester, business: false);
      await h.run(() => h.store.upsertRow('entry_fields', {
            'id': 'f1', 'workspace_id': shopId, 'cashbook_id': book.id, 'name': 'Invoice no', 'kind': 'text',
            'created_at': '2026-10-01', 'updated_at': '2026-10-01',
          }));
      Future<Object?> refusal(Future<void> Function() action) => h.run(() async {
            try {
              await action();
            } on PlanLimitException catch (error) {
              return error.feature;
            }
            return null;
          });
      expect(await refusal(() => fields.add(book, name: 'Party', kind: FieldKind.text)), F.customFields);
      expect(
        await refusal(() => cashbook.addEntry(book,
            entryType: 'cash_in', amountMinor: 1, entryDate: '2026-10-01', customValues: {'f1': 'x'})),
        F.customFields,
      );
      // An entry without values is fine, and a field can still be removed
      expect(await refusal(() => cashbook.addEntry(book, entryType: 'cash_in', amountMinor: 1, entryDate: '2026-10-01')),
          isNull);
      await h.run(() async => fields.delete((await fields.fieldsOf(book.id)).single));
      expect(await h.run(() => fields.fieldsOf(book.id)), isEmpty);
      await h.stop();
    });
  });

  group('screens', () {
    Future<(ScreenHarness, Cashbook)> open(WidgetTester tester, {bool business = true}) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.reset);
      final h = ScreenHarness(
        tester,
        plan: fieldPlan(business: business),
        overrides: [profileProvider.overrideWith(() => FixedProfile('me'))],
      );
      final repo = CashbookRepository(h.db, h.store);
      final id = await h.run(() => repo.createCashbook(shopId, 'Till', 'BDT'));
      return (h, (await h.run(() => repo.watchCashbook(id).first))!.book);
    }

    Future<String> addField(ScreenHarness h, Cashbook book, String name, String kind,
            {List<String> options = const [], bool isRequired = false, bool pinned = false}) =>
        h.run(() => FieldRepository(h.db, h.store)
            .add(book, name: name, kind: kind, options: options, isRequired: isRequired, showInList: pinned));

    Future<Entry> lastEntry(ScreenHarness h) => h.run(() =>
        (h.db.select(h.db.entries)..orderBy([(e) => OrderingTerm.desc(e.createdAt)])..limit(1)).getSingle());

    testWidgets('an empty book suggests fields, and one tap starts the sheet with it', (tester) async {
      final (h, book) = await open(tester);
      await h.show(FieldsPage(bookId: book.id), space: shop('owner'));
      expect(find.text('Track what matters to your business'), findsOneWidget);

      await tester.tap(find.widgetWithText(ActionChip, 'Due date'));
      await h.settle();
      expect(find.text('New field'), findsWidgets);
      expect(find.widgetWithText(TextField, 'Due date'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await h.settle();

      final made = (await h.run(() => FieldRepository(h.db, h.store).fieldsOf(book.id))).single;
      expect((made.name, made.kind), ('Due date', FieldKind.date));
      expect(find.text('1 of 20 fields'), findsOneWidget);
      await h.stop();
    });

    testWidgets('a choice needs options, and a name may be used once', (tester) async {
      final (h, book) = await open(tester);
      await addField(h, book, 'Party', FieldKind.text);
      await h.show(FieldsPage(bookId: book.id), space: shop('owner'));
      await tester.tap(find.byType(FloatingActionButton));
      await h.settle();

      await tester.enterText(find.widgetWithText(TextField, 'Field name').first, 'party');
      await tester.tap(find.text('Choice'));
      await h.settle();
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await h.settle();
      expect(find.text('This book already has a field called that.'), findsOneWidget);
      expect(find.text('Add at least one option.'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Field name').first, 'Size');
      await tester.enterText(find.widgetWithText(TextField, 'Add an option'), 'Small');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await h.settle();
      await tester.enterText(find.widgetWithText(TextField, 'Add an option'), 'Big');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await h.settle();
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await h.settle();

      final size = (await h.run(() => FieldRepository(h.db, h.store).fieldsOf(book.id))).last;
      expect(size.name, 'Size');
      expect(optionsOf(size), ['Small', 'Big']);
      await h.stop();
    });

    testWidgets('the entry form asks for each kind, holds back a required one, and saves the values', (tester) async {
      final (h, book) = await open(tester);
      final invoice = await addField(h, book, 'Invoice no', FieldKind.text, isRequired: true);
      final weight = await addField(h, book, 'Weight', FieldKind.number);
      final party = await addField(h, book, 'Party', FieldKind.choice, options: ['Rahim', 'Karim']);
      await addField(h, book, 'Due', FieldKind.date);
      await h.show(EntryFormPage(book: book, entryType: 'cash_out'), space: shop('owner'));

      expect(find.text('Invoice no *'), findsOneWidget);
      expect(find.text('Weight'), findsOneWidget);
      expect(find.text('Rahim'), findsOneWidget, reason: 'a few options show as chips');
      expect(find.text('Due'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, '250');
      await tester.tap(find.text('Save'));
      await h.settle();
      expect(find.text('Fill this in.'), findsOneWidget);
      expect(await h.run(() => h.db.select(h.db.entries).get()), isEmpty);

      await tester.enterText(find.widgetWithText(TextFormField, 'Invoice no *'), 'INV-1042');
      await tester.enterText(find.widgetWithText(TextFormField, 'Weight'), '1,200.50');
      await tester.tap(find.text('Rahim'));
      await h.settle();
      await tester.tap(find.text('Save'));
      await h.settle();
      expect(customValuesOf(await lastEntry(h)), {invoice: 'INV-1042', weight: '1200.5', party: 'Rahim'});
      await h.stop();
    });

    testWidgets('a field made required later never holds back an entry made before', (tester) async {
      final (h, book) = await open(tester);
      await h.run(() => CashbookRepository(h.db, h.store)
          .addEntry(book, entryType: 'cash_out', amountMinor: 100, entryDate: '2026-10-01', title: 'Old'));
      await addField(h, book, 'Invoice no', FieldKind.text, isRequired: true);
      final entry = await lastEntry(h);
      await h.show(EntryFormPage(book: book, entryType: 'cash_out', entry: entry), space: shop('owner'));
      expect(find.text('Invoice no'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await h.settle();
      expect(find.text('Fill this in.'), findsNothing);
      await h.stop();
    });

    testWidgets('the list shows the pinned field and the details show every value', (tester) async {
      final (h, book) = await open(tester);
      final invoice = await addField(h, book, 'Invoice no', FieldKind.text, pinned: true);
      final weight = await addField(h, book, 'Weight', FieldKind.number);
      await h.run(() => CashbookRepository(h.db, h.store).addEntry(book,
          entryType: 'cash_out', amountMinor: 100, entryDate: '2026-10-01', title: 'Rice',
          customValues: {invoice: '1042', weight: '1250000'}));
      await h.show(CashbookPage(bookId: book.id), space: shop('viewer'));
      expect(find.textContaining('Invoice no 1042'), findsOneWidget);

      await tester.tap(find.text('Rice'));
      await h.settle();
      expect(find.text('Entry'), findsOneWidget);
      expect(find.textContaining('1,250,000'), findsOneWidget);
      await h.stop();
    });

    testWidgets('a contributor fills in fields on a new entry', (tester) async {
      final (h, book) = await open(tester);
      final invoice = await addField(h, book, 'Invoice no', FieldKind.text);
      await h.run(() => grant(h.db, book.id, 'contributor'));
      await h.show(EntryFormPage(book: book, entryType: 'cash_in'), space: shop('staff'));
      await tester.enterText(find.byType(TextFormField).first, '90');
      await tester.enterText(find.widgetWithText(TextFormField, 'Invoice no'), 'INV-9');
      await tester.tap(find.text('Save'));
      await h.settle();
      final pushed = await h.run(() => h.db.select(h.db.outbox).get());
      expect(jsonDecode(pushed.last.data)['custom_values'], {invoice: 'INV-9'});
      await h.stop();
    });

    testWidgets('after a downgrade values are shown, not changed, and the page says why', (tester) async {
      final (h, book) = await open(tester, business: false);
      final invoice = await addField(h, book, 'Invoice no', FieldKind.text);
      await h.run(() => h.store.upsertRow('entries', {
            'id': 'e1', 'workspace_id': shopId, 'cashbook_id': book.id, 'entry_type': 'cash_in', 'amount_minor': 100,
            'currency': 'BDT', 'entry_date': '2026-10-01', 'title': 'Old', 'custom_values': {invoice: 'INV-7'},
            'created_at': '2026-10-01', 'updated_at': '2026-10-01',
          }));
      final entry = await lastEntry(h);
      await h.show(EntryFormPage(book: book, entryType: 'cash_in', entry: entry), space: shop('owner'));
      expect(find.text('Your plan keeps these values as they are. Upgrade to change them.'), findsOneWidget);
      expect(find.textContaining('INV-7'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Invoice no'), findsNothing);
      await h.stop();
    });

    testWidgets('after a downgrade the fields page says why, and fields cannot be moved', (tester) async {
      final (h, book) = await open(tester, business: false);
      await addField(h, book, 'Invoice no', FieldKind.text);
      await h.show(FieldsPage(bookId: book.id), space: shop('owner'));
      expect(find.text('Custom fields come with Business'), findsOneWidget);
      expect(find.text('Invoice no'), findsOneWidget);
      expect(find.byIcon(Icons.drag_handle_rounded), findsNothing);
      await h.stop();
    });

    testWidgets('history names a field value by its field', (tester) async {
      final (h, _) = await open(tester);
      late String label;
      late String? value;
      const change = FieldChange(FieldChange.customValue, null, '1250.5', name: 'Weight', kind: FieldKind.number);
      final event = HistoryEvent.fromJson({
        'id': 'x', 'at': '2026-10-01T00:00:00Z', 'kind': 'entry', 'action': 'updated', 'object_id': 'e',
        'changes': [], 'subject': '',
      });
      await h.show(Builder(builder: (context) {
        label = fieldLabel(context, event, change);
        value = fieldValue(context, event, change, change.after);
        return const SizedBox();
      }), space: shop('owner'));
      expect((label, value), ('Weight', '1,250.5'));
      await h.stop();
    });
  });
}

EntryField _field(String id, String kind) => EntryField(
      id: id,
      workspaceId: shopId,
      version: 0,
      serverSeq: 0,
      createdAt: '',
      updatedAt: '',
      cashbookId: 'b',
      name: id,
      kind: kind,
      options: '[]',
      isRequired: false,
      showInList: false,
      position: 0,
    );
