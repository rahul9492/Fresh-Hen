import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_hen/app/router/routes.dart';
import 'package:fresh_hen/core/constants/app_constants.dart';
import 'package:fresh_hen/features/auth/providers/auth_provider.dart';
import 'package:fresh_hen/features/auth/screens/login_screen.dart';
import 'package:fresh_hen/features/auth/screens/otp_screen.dart';
import 'package:fresh_hen/features/auth/screens/profile_setup_screen.dart';
import 'package:fresh_hen/features/onboarding/data/onboarding_pages.dart';
import 'package:fresh_hen/features/onboarding/providers/onboarding_provider.dart';
import 'package:fresh_hen/features/onboarding/screens/onboarding_screen.dart';
import 'package:go_router/go_router.dart';

import '../../support/feature_harness.dart';
import '../../support/pump.dart';

Future<void> _settle(WidgetTester t) async {
  await t.pump();
  await t.pump(const Duration(seconds: 1));
}

/// Removes the page so its countdown timer stops before the test ends.
Harness? _last;

Future<void> _close(WidgetTester t, Harness h) async {
  await t.pumpWidget(const SizedBox());
  h.container.dispose(); // stops the resend countdown's timer
  await t.pump(const Duration(seconds: 1));
}

void main() {
  setUpWidgetTests();

  group('onboarding', () {
    testWidgets('starts on the first page with Next', (t) async {
      await pumpFeature(t, const OnboardingScreen(), signedIn: false, scaffold: false);
      expect(find.textContaining('Quality &', findRichText: true), findsOneWidget);
      expect(find.text(onboardingPages.first.subtitle), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Get Started'), findsNothing);
    });

    testWidgets('Next moves through the pages, the last says Get Started', (t) async {
      await pumpFeature(t, const OnboardingScreen(), signedIn: false, scaffold: false);
      await t.tap(find.text('Next'));
      await t.pumpAndSettle();
      expect(find.textContaining('Freshness Fast', findRichText: true), findsOneWidget);
      await t.tap(find.text('Next'));
      await t.pumpAndSettle();
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('swiping also moves between pages', (t) async {
      await pumpFeature(t, const OnboardingScreen(), signedIn: false, scaffold: false);
      await t.fling(find.byType(PageView), const Offset(-300, 0), 1500);
      await t.pumpAndSettle();
      expect(find.textContaining('Freshness Fast', findRichText: true), findsOneWidget);
    });

    testWidgets('the dots follow the page', (t) async {
      await pumpFeature(t, const OnboardingScreen(), signedIn: false, scaffold: false);
      double wide() => [
        for (var i = 0; i < onboardingPages.length; i++)
          t.getSize(find.byType(AnimatedContainer).at(i)).width,
      ].indexOf(26).toDouble(); // 18 wide + 8 of margin
      expect(wide(), 0);
      await t.tap(find.text('Next'));
      await t.pumpAndSettle();
      expect(wide(), 1);
    });

    testWidgets('Get Started marks onboarding as seen', (t) async {
      final h = await pumpFeature(t, const OnboardingScreen(), signedIn: false, scaffold: false);
      h.container.listen(onboardingSeenProvider, (_, _) {});
      expect(h.container.read(onboardingSeenProvider), isFalse);

      for (var i = 0; i < onboardingPages.length - 1; i++) {
        await t.tap(find.text('Next'));
        await t.pumpAndSettle();
      }
      await t.tap(find.text('Get Started'));
      await t.pump();
      expect(h.container.read(onboardingSeenProvider), isTrue);
    });

    testWidgets('the accent word in a title is coloured separately', (t) async {
      await pumpFeature(t, const OnboardingScreen(), signedIn: false, scaffold: false);
      expect(find.textContaining('Guaranteed', findRichText: true), findsOneWidget);
      expect(find.textContaining('{', findRichText: true), findsNothing); // braces never show
    });
  });

  group('login screen', () {
    Future<Harness> open(WidgetTester t) => pumpFeature(
      t,
      const LoginScreen(),
      signedIn: false,
      scaffold: false,
      routes: [
        GoRoute(
          path: Routes.otp,
          builder: (_, s) => Scaffold(body: Text('OTP for ${s.uri.queryParameters['phone']}')),
        ),
      ],
    );

    testWidgets('shows the welcome text and a disabled Continue', (t) async {
      await open(t);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('+91'), findsOneWidget);
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    });

    testWidgets('only ten digits are accepted', (t) async {
      await open(t);
      await t.enterText(find.byType(TextField), '98a76 54321099');
      await t.pump();
      expect(t.widget<TextField>(find.byType(TextField)).controller!.text, '9876543210');
    });

    testWidgets('Continue stays off until the number is a valid mobile number', (t) async {
      await open(t);
      await t.enterText(find.byType(TextField), '98765');
      await t.pump();
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

      await t.enterText(find.byType(TextField), '5876543210'); // cannot start with 5
      await t.pump();
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

      await t.enterText(find.byType(TextField), '9876543210');
      await t.pump();
      expect(t.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNotNull);
    });

    testWidgets('Continue sends the code and opens the OTP page for that number', (t) async {
      await open(t);
      await t.enterText(find.byType(TextField), '9876543210');
      await t.pump();
      await t.tap(find.text('Continue'));
      await _settle(t);
      await t.pumpAndSettle();
      expect(find.text('OTP for 9876543210'), findsOneWidget);
    });

    testWidgets('the keyboard Done also continues, but only with a valid number', (t) async {
      await open(t);
      await t.enterText(find.byType(TextField), '12345');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
      expect(find.textContaining('OTP for'), findsNothing);

      await t.enterText(find.byType(TextField), '9876543210');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await _settle(t);
      await t.pumpAndSettle();
      expect(find.text('OTP for 9876543210'), findsOneWidget);
    });
  });

  group('OTP screen', () {
    Future<Harness> open(
      WidgetTester t, {
      String phone = '9876543210',
      Map<String, Object>? prefs,
    }) async {
      final h = await pumpFeature(
        t,
        OtpScreen(phone: phone),
        signedIn: false,
        scaffold: false,
        prefs:
            prefs ??
            {'auth.users': '{"9876543210":{"phone":"9876543210","name":"Rahul","email":null}}'},
        routes: [stubRoute(Routes.profileSetup, label: 'PROFILE SETUP')],
      );
      // The login page sits below this one in the app and keeps its controller alive.
      h.container.listen(loginControllerProvider, (_, _) {});
      return _last = h;
    }

    testWidgets('shows the number in two groups and a countdown to resend', (t) async {
      await open(t);
      expect(find.text('Verify OTP'), findsOneWidget);
      expect(find.text('We have sent a 4 digit code to +91 98765 43210'), findsOneWidget);
      expect(
        find.textContaining('Resend in 00:${AppConstants.otpResendSeconds}', findRichText: true),
        findsOneWidget,
      );
      await _close(t, _last!);
    });

    testWidgets('the countdown ticks down and then offers Resend OTP', (t) async {
      await open(t);
      await t.pump(const Duration(seconds: 3));
      expect(find.textContaining('Resend in 00:27', findRichText: true), findsOneWidget);
      await t.pump(const Duration(seconds: AppConstants.otpResendSeconds));
      expect(find.text('Resend OTP'), findsOneWidget);
      await _close(t, _last!);
    });

    testWidgets('Resend restarts the countdown and tells the customer', (t) async {
      await open(t);
      await t.pump(const Duration(seconds: AppConstants.otpResendSeconds + 1));
      await t.tap(find.text('Resend OTP'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(find.text('OTP sent to +91 98765 43210'), findsOneWidget);
      expect(find.textContaining('Resend in', findRichText: true), findsOneWidget);
      await _close(t, _last!);
    });

    testWidgets('Verify stays off until all four digits are in', (t) async {
      await open(t);
      expect(
        t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Verify & Proceed')).onPressed,
        isNull,
      );
      await t.enterText(find.byType(TextField), '12');
      await t.pump();
      expect(
        t.widget<FilledButton>(find.widgetWithText(FilledButton, 'Verify & Proceed')).onPressed,
        isNull,
      );
      await _close(t, _last!);
    });

    testWidgets('the right code signs a known customer in', (t) async {
      final h = await open(t);
      await t.enterText(find.byType(TextField), AppConstants.mockOtp);
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(h.container.read(authSessionProvider)?.phone, '9876543210');
      await _close(t, _last!);
    });

    testWidgets('the right code for a new number opens profile setup', (t) async {
      await open(t, phone: '9000000001', prefs: const {});
      await t.enterText(find.byType(TextField), AppConstants.mockOtp);
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(find.text('PROFILE SETUP'), findsOneWidget);
      await _close(t, _last!);
    });

    testWidgets('a wrong code shows an error and does not sign in', (t) async {
      final h = await open(t);
      await t.enterText(find.byType(TextField), '0000');
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(find.text('Incorrect OTP. Please try again.'), findsOneWidget);
      expect(h.container.read(authSessionProvider), isNull);
      await _close(t, _last!);
    });

    testWidgets('the debug hint shows the test code in mock mode', (t) async {
      await open(t);
      expect(find.text('Debug: use OTP ${AppConstants.mockOtp}'), findsOneWidget);
      await _close(t, _last!);
    });

    testWidgets('the back button returns to the previous page', (t) async {
      await pumpFeature(
        t,
        Builder(
          builder: (c) => TextButton(onPressed: () => c.push('/otp-page'), child: const Text('go')),
        ),
        signedIn: false,
        routes: [
          GoRoute(
            path: '/otp-page',
            builder: (_, _) => const OtpScreen(phone: '9876543210'),
          ),
        ],
      );
      await t.tap(find.text('go'));
      await t.pumpAndSettle();
      expect(find.text('Verify OTP'), findsOneWidget);
      await t.tap(find.byIcon(Icons.chevron_left_rounded));
      await t.pumpAndSettle();
      expect(find.text('go'), findsOneWidget);
    });
  });

  group('profile setup', () {
    Future<Harness> open(WidgetTester t) => pumpFeature(
      t,
      const ProfileSetupScreen(phone: '9000000001'),
      signedIn: false,
      scaffold: false,
    );

    testWidgets('asks for a name and an optional email', (t) async {
      await open(t);
      expect(find.text('Create Your Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email (Optional)'), findsOneWidget);
    });

    testWidgets('a name is needed before continuing', (t) async {
      final h = await open(t);
      await t.tap(find.text('Complete Setup & Explore'));
      await t.pump();
      expect(find.text('Please enter your name'), findsOneWidget);
      expect(h.container.read(authSessionProvider), isNull);
    });

    testWidgets('a valid profile registers the customer and signs them in', (t) async {
      final h = await open(t);
      await t.enterText(find.byType(TextFormField).first, 'Asha Devi');
      await t.enterText(find.byType(TextFormField).last, 'asha@x.com');
      await t.tap(find.text('Complete Setup & Explore'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));

      final user = h.container.read(authSessionProvider);
      expect(user?.name, 'Asha Devi');
      expect(user?.phone, '9000000001');
      expect(user?.email, 'asha@x.com');
    });

    testWidgets('the email can be left out', (t) async {
      final h = await open(t);
      await t.enterText(find.byType(TextFormField).first, 'Asha Devi');
      await t.tap(find.text('Complete Setup & Explore'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(h.container.read(authSessionProvider)?.email, isNull);
    });

    testWidgets('a badly formed email is refused', (t) async {
      final h = await open(t);
      await t.enterText(find.byType(TextFormField).first, 'Asha Devi');
      await t.enterText(find.byType(TextFormField).last, 'nope');
      await t.tap(find.text('Complete Setup & Explore'));
      await t.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(h.container.read(authSessionProvider), isNull);
    });
  });
}
