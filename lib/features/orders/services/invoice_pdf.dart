import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/formatters.dart';
import '../../checkout/models/checkout_models.dart';
import '../models/order_models.dart';

/// Builds a tax invoice PDF for [order] and opens the system share / save sheet.
Future<void> shareInvoicePdf(Order order, StoreSettings seller) async {
  final bytes = await buildInvoicePdf(order, seller);
  await Printing.sharePdf(bytes: bytes, filename: 'FreshHen-Invoice-${order.id}.pdf');
}

/// Bundled Noto Sans, since the built-in PDF fonts have no ₹ sign.
Future<pw.ThemeData> _theme() async {
  Future<pw.Font> font(String weight) async =>
      pw.Font.ttf(await rootBundle.load('assets/fonts/NotoSans-$weight.ttf'));
  return pw.ThemeData.withFont(base: await font('Regular'), bold: await font('Bold'));
}

/// The money rows printed under the items, last one the total. Kept apart from
/// the layout so the amounts can be checked against the order's bill.
List<(String, String)> invoiceTotals(Order order) {
  final bill = order.bill;
  return [
    ('Item subtotal', rupees(bill.itemTotal)),
    ('Delivery fee', bill.deliveryFee == 0 ? 'FREE' : rupees(bill.deliveryFee)),
    if (bill.discount > 0)
      (bill.couponCode == null ? 'Discount' : 'Coupon (${bill.couponCode})', '-${rupees(bill.discount)}'),
    ('Taxes & packaging', rupees(bill.taxes)),
    (order.paymentStatus == PaymentStatus.paid ? 'Total paid' : 'Total amount', rupees(bill.total)),
  ];
}

Future<Uint8List> buildInvoicePdf(Order order, StoreSettings seller) async {
  const brand = PdfColor.fromInt(0xFFB93823);
  const muted = PdfColor.fromInt(0xFF6B6B70);
  const line = PdfColor.fromInt(0xFFE3E3E8);
  final rows = invoiceTotals(order);
  final invoiceNo = 'INV-${order.id}';

  pw.Widget kv(String k, String v, {bool bold = false, PdfColor? color}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2.5),
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(k, style: pw.TextStyle(color: bold ? null : muted, fontWeight: bold ? pw.FontWeight.bold : null)),
            ),
            pw.Text(v, style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : null, color: color)),
          ],
        ),
      );

  final doc = pw.Document(
    title: 'Invoice $invoiceNo',
    author: seller.legalName,
    theme: await _theme(),
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (_) => pw.DefaultTextStyle(
        style: const pw.TextStyle(fontSize: 10),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Fresh Hen',
                          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: brand)),
                      pw.SizedBox(height: 4),
                      pw.Text(seller.legalName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      if (seller.storeAddress.isNotEmpty)
                        pw.Text(seller.storeAddress, style: const pw.TextStyle(color: muted)),
                      if (seller.gstin.isNotEmpty)
                        pw.Text('GSTIN: ${seller.gstin}', style: const pw.TextStyle(color: muted)),
                      if (seller.fssaiLicense.isNotEmpty)
                        pw.Text('FSSAI Lic. No: ${seller.fssaiLicense}', style: const pw.TextStyle(color: muted)),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('TAX INVOICE', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 6),
                    pw.Text('Invoice No: $invoiceNo'),
                    pw.Text('Order ID: ${order.id}'),
                    pw.Text('Order date: ${formatFullDate(order.placedAt)}'),
                    if (order.deliveredAt != null)
                      pw.Text('Delivered: ${formatFullDate(order.deliveredAt!)}'),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 18),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: line),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BILL TO / DELIVER TO', style: const pw.TextStyle(color: muted, fontSize: 9)),
                  pw.SizedBox(height: 3),
                  pw.Text(order.addressLabel, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(order.address),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              border: null,
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF4F4F6)),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: line, width: 0.6)),
              ),
              columnWidths: {
                0: const pw.FixedColumnWidth(24),
                1: const pw.FlexColumnWidth(),
                2: const pw.FixedColumnWidth(70),
                3: const pw.FixedColumnWidth(36),
                4: const pw.FixedColumnWidth(64),
                5: const pw.FixedColumnWidth(70),
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
              headers: ['#', 'Item', 'Pack', 'Qty', 'Rate', 'Amount'],
              data: [
                for (var i = 0; i < order.lines.length; i++)
                  [
                    '${i + 1}',
                    order.lines[i].name,
                    order.lines[i].unitLabel,
                    '${order.lines[i].quantity}',
                    rupees(order.lines[i].unitPrice),
                    rupees(order.lines[i].total),
                  ],
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Row(
              children: [
                pw.Spacer(),
                pw.SizedBox(
                  width: 230,
                  child: pw.Column(
                    children: [
                      for (final (label, value) in rows.take(rows.length - 1)) kv(label, value),
                      pw.Divider(color: line),
                      kv(rows.last.$1, rows.last.$2, bold: true, color: brand),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Text('Payment: ${order.paymentMethod.label} • ${order.paymentStatus.label}'),
            if (order.paymentReference != null) pw.Text('UPI reference: ${order.paymentReference}'),
            pw.Spacer(),
            pw.Divider(color: line),
            pw.Text(
              'Fresh, unprocessed meat, poultry and eggs are exempt from GST. '
              'This is a computer-generated invoice and needs no signature.',
              style: const pw.TextStyle(color: muted, fontSize: 8.5),
            ),
            if (seller.supportPhone.isNotEmpty || seller.supportEmail.isNotEmpty)
              pw.Text(
                'Questions? ${[seller.supportPhone, seller.supportEmail].where((s) => s.isNotEmpty).join('  |  ')}',
                style: const pw.TextStyle(color: muted, fontSize: 8.5),
              ),
          ],
        ),
      ),
    ),
  );
  return doc.save();
}
