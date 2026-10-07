import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/core/network/api_call.dart';
import 'package:fresh_hen/core/network/endpoints.dart';
import 'package:fresh_hen/features/account/data/info_content.dart';
import 'package:fresh_hen/features/catalog/data/mock_catalog_data.dart';
import 'package:fresh_hen/features/checkout/data/mock_checkout_data.dart';
import 'package:fresh_hen/features/onboarding/data/onboarding_pages.dart';
import 'package:fresh_hen/features/orders/data/mock_order_data.dart';
import 'package:fresh_hen/features/orders/models/order_models.dart';

DioException _error(
  DioExceptionType type, {
  int? status,
  Object? data,
}) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    type: type,
    response: status == null ? null : Response(requestOptions: req, statusCode: status, data: data),
  );
}

void main() {
  group('API error messages', () {
    test('timeouts and lost connections have their own wording', () {
      for (final t in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
      ]) {
        expect(mapDioError(_error(t)).message, 'The request timed out. Please try again.');
      }
      expect(mapDioError(_error(DioExceptionType.connectionError)).message, 'No internet connection.');
      expect(mapDioError(_error(DioExceptionType.cancel)).message, 'Request cancelled.');
    });

    test('the server own message wins, from message or error', () {
      expect(
        mapDioError(_error(DioExceptionType.badResponse, status: 422, data: {'message': 'Slot full'}))
            .message,
        'Slot full',
      );
      expect(
        mapDioError(_error(DioExceptionType.badResponse, status: 400, data: {'error': 'Bad pin'}))
            .message,
        'Bad pin',
      );
      expect(
        mapDioError(_error(DioExceptionType.badResponse, status: 422, data: {'message': 'Slot full'}))
            .statusCode,
        422,
      );
    });

    test('a blank or non-text server message is ignored', () {
      expect(
        mapDioError(_error(DioExceptionType.badResponse, status: 404, data: {'message': '  '})).message,
        'We could not find what you were looking for.',
      );
      expect(
        mapDioError(_error(DioExceptionType.badResponse, status: 400, data: {'message': 5})).message,
        'Something went wrong. Please try again.',
      );
      expect(
        mapDioError(_error(DioExceptionType.badResponse, status: 400, data: 'html page')).message,
        'Something went wrong. Please try again.',
      );
    });

    test('plain status codes get friendly wording', () {
      String of(int s) => mapDioError(_error(DioExceptionType.badResponse, status: s)).message;
      expect(of(401), 'Your session has expired. Please log in again.');
      expect(of(404), 'We could not find what you were looking for.');
      expect(of(500), 'Server error. Please try again later.');
      expect(of(503), 'Server error. Please try again later.');
      expect(of(418), 'Something went wrong. Please try again.');
      expect(mapDioError(_error(DioExceptionType.unknown)).message,
          'Something went wrong. Please try again.');
    });

    test('apiCall converts Dio errors and lets other errors through', () async {
      await expectLater(
        apiCall<int>(() async => throw _error(DioExceptionType.connectionError)),
        throwsA(predicate((e) => e.toString() == 'No internet connection.')),
      );
      await expectLater(apiCall<int>(() async => throw StateError('bug')), throwsStateError);
      expect(await apiCall(() async => 7), 7);
    });
  });

  group('endpoints', () {
    test('ids are encoded into paths', () {
      expect(Endpoints.orderRating('FH 1/2'), '/orders/FH%201%2F2/rating');
      expect(Endpoints.orderCancel('A'), '/orders/A/cancel');
      expect(Endpoints.address('a b'), '/addresses/a%20b');
      expect(Endpoints.addressDefault('1'), '/addresses/1/default');
      expect(Endpoints.wishlistItem('p/1'), '/wishlist/p%2F1');
    });

    test('sign-in calls never trigger the session-expired flow', () {
      expect(Endpoints.public, containsAll([Endpoints.sendOtp, Endpoints.verifyOtp, Endpoints.refresh]));
      expect(Endpoints.public, isNot(contains(Endpoints.orders)));
    });
  });

  group('mock catalog', () {
    test('every product belongs to a category and has something to buy', () {
      final categories = mockCategories.map((c) => c.id).toSet();
      expect(mockProducts, isNotEmpty);
      for (final p in mockProducts) {
        expect(categories, contains(p.categoryId), reason: p.id);
        expect(p.variants, isNotEmpty, reason: p.id);
        expect(p.image, isNotEmpty, reason: p.id);
        expect(p.variants.map((v) => v.id).toSet().length, p.variants.length,
            reason: '${p.id} has duplicate pack ids');
        for (final v in p.variants) {
          expect(v.price, greaterThan(0), reason: '${p.id}/${v.id}');
          if (v.mrp != null) expect(v.mrp, greaterThanOrEqualTo(v.price), reason: '${p.id}/${v.id}');
        }
      }
    });

    test('product ids are unique', () {
      expect(mockProducts.map((p) => p.id).toSet().length, mockProducts.length);
    });

    test('every category has products, and banners point at real categories', () {
      for (final c in mockCategories) {
        expect(mockProducts.where((p) => p.categoryId == c.id), isNotEmpty, reason: c.id);
      }
      final ids = mockCategories.map((c) => c.id).toSet();
      for (final b in mockBanners) {
        expect(ids, contains(b.categoryId), reason: b.title);
      }
    });

    test('there are popular and recommended picks for Home', () {
      expect(mockProducts.where((p) => p.isPopular), isNotEmpty);
      expect(mockProducts.where((p) => p.isRecommended), isNotEmpty);
    });
  });

  group('mock checkout', () {
    final now = DateTime(2026, 10, 7, 12); // a Wednesday

    test('coupon codes are unique and each can actually give a discount', () {
      final coupons = mockCoupons(now);
      expect(coupons.map((c) => c.code).toSet().length, coupons.length);
      for (final c in coupons) {
        expect(c.discountFor(5000), greaterThan(0), reason: c.code);
      }
    });

    test('the store serves a few pincodes and is open for UPI', () {
      expect(mockStoreSettings.deliveryPincodes, isNotEmpty);
      expect(mockStoreSettings.upiEnabled, isTrue);
    });

    test('delivery days: the weekly off is closed, and slots start after the lead time', () {
      final days = mockDeliveryDays(now, days: 7);
      expect(days.length, 7);
      final tuesday = days.firstWhere((d) => d.date.weekday == DateTime.tuesday);
      expect(tuesday.isOpen, isFalse);
      expect(tuesday.closedReason, 'Weekly off');

      for (final d in days.where((d) => d.closedReason == null)) {
        for (final s in d.slots) {
          expect(s.end.isAfter(s.start), isTrue);
          if (s.available) {
            expect(s.start.isAfter(now.add(const Duration(minutes: 90))), isTrue, reason: s.id);
          }
        }
      }
      // Slot ids are unique across the whole picker.
      final ids = [for (final d in days) ...d.slots.map((s) => s.id)];
      expect(ids.toSet().length, ids.length);
    });

    test('early slots today are unavailable when it is already late', () {
      final lateNow = DateTime(2026, 10, 7, 11, 30);
      final today = mockDeliveryDays(lateNow).first;
      final seven = today.slots.firstWhere((s) => s.start.hour == 7);
      expect(seven.available, isFalse);
      final evening = today.slots.firstWhere((s) => s.start.hour == 18);
      expect(evening.available, isTrue);
    });
  });

  group('mock orders', () {
    final orders = mockOrders(DateTime(2026, 10, 7, 12));

    test('ids are unique and there is at least one active and one delivered order', () {
      expect(orders.map((o) => o.id).toSet().length, orders.length);
      expect(orders.any((o) => o.status.isActive), isTrue);
      expect(orders.any((o) => o.status == OrderStatus.delivered), isTrue);
    });

    test('newest first, never placed in the future', () {
      final now = DateTime(2026, 10, 7, 12);
      for (var i = 1; i < orders.length; i++) {
        expect(orders[i - 1].placedAt.isBefore(orders[i].placedAt), isFalse);
      }
      for (final o in orders) {
        expect(o.placedAt.isAfter(now), isFalse, reason: o.id);
      }
    });

    test('every bill adds up to its lines', () {
      for (final o in orders) {
        expect(o.bill.itemTotal, o.lines.fold<int>(0, (s, l) => s + l.total), reason: o.id);
        expect(o.total, greaterThan(0), reason: o.id);
      }
    });

    test('delivered orders say when, and cancelled ones say why', () {
      for (final o in orders) {
        if (o.status == OrderStatus.delivered) expect(o.deliveredAt, isNotNull, reason: o.id);
        if (o.status == OrderStatus.cancelled) expect(o.cancelReason, isNotNull, reason: o.id);
      }
    });
  });

  group('static content', () {
    test('onboarding has pages with text and a picture', () {
      expect(onboardingPages, isNotEmpty);
      for (final p in onboardingPages) {
        expect(p.title, isNotEmpty);
        expect(p.subtitle, isNotEmpty);
        expect(p.image, isNotEmpty);
      }
    });

    test('terms and privacy sections are filled in', () {
      for (final s in [...termsSections, ...termsTabSections, ...privacyTabSections]) {
        expect(s.heading.trim(), isNotEmpty);
        expect(s.body.trim(), isNotEmpty);
      }
    });

    test('the fallback legal page is a real https address', () {
      expect(Uri.parse(legalPageUrl).scheme, 'https');
    });
  });
}
