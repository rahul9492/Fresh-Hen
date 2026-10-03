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
