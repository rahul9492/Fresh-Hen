import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/errors/app_exception.dart';
import 'package:fresh_hen/core/widgets/app_button.dart';
import 'package:fresh_hen/core/widgets/app_card.dart';
import 'package:fresh_hen/core/widgets/app_image.dart';
import 'package:fresh_hen/core/widgets/app_text_field.dart';
import 'package:fresh_hen/core/widgets/applied_filters_row.dart';
import 'package:fresh_hen/core/widgets/async_view.dart';
import 'package:fresh_hen/core/widgets/brand_badge.dart';
import 'package:fresh_hen/core/widgets/choice_chip_group.dart';
import 'package:fresh_hen/core/widgets/dashed_divider.dart';
import 'package:fresh_hen/core/widgets/error_view.dart';
import 'package:fresh_hen/core/widgets/filter_button.dart';
import 'package:fresh_hen/core/widgets/loading_overlay.dart';
import 'package:fresh_hen/core/widgets/price_text.dart';
import 'package:fresh_hen/core/widgets/product_image.dart';
import 'package:fresh_hen/core/widgets/small_widgets.dart';
import 'package:fresh_hen/core/widgets/status_chip.dart';

import '../support/pump.dart';

void main() {
  setUpWidgetTests();

  group('AppButton', () {
    testWidgets('shows its label and runs the action when tapped', (t) async {
      var taps = 0;
      await pumpWidgetApp(t, AppButton(label: 'Confirm', onPressed: () => taps++));
      expect(find.text('Confirm'), findsOneWidget);
      await t.tap(find.text('Confirm'));
      expect(taps, 1);
    });

    testWidgets('while loading it shows a spinner instead of the label and ignores taps', (t) async {
      var taps = 0;
      await pumpWidgetApp(t, AppButton(label: 'Confirm', loading: true, onPressed: () => taps++));
      expect(find.text('Confirm'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await t.tap(find.byType(FilledButton), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('without an action it is disabled', (t) async {
      await pumpWidgetApp(t, const AppButton(label: 'Confirm', onPressed: null));
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });

    testWidgets('fills the width and takes the given height', (t) async {
      await pumpWidgetApp(t, AppButton(label: 'Go', height: 60, onPressed: () {}));
      final size = t.getSize(find.byType(FilledButton));
      expect(size.height, 60);
      expect(size.width, greaterThan(300));
    });
  });

  group('AppCard and CardTitle', () {
    testWidgets('a plain card shows its child and is not tappable', (t) async {
      await pumpWidgetApp(t, const AppCard(child: Text('Inside')));
      expect(find.text('Inside'), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('a card with onTap reacts to taps', (t) async {
      var taps = 0;
      await pumpWidgetApp(t, AppCard(onTap: () => taps++, child: const Text('Tap me')));
      await t.tap(find.text('Tap me'));
      expect(taps, 1);
    });

    testWidgets('the card title can carry a trailing widget', (t) async {
      await pumpWidgetApp(t, const CardTitle('Bill details', trailing: Text('Edit')));
      expect(find.text('Bill details'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });
  });

  group('AppTextField', () {
    testWidgets('shows the hint, reports changes and submissions', (t) async {
      String? changed;
      String? submitted;
      await pumpWidgetApp(
        t,
        AppTextField(hint: 'Mobile', onChanged: (v) => changed = v, onSubmitted: (v) => submitted = v),
      );
      expect(find.text('Mobile'), findsOneWidget);
      await t.enterText(find.byType(TextFormField), '98765');
      expect(changed, '98765');
      await t.testTextInput.receiveAction(TextInputAction.done);
      expect(submitted, '98765');
    });

    testWidgets('shows a validation error and no character counter', (t) async {
      final key = GlobalKey<FormState>();
      await pumpWidgetApp(
        t,
        Form(
          key: key,
          child: AppTextField(maxLength: 10, validator: (v) => (v ?? '').isEmpty ? 'Required' : null),
        ),
      );
      expect(find.text('0/10'), findsNothing);
      key.currentState!.validate();
      await t.pump();
      expect(find.text('Required'), findsOneWidget);
    });
  });

  group('small pieces', () {
    testWidgets('status chip shows its label', (t) async {
      await pumpWidgetApp(t, const StatusChip(label: 'Delivered'));
      expect(find.text('Delivered'), findsOneWidget);
    });

    testWidgets('loading overlay covers the page only while loading', (t) async {
      await pumpWidgetApp(t, const LoadingOverlay(loading: false, child: Text('Page')));
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await pumpWidgetApp(t, const LoadingOverlay(loading: true, child: Text('Page')));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ModalBarrier), findsWidgets);
    });

    testWidgets('section header shows an action only when given a label', (t) async {
      var taps = 0;
      await pumpWidgetApp(t, SectionHeader(title: 'Popular', actionLabel: 'See all', onAction: () => taps++));
      await t.tap(find.text('See all'));
      expect(taps, 1);

      await pumpWidgetApp(t, const SectionHeader(title: 'Popular'));
      expect(find.text('See all'), findsNothing);
    });

    testWidgets('rating label shows the stars and a compact count', (t) async {
      await pumpWidgetApp(t, const RatingLabel(rating: 4.5, count: 12400));
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(12.4K)'), findsOneWidget);
    });

    testWidgets('the non-veg mark and brand badge render', (t) async {
      await pumpWidgetApp(t, const Column(children: [NonVegMark(), BrandBadge(label: 'FRESH')]));
      expect(find.byType(NonVegMark), findsOneWidget);
      expect(find.text('FRESH'), findsOneWidget);
    });

    testWidgets('the terms footer names both documents', (t) async {
      await pumpWidgetApp(t, const TermsFooter());
      expect(find.textContaining('Terms of Service', findRichText: true), findsOneWidget);
      expect(find.textContaining('Privacy Policy', findRichText: true), findsOneWidget);
    });

    testWidgets('a dashed divider fills the width', (t) async {
      await pumpWidgetApp(t, const DashedDivider(height: 2));
      final box = t.getSize(find.byType(DashedDivider));
      expect(box.height, 2);
      expect(box.width, greaterThan(300));
    });
  });

  group('PriceText', () {
    testWidgets('shows only the price when there is no discount', (t) async {
      await pumpWidgetApp(t, const PriceText(price: 80));
      expect(find.textContaining('₹80', findRichText: true), findsOneWidget);
      expect(find.textContaining('off', findRichText: true), findsNothing);
    });

    testWidgets('shows the struck-through MRP and the discount percentage', (t) async {
      await pumpWidgetApp(t, const PriceText(price: 80, mrp: 100, showDiscount: true));
      expect(find.textContaining('₹100', findRichText: true), findsOneWidget);
      expect(find.textContaining('20% off', findRichText: true), findsOneWidget);
    });

    testWidgets('hides the discount unless asked, and ignores an MRP at or below the price', (t) async {
      await pumpWidgetApp(t, const PriceText(price: 80, mrp: 100));
      expect(find.textContaining('off', findRichText: true), findsNothing);

      await pumpWidgetApp(t, const PriceText(price: 80, mrp: 80, showDiscount: true));
      expect(find.textContaining('off', findRichText: true), findsNothing);
      await pumpWidgetApp(t, const PriceText(price: 80, mrp: 50, showDiscount: true));
      expect(find.textContaining('₹50', findRichText: true), findsNothing);
    });
  });

  group('ChoiceChipGroup', () {
    testWidgets('marks the selected value and reports a new pick', (t) async {
      String? picked;
      await pumpWidgetApp(
        t,
        ChoiceChipGroup<String>(
          values: const ['a', 'b', 'c'],
          selected: 'b',
          label: (v) => v.toUpperCase(),
          onSelected: (v) => picked = v,
        ),
      );
      final chips = t.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
      expect(chips.map((c) => c.selected), [false, true, false]);

      await t.tap(find.text('C'));
      expect(picked, 'c');
    });
  });

  group('AppliedFiltersRow', () {
    testWidgets('shows nothing without filters', (t) async {
      await pumpWidgetApp(t, const AppliedFiltersRow(filters: []));
      expect(find.byType(InputChip), findsNothing);
    });

    testWidgets('each chip removes its own filter', (t) async {
      final removed = <String>[];
      await pumpWidgetApp(
        t,
        AppliedFiltersRow(filters: [
          AppliedFilter(label: 'Under ₹300', onRemove: () => removed.add('price')),
          AppliedFilter(label: 'Top rated', onRemove: () => removed.add('rating')),
        ]),
      );
      expect(find.text('Under ₹300'), findsOneWidget);
      await t.tap(find.descendant(of: find.widgetWithText(InputChip, 'Top rated'), matching: find.byType(Icon)));
      expect(removed, ['rating']);
    });
  });

  group('FilterButton', () {
    testWidgets('shows a dot only when a filter is active', (t) async {
      await pumpWidgetApp(t, FilterButton(onPressed: () {}));
      expect(t.widget<Badge>(find.byType(Badge)).isLabelVisible, isFalse);
      await pumpWidgetApp(t, FilterButton(onPressed: () {}, isActive: true));
      expect(t.widget<Badge>(find.byType(Badge)).isLabelVisible, isTrue);
    });

    testWidgets('taps work in both plain and bordered styles', (t) async {
      var taps = 0;
      await pumpWidgetApp(t, FilterButton(onPressed: () => taps++));
      await t.tap(find.byType(IconButton));
      await pumpWidgetApp(t, FilterButton(onPressed: () => taps++, bordered: true));
      await t.tap(find.byType(IconButton));
      expect(taps, 2);
    });
  });

  group('EmptyState and ErrorView', () {
    testWidgets('empty state shows title, message and action', (t) async {
      await pumpWidgetApp(
        t,
        EmptyState(
          icon: Icons.inbox,
          title: 'Nothing here',
          message: 'Come back later',
          action: TextButton(onPressed: () {}, child: const Text('Go')),
        ),
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Come back later'), findsOneWidget);
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('message and action are optional', (t) async {
      await pumpWidgetApp(t, const EmptyState(icon: Icons.inbox, title: 'Only title'));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Only title'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('an offline error says so and offers retry', (t) async {
      var retries = 0;
      await pumpWidgetApp(
        t,
        ErrorView(error: const AppException('No internet connection.'), onRetry: () => retries++),
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.text('No internet connection'), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
      await t.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('another error shows its own message; with no retry there is no button', (t) async {
      await pumpWidgetApp(t, const ErrorView(error: AppException('Slot full')));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Slot full'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
    });

    testWidgets('an unknown error gets the generic message', (t) async {
      await pumpWidgetApp(t, ErrorView(error: Exception('boom')));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    });
  });

  group('AsyncView', () {
    testWidgets('shows a spinner while loading, then the data', (t) async {
      await pumpWidgetApp(
        t,
        AsyncView<int>(value: const AsyncLoading(), data: (v) => Text('got $v')),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await pumpWidgetApp(t, AsyncView<int>(value: const AsyncData(7), data: (v) => Text('got $v')));
      expect(find.text('got 7'), findsOneWidget);
    });

    testWidgets('a custom loading widget replaces the spinner', (t) async {
      await pumpWidgetApp(
        t,
        AsyncView<int>(
          value: const AsyncLoading(),
          loading: const Text('shimmer'),
          data: (v) => Text('got $v'),
        ),
      );
      expect(find.text('shimmer'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('an error shows the error view with retry', (t) async {
      var retries = 0;
      await pumpWidgetApp(
        t,
        AsyncView<int>(
          value: AsyncError(const AppException('Nope'), StackTrace.empty),
          data: (v) => Text('got $v'),
          onRetry: () => retries++,
        ),
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Nope'), findsOneWidget);
      await t.tap(find.text('Try again'));
      expect(retries, 1);
    });

    testWidgets('keeps showing the data while reloading', (t) async {
      var calls = 0;
      final provider = FutureProvider<int>((ref) async {
        calls++;
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return calls;
      });
      late WidgetRef widgetRef;
      await t.pumpWidget(ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(builder: (context, ref, _) {
              widgetRef = ref;
              return AsyncView<int>(value: ref.watch(provider), data: (v) => Text('got $v'));
            }),
          ),
        ),
      ));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('got 1'), findsOneWidget);

      widgetRef.invalidate(provider);
      await t.pump(const Duration(milliseconds: 50)); // reloading
      expect(find.text('got 1'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('got 2'), findsOneWidget);
    });
  });

  group('images', () {
    testWidgets('a missing asset shows the fallback icon instead of crashing', (t) async {
      await pumpWidgetApp(t, const AppImage(source: 'assets/does-not-exist.png', width: 80, height: 80));
      await t.pump();
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });

    testWidgets('the product image rounds its corners and keeps its size', (t) async {
      await pumpWidgetApp(t, const ProductImage(asset: 'assets/nope.png', size: 64, radius: 20));
      await t.pump();
      final clip = t.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clip.borderRadius, BorderRadius.circular(20));
      expect(t.getSize(find.byType(ProductImage)), const Size(64, 64));
    });
  });
}
