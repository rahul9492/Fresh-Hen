import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/core/push/push_route.dart';

void main() {
  test('order and payment pushes open the order', () {
    expect(pushRoute({'type': 'order', 'orderId': 'FH123'}), Routes.orderFor('FH123'));
    expect(pushRoute({'type': 'payment', 'orderId': 'FH123'}), Routes.orderFor('FH123'));
  });

  test('offer pushes open a product or a category', () {
    expect(pushRoute({'type': 'offer', 'productId': 'p1'}), Routes.productFor('p1'));
    expect(
      pushRoute({'type': 'offer', 'categoryId': 'chicken', 'title': 'Chicken deals'}),
      Routes.productsFor(title: 'Chicken deals', category: 'chicken'),
    );
  });

  test('unknown types or missing ids fall back to Home', () {
    expect(pushRoute({}), Routes.home);
    expect(pushRoute({'type': 'something-new', 'orderId': 'FH123'}), Routes.home);
    expect(pushRoute({'type': 'order'}), Routes.home);
    expect(pushRoute({'type': 'offer', 'productId': ''}), Routes.home);
  });

  test('offers get their own channel so they can be muted', () {
    expect(PushChannel.forData({'type': 'offer'}), PushChannel.offers);
    expect(PushChannel.forData({'type': 'order'}), PushChannel.orderUpdates);
    expect(PushChannel.forData({}), PushChannel.orderUpdates);
  });
}
