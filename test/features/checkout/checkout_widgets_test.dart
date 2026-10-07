import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/checkout/models/checkout_models.dart';
import 'package:fresh_hen/features/checkout/widgets/after_paying_card.dart';
import 'package:fresh_hen/features/checkout/widgets/bill_summary.dart';
import 'package:fresh_hen/features/checkout/widgets/delivery_slot_sheet.dart';
import 'package:fresh_hen/features/checkout/widgets/payment_method_sheet.dart';
import 'package:fresh_hen/features/checkout/widgets/payment_reference_card.dart';
import 'package:fresh_hen/features/checkout/widgets/payment_unavailable.dart';
import 'package:fresh_hen/features/checkout/widgets/upi_qr_card.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';

import '../../support/feature_harness.dart';
import '../../support/pump.dart';

void main() {
  setUpWidgetTests();

  group('BillSummary', () {
    Future<void> show(WidgetTester t, OrderBill bill, {String title = 'Bill Summary', String totalLabel = 'To Pay', bool highlight = true, Widget? footer}) =>
        pumpWidgetApp(
          t,
          SingleChildScrollView(
            child: BillSummary(bill: bill, title: title, totalLabel: totalLabel, highlightTotal: highlight, footer: footer),
          ),
        );

    testWidgets('lists the subtotal, delivery, taxes and total', (t) async {
      await show(t, const OrderBill(itemTotal: 400, mrpTotal: 400, deliveryFee: 40, taxes: 10));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Bill Summary'), findsOneWidget);
      expect(find.text('Item Subtotal'), findsOneWidget);
      expect(find.text('₹400'), findsOneWidget);
      expect(find.text('Delivery Fee'), findsOneWidget);
      expect(find.text('₹40'), findsOneWidget);
      expect(find.text('Taxes & Packaging'), findsOneWidget);
      expect(find.text('To Pay'), findsOneWidget);
      expect(find.text('₹450'), findsOneWidget);
    });

    testWidgets('free delivery says FREE, and no discount row without a discount', (t) async {
      await show(t, const OrderBill(itemTotal: 600, mrpTotal: 600, deliveryFee: 0));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('FREE'), findsOneWidget);
      expect(find.textContaining('Coupon'), findsNothing);
      expect(find.text('Discount'), findsNothing);
    });

    testWidgets('a coupon discount shows its code and is taken off the total', (t) async {
      await show(t, const OrderBill(itemTotal: 500, mrpTotal: 500, deliveryFee: 40, discount: 50, couponCode: 'SAVE50'));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Coupon (SAVE50)'), findsOneWidget);
      expect(find.text('−₹50'), findsOneWidget);
      expect(find.text('₹490'), findsOneWidget);
    });

    testWidgets('a discount without a code is just called Discount', (t) async {
      await show(t, const OrderBill(itemTotal: 500, mrpTotal: 500, deliveryFee: 0, discount: 25));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Discount'), findsOneWidget);
    });

    testWidgets('savings show only when the customer saved something', (t) async {
      await show(t, const OrderBill(itemTotal: 400, mrpTotal: 500, deliveryFee: 0));
      await t.pump(const Duration(seconds: 1));
      expect(find.textContaining('You save', findRichText: true), findsOneWidget);
      expect(find.textContaining('₹100', findRichText: true), findsOneWidget);

      await show(t, const OrderBill(itemTotal: 400, mrpTotal: 400, deliveryFee: 0));
      await t.pump(const Duration(seconds: 1));
      expect(find.textContaining('You save', findRichText: true), findsNothing);
    });

    testWidgets('the title, total label and footer can be changed', (t) async {
      await show(
        t,
        const OrderBill(itemTotal: 100, mrpTotal: 100, deliveryFee: 0),
        title: 'Payment details',
        totalLabel: 'Total paid',
        footer: const Text('thanks'),
      );
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Payment details'), findsOneWidget);
      expect(find.text('Total paid'), findsOneWidget);
      expect(find.text('thanks'), findsOneWidget);
    });

    testWidgets('the total is red for a bill to pay and plain once paid', (t) async {
      await show(t, const OrderBill(itemTotal: 100, mrpTotal: 100, deliveryFee: 0));
      await t.pump(const Duration(seconds: 1));
      final due = t.widget<Text>(find.text('₹100').last).style?.color;

      await show(t, const OrderBill(itemTotal: 100, mrpTotal: 100, deliveryFee: 0), highlight: false);
      await t.pump(const Duration(seconds: 1));
      final paid = t.widget<Text>(find.text('₹100').last).style?.color;
      expect(due, isNot(paid));
    });

    testWidgets('the total counts to a new amount when the bill changes', (t) async {
      await show(t, const OrderBill(itemTotal: 100, mrpTotal: 100, deliveryFee: 0));
      await t.pump(const Duration(seconds: 1));
      await show(t, const OrderBill(itemTotal: 300, mrpTotal: 300, deliveryFee: 0));
      await t.pump(const Duration(seconds: 1));
      expect(find.text('₹300'), findsWidgets);
    });
  });

  group('payment method sheet', () {
    Future<void> open(WidgetTester t, StoreSettings settings, {int amount = 450, void Function(PaymentMethod?)? onResult}) async {
      await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(
            onPressed: () async {
              final m = await showPaymentMethodSheet(c, amount: amount, settings: settings);
              onResult?.call(m);
            },
            child: const Text('open'),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('UPI is chosen first when the store accepts it, with the amount', (t) async {
      await open(t, mockStoreSettings);
      expect(find.text('Choose payment method'), findsOneWidget);
      expect(find.textContaining('Amount to pay', findRichText: true), findsOneWidget);
      expect(find.text('Continue to Pay ₹450'), findsOneWidget);
      expect(find.text('Pay Online via UPI'), findsOneWidget);
      expect(find.text('Cash on Delivery'), findsOneWidget);
      for (final b in ['GPay', 'PhonePe', 'Paytm', 'BHIM']) {
        expect(find.text(b), findsOneWidget);
      }
    });

    testWidgets('choosing cash changes the button, and it returns the method', (t) async {
      PaymentMethod? result;
      await open(t, mockStoreSettings, onResult: (m) => result = m);
      await t.tap(find.text('Cash on Delivery'));
      await t.pump();
      expect(find.text('Place Order • ₹450'), findsOneWidget);

      await t.tap(find.text('Place Order • ₹450'));
      await t.pumpAndSettle();
      expect(result, PaymentMethod.cash);
    });

    testWidgets('continuing with UPI returns UPI', (t) async {
      PaymentMethod? result;
      await open(t, mockStoreSettings, onResult: (m) => result = m);
      await t.tap(find.text('Continue to Pay ₹450'));
      await t.pumpAndSettle();
      expect(result, PaymentMethod.upi);
    });

    testWidgets('without a UPI QR, cash is the only option and is chosen already', (t) async {
      await open(t, mockStoreSettings.copyWith(upiQrImage: null));
      expect(find.text('Currently unavailable'), findsOneWidget);
      expect(find.text('Place Order • ₹450'), findsOneWidget);
      expect(find.text('GPay'), findsNothing);
    });

    testWidgets('an unavailable UPI option cannot be tapped', (t) async {
      await open(t, mockStoreSettings.copyWith(upiQrImage: null));
      await t.tap(find.text('Pay Online via UPI'));
      await t.pump();
      expect(find.text('Place Order • ₹450'), findsOneWidget); // still cash
    });

    testWidgets('with cash off, UPI stays chosen and cash is unavailable', (t) async {
      await open(t, mockStoreSettings.copyWith(cashOnDeliveryEnabled: false));
      expect(find.text('Continue to Pay ₹450'), findsOneWidget);
      await t.tap(find.text('Cash on Delivery'));
      await t.pump();
      expect(find.text('Continue to Pay ₹450'), findsOneWidget);
    });

    testWidgets('with both off the button says payments are unavailable and does nothing', (t) async {
      PaymentMethod? result;
      await open(
        t,
        mockStoreSettings.copyWith(upiQrImage: null, cashOnDeliveryEnabled: false),
        onResult: (m) => result = m,
      );
      expect(find.text('Payments unavailable'), findsOneWidget);
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
      expect(result, isNull);
    });

    testWidgets('dismissing returns nothing', (t) async {
      PaymentMethod? result = PaymentMethod.cash;
      await open(t, mockStoreSettings, onResult: (m) => result = m);
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();
      expect(result, isNull);
    });
  });

  group('payment cards', () {
    testWidgets('after-paying steps include the exact amount', (t) async {
      await pumpWidgetApp(t, const SingleChildScrollView(child: AfterPayingCard(amount: 450)));
      expect(find.text('How to pay'), findsOneWidget);
      expect(find.textContaining('pay exactly ₹450'), findsOneWidget);
      expect(find.textContaining('screenshot'), findsWidgets);
      expect(find.textContaining('Upload it using the button below'), findsOneWidget);
    });

    testWidgets('the reference field takes up to 12 digits only', (t) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pumpWidgetApp(t, SingleChildScrollView(child: PaymentReferenceCard(controller: controller)));
      expect(find.textContaining('UPI Transaction ID', findRichText: true), findsOneWidget);
      expect(find.text('Helps us confirm your payment faster'), findsOneWidget);

      await t.enterText(find.byType(TextField), '12ab34cd56 78901234567');
      expect(controller.text, '123456789012');
    });

    testWidgets('the unavailable page explains and goes back', (t) async {
      await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(
            onPressed: () => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => const Scaffold(body: PaymentUnavailable()))),
            child: const Text('go'),
          ),
        ),
        scaffold: false,
      );
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      expect(find.text('UPI payments are unavailable right now'), findsOneWidget);
      expect(find.text('Please go back and choose Cash on Delivery.'), findsOneWidget);
    });
  });

  group('UPI QR card', () {
    /// Shows the card as if on [platform], and always puts the real one back.
    Future<void> showOn(WidgetTester t, TargetPlatform platform, StoreSettings settings) async {
      debugDefaultTargetPlatformOverride = platform;
      try {
        await pumpFeature(t, SingleChildScrollView(child: UpiQrCard(settings: settings, amount: 450)));
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    }

    testWidgets('shows the QR, the amount and the actions', (t) async {
      await pumpFeature(t, SingleChildScrollView(child: UpiQrCard(settings: mockStoreSettings, amount: 450)));
      expect(find.text('Scan & Pay via Any UPI App'), findsOneWidget);
      expect(find.text('Use Google Pay, PhonePe, Paytm or BHIM'), findsOneWidget);
      expect(find.textContaining('Pay exactly', findRichText: true), findsOneWidget);
      expect(find.text('Save QR'), findsOneWidget);
      expect(find.text('Share QR'), findsOneWidget);
      expect(find.textContaining('freshhen@upi', findRichText: true), findsWidgets);
    });

    testWidgets('the UPI app button appears on Android only', (t) async {
      await showOn(t, TargetPlatform.android, mockStoreSettings);
      expect(find.text('Pay ₹450 with UPI app'), findsOneWidget);
      expect(find.text('or scan the QR'), findsOneWidget);
    });

    testWidgets('no UPI app button on iOS', (t) async {
      await showOn(t, TargetPlatform.iOS, mockStoreSettings);
      expect(find.textContaining('with UPI app'), findsNothing);
    });

    testWidgets('without a UPI ID there is no app button even on Android', (t) async {
      await showOn(t, TargetPlatform.android, mockStoreSettings.copyWith(upiId: null));
      expect(find.textContaining('with UPI app'), findsNothing);
    });
  });

  group('delivery slot sheet', () {
    Future<void> open(WidgetTester t, {DeliverySlot? current, void Function(DeliverySlot?)? onResult, List<DeliveryDay>? days}) async {
      await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(
            onPressed: () async {
              final s = await showDeliverySlotSheet(c, current: current);
              onResult?.call(s);
            },
            child: const Text('open'),
          ),
        ),
        days: days,
      );
      await t.tap(find.text('open'));
      // The sleeping hen loops forever, so settle by time instead of pumpAndSettle.
      await t.pump();
      await t.pump(const Duration(seconds: 1));
    }

    testWidgets('shows the days and time slots, with Confirm disabled until one is picked', (t) async {
      await open(t);
      expect(find.text('Select delivery slot'), findsOneWidget);
      expect(find.text('Choose Time Slot'), findsOneWidget);
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });

    testWidgets('picking a slot and confirming returns it', (t) async {
      DeliverySlot? result;
      final days = [
        DeliveryDay(date: DateTime.now().add(const Duration(days: 1)), slots: [
          DeliverySlot(id: 'a', start: DateTime.now().add(const Duration(days: 1, hours: 2)), end: DateTime.now().add(const Duration(days: 1, hours: 3))),
          DeliverySlot(id: 'b', start: DateTime.now().add(const Duration(days: 1, hours: 4)), end: DateTime.now().add(const Duration(days: 1, hours: 5))),
        ]),
      ];
      await open(t, days: days, onResult: (s) => result = s);
      final slotTexts = find.byType(InkWell);
      expect(slotTexts, findsWidgets);

      // Tap the first time slot in the grid.
      await t.tap(find.descendant(of: find.byType(GridView), matching: find.byType(InkWell)).first);
      await t.pump();
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);

      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.id, 'a');
    });

    testWidgets('when every day is closed it says so instead of showing slots', (t) async {
      final days = [
        DeliveryDay(date: DateTime.now().add(const Duration(days: 1)), slots: const [], closedReason: 'Weekly off'),
      ];
      await open(t, days: days);
      await t.pump(const Duration(seconds: 1));
      expect(find.textContaining('No delivery slots are open right now'), findsOneWidget);
      expect(find.text('Choose Time Slot'), findsNothing);
    });

    testWidgets('a closed or fully booked day cannot be chosen, so the open day stays shown', (t) async {
      final slot = DeliverySlot(id: 'a', start: DateTime.now().add(const Duration(days: 1, hours: 2)), end: DateTime.now().add(const Duration(days: 1, hours: 3)));
      final taken = DeliverySlot(id: 'x', start: DateTime.now().add(const Duration(days: 3, hours: 2)), end: DateTime.now().add(const Duration(days: 3, hours: 3)), available: false);
      final days = [
        DeliveryDay(date: DateTime.now().add(const Duration(days: 1)), slots: [slot]),
        DeliveryDay(date: DateTime.now().add(const Duration(days: 2)), slots: const [], closedReason: 'Weekly off'),
        DeliveryDay(date: DateTime.now().add(const Duration(days: 3)), slots: [taken]),
      ];
      await open(t, days: days);
      final chips = find.descendant(of: find.byType(ListView).first, matching: find.byType(InkWell));
      expect(t.widget<InkWell>(chips.at(0)).onTap, isNotNull);
      expect(t.widget<InkWell>(chips.at(1)).onTap, isNull);
      expect(t.widget<InkWell>(chips.at(2)).onTap, isNull);

      await t.tap(chips.at(1), warnIfMissed: false);
      await t.pump(const Duration(seconds: 1));
      expect(find.byType(GridView), findsOneWidget); // still the open day's slots
      expect(find.textContaining('We are closed on this day'), findsNothing);
    });

    testWidgets('a slot picked earlier is shown again when the sheet reopens', (t) async {
      final slot = DeliverySlot(id: 'a', start: DateTime.now().add(const Duration(days: 1, hours: 2)), end: DateTime.now().add(const Duration(days: 1, hours: 3)));
      final other = DeliverySlot(id: 'b', start: DateTime.now().add(const Duration(days: 1, hours: 5)), end: DateTime.now().add(const Duration(days: 1, hours: 6)));
      DeliverySlot? result;
      await open(
        t,
        current: slot,
        days: [DeliveryDay(date: DateTime.now().add(const Duration(days: 1)), slots: [slot, other])],
        onResult: (s) => result = s,
      );
      // Confirm is already available: the current slot is still free.
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
      await t.tap(find.text('Confirm'));
      await t.pumpAndSettle();
      expect(result?.id, 'a');
    });

    testWidgets('if the picked slot gets taken meanwhile, Confirm is switched off', (t) async {
      final gone = DeliverySlot(id: 'a', start: DateTime.now().add(const Duration(days: 1, hours: 2)), end: DateTime.now().add(const Duration(days: 1, hours: 3)), available: false);
      final other = DeliverySlot(id: 'b', start: DateTime.now().add(const Duration(days: 1, hours: 5)), end: DateTime.now().add(const Duration(days: 1, hours: 6)));
      await open(
        t,
        current: gone,
        days: [DeliveryDay(date: DateTime.now().add(const Duration(days: 1)), slots: [gone, other])],
      );
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });
  });
}
