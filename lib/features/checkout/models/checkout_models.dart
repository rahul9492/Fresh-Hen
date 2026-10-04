import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/utils/formatters.dart';
import '../../orders/models/order_models.dart';

part 'checkout_models.freezed.dart';
part 'checkout_models.g.dart';

/// Store-wide checkout rules. Everything here is controlled from the admin app.
@freezed
abstract class StoreSettings with _$StoreSettings {
  const StoreSettings._();

  const factory StoreSettings({
    /// Admin switch: when off the cart offers "Order now" only.
    @Default(false) bool scheduleEnabled,

    /// "Order now" promise, depending on rider availability.
    @Default(45) int etaMinMinutes,
    @Default(90) int etaMaxMinutes,
    @Default(true) bool cashOnDeliveryEnabled,

    /// UPI QR the admin uploaded: a URL (or a bundled asset in mock mode).
    /// UPI is offered only while one is set.
    String? upiQrImage,
    String? upiId,
    @Default('Fresh Hen') String upiPayeeName,

    @Default(40) int deliveryFee,
    @Default(499) int freeDeliveryAbove,
    @Default(0) int packagingFee,

    /// GST on fresh, unprocessed meat and eggs is nil, so this is usually 0.
    @Default(0) int taxPercent,

    // Seller details printed on the tax invoice.
    @Default('Fresh Hen Foods Pvt. Ltd.') String legalName,
    @Default('') String gstin,
    @Default('') String fssaiLicense,
    @Default('') String storeAddress,
    /// Help & Support call and WhatsApp number, e.g. `9711739492`.
    @Default('') String supportPhone,
    @Default('') String supportEmail,

    /// Public pages set in the admin app. Empty falls back to the text built
    /// into the app.
    @Default('') String termsUrl,
    @Default('') String privacyUrl,

    /// Pincodes the shop delivers to, set in the admin app. Empty means no
    /// limit (every pincode is accepted).
    @Default(<String>[]) List<String> deliveryPincodes,
  }) = _StoreSettings;

  factory StoreSettings.fromJson(Map<String, dynamic> json) => _$StoreSettingsFromJson(json);

  bool get upiEnabled => (upiQrImage ?? '').isNotEmpty;

  bool deliversTo(String pincode) =>
      deliveryPincodes.isEmpty || deliveryPincodes.contains(pincode.trim());

  String get etaLabel => formatEta(etaMinMinutes, etaMaxMinutes);

  int deliveryFeeFor(int itemTotal) =>
      itemTotal == 0 || itemTotal >= freeDeliveryAbove ? 0 : deliveryFee;

  int taxesFor(int itemTotal) =>
      itemTotal == 0 ? 0 : packagingFee + (itemTotal * taxPercent / 100).round();
}

@freezed
abstract class Coupon with _$Coupon {
  const Coupon._();

  const factory Coupon({
    required String code,

    /// Short headline, e.g. "20% OFF up to ₹100".
    required String title,
    required String description,
    @Default(0) int percentOff,
    @Default(0) int flatOff,

    /// Cap for percentage coupons; 0 means no cap.
    @Default(0) int maxDiscount,
    @Default(0) int minOrder,
    @Default(false) bool firstOrderOnly,
    DateTime? expiresAt,
  }) = _Coupon;

  factory Coupon.fromJson(Map<String, dynamic> json) => _$CouponFromJson(json);

  /// Discount on [itemTotal], never more than the items cost.
  int discountFor(int itemTotal) {
    var off = flatOff + (itemTotal * percentOff / 100).floor();
    if (maxDiscount > 0 && off > maxDiscount) off = maxDiscount;
    return off.clamp(0, itemTotal);
  }

  /// Why the coupon can't be used right now, or null when it can.
  String? issueFor({required int itemTotal, required bool isFirstOrder, DateTime? now}) {
    if (expiresAt != null && (now ?? DateTime.now()).isAfter(expiresAt!)) {
      return 'This coupon has expired';
    }
    if (firstOrderOnly && !isFirstOrder) return 'Valid on your first order only';
    if (itemTotal < minOrder) return 'Add ${rupees(minOrder - itemTotal)} more to use this coupon';
    return null;
  }
}

/// One selectable day in the slot picker.
@freezed
abstract class DeliveryDay with _$DeliveryDay {
  const DeliveryDay._();

  const factory DeliveryDay({
    required DateTime date,
    required List<DeliverySlot> slots,

    /// Set when the store is closed that day (holiday, weekly off).
    String? closedReason,
  }) = _DeliveryDay;

  factory DeliveryDay.fromJson(Map<String, dynamic> json) => _$DeliveryDayFromJson(json);

  bool get isOpen => closedReason == null && slots.any((s) => s.available);
}

enum DeliveryMode { now, scheduled }

/// What the customer has chosen in the cart so far.
@freezed
abstract class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    @Default('') String instructions,
    Coupon? coupon,
    @Default(DeliveryMode.now) DeliveryMode mode,
    DeliverySlot? slot,

    /// True once the customer tapped "Continue" and picked how to receive the order.
    @Default(false) bool timingConfirmed,
  }) = _CheckoutState;
}

/// Where the cart's main button takes the customer next.
enum CheckoutStep { address, timing, payment }
