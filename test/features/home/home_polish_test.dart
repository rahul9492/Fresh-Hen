import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/features/catalog/models/catalog_models.dart';
import 'package:fresh_hen/features/home/widgets/home_header.dart';
import 'package:fresh_hen/features/home/widgets/promo_carousel.dart';

PromoBanner _banner(String title) => PromoBanner(
      eyebrow: 'NEW',
      title: title,
      highlight: 'Fresh',
      description: 'Description',
      image: 'assets/images/none.png',
      categoryId: 'c',
    );

void main() {
  testWidgets('the search bar stays pinned while the page scrolls', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 120, child: Text('top block'))),
              const SliverPersistentHeader(pinned: true, delegate: HomeSearchPinnedDelegate()),
              SliverList(
                delegate: SliverChildListDelegate([
                  for (var i = 0; i < 40; i++) SizedBox(height: 80, child: Text('item $i')),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Search...'), findsOneWidget);

    await t.drag(find.byType(CustomScrollView), const Offset(0, -1500));
    await t.pump();

    expect(find.text('top block'), findsNothing); // scrolled away
    expect(find.text('Search...'), findsOneWidget); // still there
    expect(t.getTopLeft(find.text('Search...')).dy, lessThan(100));
  });

  testWidgets('the banners auto-scroll, but pause while a finger is on them', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PromoCarousel(banners: [_banner('One'), _banner('Two'), _banner('Three')]),
        ),
      ),
    );
    expect(find.text('One'), findsOneWidget);

    // Finger down: nothing moves, however long it stays there.
    final gesture = await t.startGesture(t.getCenter(find.byType(PageView)));
    await t.pump(const Duration(seconds: 9));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.text('One'), findsOneWidget);

    // Finger up: the auto-scroll starts again and moves to the next banner.
    await gesture.up();
    await t.pump(const Duration(seconds: 4));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('Two'), findsOneWidget);

    // Leave the widget tree so the repeating timer is cancelled.
    await t.pumpWidget(const SizedBox());
  });
}
