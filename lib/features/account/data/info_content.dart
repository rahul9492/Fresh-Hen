class InfoSection {
  const InfoSection(this.heading, this.body);

  final String heading;
  final String body;
}

const termsSections = [
  InfoSection(
    'Terms of Service',
    'By using Fresh Hen you agree to provide accurate details and to use the app only for lawful purposes.',
  ),
  InfoSection(
    'Orders and refunds',
    'Prices and availability can change. Perishable items are refunded or replaced when they are not fresh on delivery.',
  ),
  InfoSection(
    'Privacy Policy',
    'We collect your name, phone number, email and delivery address only to serve your orders. We never sell your data.',
  ),
];

/// Where the full Terms of Service and Privacy Policy live. Both tabs of the
/// Terms & Privacy screen point here for now.
const legalPageUrl = 'https://mymunc.com/';

const termsTabSections = [
  InfoSection(
    'Acceptance of Terms',
    'By using Fresh Hen you agree to these Terms of Service and to provide accurate details. If you do not agree, please do not use the app.',
  ),
  InfoSection(
    'Orders and delivery',
    'Prices and availability can change. Delivery times are estimates and depend on your area and the shop\'s workload.',
  ),
  InfoSection(
    'Payments',
    'You can pay by cash on delivery or UPI where available. Orders paid by UPI are confirmed once the payment is verified.',
  ),
  InfoSection(
    'Refunds and replacements',
    'Perishable items are refunded or replaced when they are not fresh on delivery. Please report the issue as soon as you receive the order.',
  ),
  InfoSection(
    'Acceptable use',
    'Use the app only for lawful purposes. We may suspend accounts that misuse the app, offers or coupons.',
  ),
];

const privacyTabSections = [
  InfoSection(
    'What we collect',
    'We collect your name, phone number, email and delivery addresses, along with your orders and payment screenshots you upload.',
  ),
  InfoSection(
    'How we use it',
    'Your details are used only to take, deliver and support your orders, and to send order updates. We never sell your data.',
  ),
  InfoSection(
    'Sharing',
    'We share your name, phone number and address with delivery staff only as needed to deliver your order.',
  ),
  InfoSection(
    'Your choices',
    'You can edit your profile and addresses in the app, and delete your account from the Profile screen at any time.',
  ),
];
