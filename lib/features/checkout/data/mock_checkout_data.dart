import '../../../core/constants/app_constants.dart';
import '../../orders/models/order_models.dart';
import '../models/checkout_models.dart';

/// Mirrors the admin "Schedule for later" switch while there is no backend.
/// Try both states with `--dart-define=MOCK_SCHEDULE=false`.
const _mockScheduleEnabled = bool.fromEnvironment('MOCK_SCHEDULE', defaultValue: true);

const mockStoreSettings = StoreSettings(
  scheduleEnabled: _mockScheduleEnabled,
  etaMinMinutes: 45,
  etaMaxMinutes: 90,
  upiQrImage: Assets.mockUpiQr,
  // The admin app supplies the real QR and UPI ID; these mirror the store's details.
  upiId: 'freshhen@upi',
  upiPayeeName: 'Fresh Hen Foods',
  // Noida sectors around the shop.
  deliveryPincodes: ['201301', '201303', '201304', '201307', '201309', '201310'],
  deliveryFee: 40,
  freeDeliveryAbove: 499,
  legalName: 'Fresh Hen Foods Pvt. Ltd.',
  gstin: '09AAACF1234A1Z5',
  fssaiLicense: '12724999000123',
  storeAddress: 'Plot 14, Sector 63, Noida, Uttar Pradesh - 201301',
  supportPhone: '+91 97117 39492',
  supportEmail: 'support@freshhen.in',
);

List<Coupon> mockCoupons(DateTime now) => [
      Coupon(
        code: 'FRESH20',
        title: '20% OFF up to ₹100',
        description: 'On all fresh chicken, mutton and fish orders.',
        percentOff: 20,
        maxDiscount: 100,
        minOrder: 499,
        expiresAt: now.add(const Duration(days: 12)),
      ),
      const Coupon(
        code: 'CHICKEN50',
        title: 'Flat ₹50 OFF',
        description: 'Save on your weekly chicken order.',
        flatOff: 50,
        minOrder: 299,
      ),
      const Coupon(
        code: 'HEN100',
        title: 'Flat ₹100 OFF',
        description: 'Stock up for the week and save more.',
        flatOff: 100,
        minOrder: 999,
      ),
      const Coupon(
        code: 'WELCOME15',
        title: '15% OFF up to ₹75',
        description: 'A welcome treat on your first Fresh Hen order.',
        percentOff: 15,
        maxDiscount: 75,
        minOrder: 199,
        firstOrderOnly: true,
      ),
    ];

/// Hourly windows the store delivers in, as (start hour, end hour).
const _slotHours = [(7, 8), (8, 9), (9, 10), (10, 11), (11, 12), (12, 13), (16, 17), (17, 18), (18, 19), (19, 20)];

/// A slot must start at least this long from now so the order can be cut and packed.
const _slotLeadTime = Duration(minutes: 90);

/// The next [days] days from [now]. Tuesday is the store's weekly off, and a
/// couple of popular windows are already full, so the picker shows every state.
List<DeliveryDay> mockDeliveryDays(DateTime now, {int days = 4}) {
  final today = DateTime(now.year, now.month, now.day);
  return [
    for (var i = 0; i < days; i++)
      () {
        final date = today.add(Duration(days: i));
        if (date.weekday == DateTime.tuesday) {
          return DeliveryDay(date: date, slots: const [], closedReason: 'Weekly off');
        }
        return DeliveryDay(
          date: date,
          slots: [
            for (final (from, to) in _slotHours)
              () {
                final start = date.add(Duration(hours: from));
                final full = (i == 1 && (from == 9 || from == 18)) || (i == 2 && from == 10);
                return DeliverySlot(
                  id: '${date.year}${_two(date.month)}${_two(date.day)}-${_two(from)}00',
                  start: start,
                  end: date.add(Duration(hours: to)),
                  available: !full && start.isAfter(now.add(_slotLeadTime)),
                );
              }(),
          ],
        );
      }(),
  ];
}

String _two(int v) => v.toString().padLeft(2, '0');
