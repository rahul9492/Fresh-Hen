class InfoSection {
  const InfoSection(this.heading, this.body);

  final String heading;
  final String body;
}

const helpSections = [
  InfoSection(
    'Where is my order?',
    'Open the Orders tab to see the live status of every order you have placed.',
  ),
  InfoSection(
    'Received a wrong or damaged item?',
    'Contact us within 2 hours of delivery with a photo and we will refund or replace it.',
  ),
  InfoSection(
    'Delivery timings',
    'We deliver daily from 6 AM to 10 PM. Orders above ₹499 get free delivery.',
  ),
  InfoSection(
    'Contact us',
    'Call 1800-000-0000 or write to support@freshhen.in. We reply within a few hours.',
  ),
];

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
