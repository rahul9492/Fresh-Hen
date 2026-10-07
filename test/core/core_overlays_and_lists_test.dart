import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/core/utils/context_x.dart';
import 'package:fresh_hen/core/widgets/app_bottom_sheet.dart';
import 'package:fresh_hen/core/widgets/app_scaffold.dart';
import 'package:fresh_hen/core/widgets/app_search_bar.dart';
import 'package:fresh_hen/core/widgets/app_snackbar.dart';
import 'package:fresh_hen/core/widgets/bottom_action_bar.dart';
import 'package:fresh_hen/core/widgets/confirm_dialog.dart';
import 'package:fresh_hen/core/widgets/empty_state_kit.dart';
import 'package:fresh_hen/core/widgets/filter_sheet_scaffold.dart';
import 'package:fresh_hen/core/widgets/paginated_list_view.dart';
import 'package:fresh_hen/core/widgets/tab_close_button.dart';
import 'package:go_router/go_router.dart';

import '../support/pump.dart';

/// Opens [open] from a button, so dialogs and sheets have a real navigator.
Future<void> _pumpOpener(
  WidgetTester t,
  Future<void> Function(BuildContext) open, {
  bool reduceMotion = false,
}) async {
  await pumpWidgetApp(
    t,
    Builder(
      builder: (context) => Center(
        child: ElevatedButton(onPressed: () => open(context), child: const Text('open')),
      ),
    ),
    reduceMotion: reduceMotion,
  );
}

void main() {
  setUpWidgetTests();

  group('confirm dialog', () {

    testWidgets('confirm returns true', (t) async {
      bool? result;
      await _pumpOpener(t, (c) async {
        result = await showConfirmDialog(c, title: 'Delete?', message: 'Sure?', confirmLabel: 'Delete');
      });
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);
      expect(find.text('Sure?'), findsOneWidget);

      await t.tap(find.text('Delete'));
      await t.pumpAndSettle();
      expect(result, isTrue);
      expect(find.text('Delete?'), findsNothing);
    });

    testWidgets('cancel returns false', (t) async {
      bool? result;
      await _pumpOpener(t, (c) async {
        result = await showConfirmDialog(c, title: 'T', message: 'M', cancelLabel: 'Not now');
      });
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text('Not now'));
      await t.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('tapping outside counts as cancel', (t) async {
      bool? result;
      await _pumpOpener(t, (c) async => result = await showConfirmDialog(c, title: 'T', message: 'M'));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('default labels are Confirm and Cancel', (t) async {
      await _pumpOpener(t, (c) => showConfirmDialog(c, title: 'T', message: 'M'));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('prefer-cancel makes Cancel the filled button', (t) async {
      await _pumpOpener(t, (c) => showConfirmDialog(c, title: 'T', message: 'M', preferCancel: true));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Confirm'), findsOneWidget);
    });

    testWidgets('by default Confirm is the filled button', (t) async {
      await _pumpOpener(t, (c) => showConfirmDialog(c, title: 'T', message: 'M'));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Confirm'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('prefer-cancel: the main button still returns false, the other true', (t) async {
      bool? result;
      await _pumpOpener(t, (c) async {
        result = await showConfirmDialog(c, title: 'T', message: 'M', preferCancel: true, confirmLabel: 'Leave');
      });
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text('Leave'));
      await t.pumpAndSettle();
      expect(result, isTrue);
    });

    testWidgets('icon and note appear only when given', (t) async {
      await _pumpOpener(t, (c) => showConfirmDialog(c, title: 'T', message: 'M'));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.delete), findsNothing);
      expect(find.text('Your cart is saved'), findsNothing);
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();

      await _pumpOpener(
        t,
        (c) => showConfirmDialog(c, title: 'T', message: 'M', icon: Icons.delete, note: 'Your cart is saved'),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.text('Your cart is saved'), findsOneWidget);
    });
  });

  group('snackbars', () {
    Future<void> show(WidgetTester t, void Function(BuildContext) action) async {
      await _pumpOpener(t, (c) async => action(c));
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
    }

    testWidgets('info, success and error messages show', (t) async {
      await show(t, (c) => AppSnackbar.info(c, 'Saved for later'));
      expect(find.text('Saved for later'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);

      await show(t, (c) => AppSnackbar.success(c, 'Order placed'));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Order placed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      await show(t, (c) => AppSnackbar.error(c, 'Failed'));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    });

    testWidgets('a new message replaces the old one', (t) async {
      await _pumpOpener(t, (c) async {
        AppSnackbar.info(c, 'first');
        AppSnackbar.info(c, 'second');
      });
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(find.text('second'), findsOneWidget);
      expect(find.text('first'), findsNothing);
    });

    testWidgets('an action runs its callback', (t) async {
      var undone = 0;
      await show(t, (c) => AppSnackbar.info(c, 'Removed', actionLabel: 'Undo', onAction: () => undone++));
      await t.tap(find.text('Undo'));
      expect(undone, 1);
    });

    testWidgets('it closes by itself after its duration, even with an action', (t) async {
      await show(t, (c) => AppSnackbar.info(c, 'Removed', actionLabel: 'Undo', duration: const Duration(seconds: 2)));
      expect(find.text('Removed'), findsOneWidget);
      await t.pump(const Duration(seconds: 3));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Removed'), findsNothing);
    });

    testWidgets('showError takes a message or any error object', (t) async {
      await show(t, (c) => c.showError('Plain text'));
      expect(find.text('Plain text'), findsOneWidget);

      await show(t, (c) => c.showError(const AppException('From the server')));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('From the server'), findsOneWidget);

      await show(t, (c) => c.showError(Exception('boom')));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    });

    testWidgets('showSnack and showSuccess are shortcuts', (t) async {
      await show(t, (c) => c.showSnack('hello'));
      expect(find.text('hello'), findsOneWidget);
      await show(t, (c) => c.showSuccess('done'));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('done'), findsOneWidget);
    });
  });

  group('bottom sheets', () {
    testWidgets('a sheet shows its title, body and footer', (t) async {
      await _pumpOpener(
        t,
        (c) => showAppSheet<void>(
          c,
          builder: (_) => const AppSheet(title: 'Pick one', footer: Text('footer'), child: Text('body')),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Pick one'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.text('footer'), findsOneWidget);
    });

    testWidgets('the close button dismisses it, and a sheet can return a value', (t) async {
      String? result;
      await _pumpOpener(t, (c) async {
        result = await showAppSheet<String>(
          c,
          builder: (ctx) => AppSheet(
            title: 'T',
            showClose: true,
            child: TextButton(onPressed: () => Navigator.pop(ctx, 'picked'), child: const Text('choose')),
          ),
        );
      });
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.byType(SheetCloseButton));
      await t.pumpAndSettle();
      expect(result, isNull);
      expect(find.text('T'), findsNothing);

      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text('choose'));
      await t.pumpAndSettle();
      expect(result, 'picked');
    });

    testWidgets('without a title there is no header, and the trailing widget shows with one', (t) async {
      await _pumpOpener(t, (c) => showAppSheet<void>(c, builder: (_) => const AppSheet(child: Text('only body'))));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('only body'), findsOneWidget);
      expect(find.byType(SheetCloseButton), findsNothing);
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();

      await _pumpOpener(
        t,
        (c) => showAppSheet<void>(c, builder: (_) => const AppSheet(title: 'T', trailing: Text('Reset'), child: Text('b'))),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('the filter sheet wires Reset and the apply button', (t) async {
      var resets = 0;
      var applies = 0;
      await _pumpOpener(
        t,
        (c) => showAppSheet<void>(
          c,
          builder: (_) => FilterSheetScaffold(
            onReset: () => resets++,
            onApply: () => applies++,
            child: const Text('fields'),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Show results'), findsOneWidget);

      await t.tap(find.text('Reset'));
      await t.tap(find.text('Show results'));
      expect((resets, applies), (1, 1));
    });

    testWidgets('the filter sheet title and button label can be changed', (t) async {
      await _pumpOpener(
        t,
        (c) => showAppSheet<void>(
          c,
          builder: (_) => FilterSheetScaffold(
            title: 'Sort',
            applyLabel: 'Done',
            onReset: () {},
            onApply: () {},
            child: const Text('x'),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });

  group('bottom action bar', () {
    testWidgets('shows info rows above the main button', (t) async {
      await pumpWidgetApp(
        t,
        const BottomActionBar(button: Text('PAY'), children: [Text('row one'), Text('row two')]),
      );
      expect(find.text('row one'), findsOneWidget);
      expect(find.text('row two'), findsOneWidget);
      expect(find.text('PAY'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
      // The button sits below the rows.
      expect(t.getTopLeft(find.text('PAY')).dy, greaterThan(t.getTopLeft(find.text('row two')).dy));
    });

    testWidgets('works with only a button', (t) async {
      await pumpWidgetApp(t, const BottomActionBar(button: Text('PAY')));
      expect(find.byType(Divider), findsNothing);
    });

    testWidgets('an info row shows its title, subtitle, extra and link, and each can be tapped', (t) async {
      var link = 0;
      var row = 0;
      await pumpWidgetApp(
        t,
        ActionInfoRow(
          icon: Icons.home,
          title: const Text('Delivering to Home'),
          subtitle: 'Flat 1, Sector 62',
          extra: const Text('45 mins'),
          actionLabel: 'Change',
          onAction: () => link++,
          onTap: () => row++,
        ),
      );
      expect(find.text('Delivering to Home'), findsOneWidget);
      expect(find.text('Flat 1, Sector 62'), findsOneWidget);
      expect(find.text('45 mins'), findsOneWidget);

      await t.tap(find.text('Change'));
      expect(link, 1);
      await t.tap(find.text('Delivering to Home'));
      expect(row, 1);
    });

    testWidgets('an info row without subtitle or link is just icon and title', (t) async {
      await pumpWidgetApp(t, const ActionInfoRow(icon: Icons.home, title: Text('Hi')));
      expect(find.byType(LinkAction), findsNothing);
    });

    testWidgets('a long subtitle is cut at the given line count', (t) async {
      await pumpWidgetApp(
        t,
        ActionInfoRow(
          icon: Icons.home,
          title: const Text('T'),
          subtitle: 'word ' * 80,
          subtitleMaxLines: 1,
        ),
      );
      final text = t.widget<Text>(find.textContaining('word'));
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });

  group('app scaffold', () {
    testWidgets('shows the title, body and bottom bar', (t) async {
      await pumpWidgetApp(
        t,
        const AppScaffold(title: 'Checkout', body: Text('body'), bottom: Text('bottom')),
        scaffold: false,
      );
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
      expect(find.text('bottom'), findsOneWidget);
    });

    testWidgets('no title means no app bar', (t) async {
      await pumpWidgetApp(t, const AppScaffold(body: Text('body')), scaffold: false);
      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('loading blocks the page behind a spinner', (t) async {
      await pumpWidgetApp(t, const AppScaffold(loading: true, body: Text('body')), scaffold: false);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('pull to refresh is there only when a refresh action is given', (t) async {
      await pumpWidgetApp(t, const AppScaffold(body: Text('body')), scaffold: false);
      expect(find.byType(RefreshIndicator), findsNothing);
      await pumpWidgetApp(t, AppScaffold(body: ListView(), onRefresh: () async {}), scaffold: false);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  group('search bar', () {
    testWidgets('reports typing straight away when there is no debounce', (t) async {
      final seen = <String>[];
      await pumpWidgetApp(t, AppSearchBar(onChanged: seen.add));
      await t.enterText(find.byType(TextField), 'chi');
      expect(seen, ['chi']);
    });

    testWidgets('waits for a pause in typing when a debounce is set', (t) async {
      final seen = <String>[];
      await pumpWidgetApp(t, AppSearchBar(debounce: const Duration(milliseconds: 300), onChanged: seen.add));
      await t.enterText(find.byType(TextField), 'c');
      await t.pump(const Duration(milliseconds: 200));
      await t.enterText(find.byType(TextField), 'ch');
      await t.pump(const Duration(milliseconds: 200));
      expect(seen, isEmpty);
      await t.pump(const Duration(milliseconds: 200));
      expect(seen, ['ch']); // only the final value, once
    });

    testWidgets('the clear button appears with text, empties the field and reports empty', (t) async {
      final seen = <String>[];
      await pumpWidgetApp(t, AppSearchBar(onChanged: seen.add));
      expect(find.byIcon(Icons.close_rounded), findsNothing);

      await t.enterText(find.byType(TextField), 'eggs');
      await t.pump();
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      await t.tap(find.byIcon(Icons.close_rounded));
      await t.pump();
      expect(t.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
      expect(seen.last, '');
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('clearing cancels a pending debounced search', (t) async {
      final seen = <String>[];
      await pumpWidgetApp(t, AppSearchBar(debounce: const Duration(milliseconds: 300), onChanged: seen.add));
      await t.enterText(find.byType(TextField), 'eggs');
      await t.pump();
      await t.tap(find.byIcon(Icons.close_rounded));
      await t.pump(const Duration(seconds: 1));
      expect(seen, ['']); // the stale "eggs" never fires
    });

    testWidgets('uses the controller it is given, and leaves it alive', (t) async {
      final controller = TextEditingController(text: 'start');
      addTearDown(controller.dispose);
      await pumpWidgetApp(t, AppSearchBar(controller: controller));
      expect(find.text('start'), findsOneWidget);
      await pumpWidgetApp(t, const SizedBox());
      controller.text = 'still usable'; // would throw if the bar had disposed it
    });

    testWidgets('the hint is shown', (t) async {
      await pumpWidgetApp(t, const AppSearchBar(hint: 'Search chicken'));
      expect(find.text('Search chicken'), findsOneWidget);
    });

    testWidgets('read-only looks like a field but only reacts to taps', (t) async {
      var taps = 0;
      await pumpWidgetApp(t, AppSearchBar.readOnly(hint: 'Search items', onTap: () => taps++));
      expect(find.byType(TextField), findsNothing);
      await t.tap(find.text('Search items'));
      expect(taps, 1);
    });
  });

  group('paginated list', () {
    Widget list({
      required List<int> items,
      bool hasMore = false,
      bool isLoadingMore = false,
      required VoidCallback onLoadMore,
      Future<void> Function()? onRefresh,
    }) =>
        SizedBox(
          height: 400,
          child: PaginatedListView<int>(
            items: items,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
            onLoadMore: onLoadMore,
            onRefresh: onRefresh,
            itemBuilder: (_, i) => SizedBox(height: 100, child: Text('item $i')),
          ),
        );

    testWidgets('shows its items, and a spinner footer only while more pages remain', (t) async {
      await pumpWidgetApp(t, list(items: [1, 2], onLoadMore: () {}));
      expect(find.text('item 1'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await pumpWidgetApp(t, list(items: [1, 2], hasMore: true, onLoadMore: () {}));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('asks for more when the end comes near', (t) async {
      var loads = 0;
      final items = List.generate(20, (i) => i);
      await pumpWidgetApp(t, list(items: items, hasMore: true, onLoadMore: () => loads++));
      await t.drag(find.byType(ListView), const Offset(0, -300));
      expect(loads, 0); // still far from the end

      await t.drag(find.byType(ListView), const Offset(0, -2000));
      await t.pump();
      expect(loads, greaterThan(0));
    });

    testWidgets('does not ask again while a page is loading, or when there is no more', (t) async {
      var loads = 0;
      final items = List.generate(20, (i) => i);
      await pumpWidgetApp(t, list(items: items, hasMore: true, isLoadingMore: true, onLoadMore: () => loads++));
      await t.drag(find.byType(ListView), const Offset(0, -3000));
      await t.pump();
      expect(loads, 0);

      await pumpWidgetApp(t, list(items: items, onLoadMore: () => loads++));
      await t.drag(find.byType(ListView), const Offset(0, -3000));
      await t.pump();
      expect(loads, 0);
    });

    testWidgets('pull to refresh exists only with a refresh action', (t) async {
      await pumpWidgetApp(t, list(items: [1], onLoadMore: () {}));
      expect(find.byType(RefreshIndicator), findsNothing);
      await pumpWidgetApp(t, list(items: [1], onLoadMore: () {}, onRefresh: () async {}));
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  group('tab close button', () {
    Future<void> pumpRouter(WidgetTester t, {required String start, List<String> stack = const []}) async {
      t.view.physicalSize = const Size(1080, 2340);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
      final router = GoRouter(
        initialLocation: start,
        routes: [
          GoRoute(path: Routes.home, builder: (_, _) => const Scaffold(body: Text('HOME'))),
          GoRoute(path: '/before', builder: (_, _) => Scaffold(body: Center(child: Builder(
            builder: (c) => TextButton(onPressed: () => c.push('/tab'), child: const Text('open tab')),
          )))),
          GoRoute(
            path: '/tab',
            builder: (_, _) => Scaffold(
              appBar: AppBar(leading: const TabCloseButton(), leadingWidth: TabCloseButton.width),
              body: const Text('TAB'),
            ),
          ),
        ],
      );
      await t.pumpWidget(MaterialApp.router(routerConfig: router));
      await t.pumpAndSettle();
    }

    testWidgets('with nothing to go back to, it goes Home', (t) async {
      await pumpRouter(t, start: '/tab');
      expect(find.text('TAB'), findsOneWidget);
      await t.tap(find.byType(TabCloseButton));
      await t.pumpAndSettle();
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('when opened on top of another page, it goes back to it', (t) async {
      await pumpRouter(t, start: '/before');
      await t.tap(find.text('open tab'));
      await t.pumpAndSettle();
      expect(find.text('TAB'), findsOneWidget);

      await t.tap(find.byType(TabCloseButton));
      await t.pumpAndSettle();
      expect(find.text('open tab'), findsOneWidget);
      expect(find.text('HOME'), findsNothing);
    });

    testWidgets('has a Back tooltip', (t) async {
      await pumpRouter(t, start: '/tab');
      expect(find.byTooltip('Back'), findsOneWidget);
    });
  });

  group('empty state kit', () {
    testWidgets('text, steps and action show what they are given and the action fires', (t) async {
      var taps = 0;
      await pumpWidgetApp(
        t,
        EmptyStateEntrance(
          child: Column(
            children: [
              const EmptyStateText(title: 'Title', message: 'Message'),
              const EmptyStateSteps(steps: [(Icons.search, 'One'), (Icons.favorite, 'Two'), (Icons.bolt, 'Three')]),
              EmptyStateAction(label: 'Go', icon: Icons.storefront, onPressed: () => taps++),
              const EmptyStateChip(icon: Icons.egg, size: 16),
            ],
          ),
        ),
      );
      await t.pump(const Duration(seconds: 1));
      for (final s in ['Title', 'Message', 'One', 'Two', 'Three', 'Go']) {
        expect(find.text(s), findsOneWidget, reason: s);
      }
      await t.tap(find.text('Go'));
      expect(taps, 1);
    });

    testWidgets('the entrance fades the content in', (t) async {
      await pumpWidgetApp(t, const EmptyStateEntrance(child: Text('hello')));
      double opacity() => t.widget<Opacity>(find.descendant(of: find.byType(EmptyStateEntrance), matching: find.byType(Opacity))).opacity;
      await t.pump(const Duration(milliseconds: 30));
      expect(opacity(), lessThan(1));
      await t.pump(const Duration(seconds: 1));
      expect(opacity(), 1);
    });

    testWidgets('a floating accent moves, and phase offsets it from the others', (t) async {
      final controller = AnimationController(vsync: const TestVSync(), duration: const Duration(seconds: 2));
      addTearDown(controller.dispose);
      await pumpWidgetApp(
        t,
        Stack(children: [
          FloatingBob(key: const Key('a'), animation: controller, child: const SizedBox(width: 4, height: 4)),
          FloatingBob(key: const Key('b'), animation: controller, phase: 0.5, child: const SizedBox(width: 4, height: 4)),
        ]),
      );
      Offset at(String k) => t.getTopLeft(find.descendant(of: find.byKey(Key(k)), matching: find.byType(SizedBox)));
      final a0 = at('a');
      expect(at('a'), isNot(at('b'))); // different phase, different place

      controller.value = 0.5;
      await t.pump();
      expect(at('a'), isNot(a0));
    });

    testWidgets('a floating accent can be shifted from its resting place', (t) async {
      final controller = AnimationController(vsync: const TestVSync());
      addTearDown(controller.dispose);
      await pumpWidgetApp(
        t,
        Stack(children: [
          FloatingBob(animation: controller, child: const SizedBox(key: Key('plain'), width: 4, height: 4)),
          FloatingBob(animation: controller, dx: 50, dy: 20, child: const SizedBox(key: Key('moved'), width: 4, height: 4)),
        ]),
      );
      final plain = t.getTopLeft(find.byKey(const Key('plain')));
      final moved = t.getTopLeft(find.byKey(const Key('moved')));
      expect(moved - plain, const Offset(50, 20));
    });
  });
}
