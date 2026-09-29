import '../../../core/constants/app_constants.dart';

class OnboardingPage {
  const OnboardingPage({required this.title, required this.subtitle, required this.image});

  /// Text inside {braces} is shown in the accent colour.
  final String title;
  final String subtitle;
  final String image;
}

const onboardingPages = [
  OnboardingPage(
    title: 'Quality &\nHygiene {Guaranteed}',
    subtitle: 'Farm fresh chicken, processed today.',
    image: Assets.splash1,
  ),
  OnboardingPage(
    title: 'Freshness Fast &\n{Reliable} Delivery',
    subtitle: 'Get your chicken at your doorstep.',
    image: Assets.splash2,
  ),
  OnboardingPage(
    title: 'Freshness\nYou can {Trust}',
    subtitle: 'Farm fresh chicken, processed today.',
    image: Assets.splash3,
  ),
];
