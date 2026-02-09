import 'dart:io';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/restaurant_settings.dart';

enum PrintLayout { standard80mm }

class ThermalPrinterService {
  // --- RECEIPT PRINTING ---
  static Future<void> printOrder(
      Order order, PrintLayout layout, RestaurantSettings settings,
      {String? orderMode}) async {
    final pdf = await _generateReceiptPDF(order, settings, orderMode);
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<pw.Document> _generateReceiptPDF(
      Order order, RestaurantSettings settings, String? orderMode) async {
    final pdf = pw.Document();
    pw.ImageProvider? logo;
    if (settings.logoPath != null && File(settings.logoPath!).existsSync()) {
      logo = pw.MemoryImage(File(settings.logoPath!).readAsBytesSync());
    }

    const fontStyle = pw.TextStyle(fontSize: 10);
    final boldStyle =
        pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final titleStyle =
        pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);
    final modeStyle =
        pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);

    // Use Invoice Number for QR if available
    final qrData = order.invoiceNumber;

    // ✅ FIXED LOGIC:
    // 1. Start with the saved mode from the Order object.
    // 2. If 'orderMode' param is passed AND not empty, use that instead.
    String modeToDisplay = order.orderMode;
    if (orderMode != null && orderMode.trim().isNotEmpty) {
      modeToDisplay = orderMode;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        margin: const pw.EdgeInsets.all(5),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null)
              pw.Container(height: 60, width: 60, child: pw.Image(logo)),
            pw.SizedBox(height: 5),
            pw.Text(settings.name,
                style: titleStyle, textAlign: pw.TextAlign.center),
            pw.Text('VAT NO: ${settings.vatNumber}', style: fontStyle),
            pw.Text(settings.phone, style: fontStyle),
            pw.SizedBox(height: 10),
            pw.Text('Tax Invoice', style: titleStyle),
            pw.SizedBox(height: 5),

            // ✅ DISPLAY THE MODE (Dine-in / Takeaway)
            if (modeToDisplay.isNotEmpty)
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(),
                    borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Text('TYPE: ${modeToDisplay.toUpperCase()}',
                    style: modeStyle),
              ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 0.5),

            // ✅ SHOW INVOICE AND TICKET
            _buildInfoRow('Invoice #', order.invoiceNumber),
            _buildInfoRow('Ticket #', order.ticketNumber),
            _buildInfoRow(
                'Date', DateFormat('dd/MM/yyyy HH:mm').format(order.dateTime)),
            _buildInfoRow('Cashier', order.cashier),
            pw.Divider(thickness: 0.5),

            pw.Row(children: [
              pw.Expanded(flex: 4, child: pw.Text('Item', style: boldStyle)),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('Price',
                      style: boldStyle, textAlign: pw.TextAlign.center)),
              pw.Expanded(
                  flex: 1,
                  child: pw.Text('Qty',
                      style: boldStyle, textAlign: pw.TextAlign.center)),
              pw.Expanded(
                  flex: 2,
                  child: pw.Text('Total',
                      style: boldStyle, textAlign: pw.TextAlign.right)),
            ]),
            pw.SizedBox(height: 5),
            pw.Container(
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                            style: pw.BorderStyle.dashed, width: 0.5)))),

            ...order.items.map((item) {
              return pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                            item.nameOverride.isNotEmpty
                                ? item.nameOverride
                                : item.menuItem.name,
                            style: fontStyle)),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(item.priceOverride.toStringAsFixed(2),
                            style: fontStyle, textAlign: pw.TextAlign.center)),
                    pw.Expanded(
                        flex: 1,
                        child: pw.Text(item.quantityLabel,
                            style: fontStyle, textAlign: pw.TextAlign.center)),
                    pw.Expanded(
                        flex: 2,
                        child: pw.Text(item.subtotal.toStringAsFixed(2),
                            style: boldStyle, textAlign: pw.TextAlign.right)),
                  ],
                ),
              );
            }).toList(),

            pw.Divider(thickness: 0.5),
            _buildTotalRow(
                'Total Taxable', (order.subtotal).toStringAsFixed(2)),
            _buildTotalRow('Total VAT', order.vat.toStringAsFixed(2)),
            pw.Divider(),
            pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total Due', style: titleStyle),
                  pw.Text('${order.total.toStringAsFixed(2)} SAR',
                      style: titleStyle),
                ]),
            pw.SizedBox(height: 20),
            pw.Container(
                height: 80,
                width: 80,
                child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(), data: qrData)),
            pw.SizedBox(height: 10),
            pw.Text('Thank you', style: fontStyle),
          ],
        ),
      ),
    );
    return pdf;
  }

  // --- REPORT PRINTING ---
  static Future<void> printReport(
      List<Order> orders, String title, RestaurantSettings settings) async {
    final pdf = pw.Document();

    double totalRevenue = orders.fold(0, (sum, o) => sum + o.total);
    int totalOrders = orders.length;
    double avgOrder = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, double.infinity),
        margin: const pw.EdgeInsets.all(5),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
                child: pw.Text(settings.name,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 14))),
            pw.Center(
                child: pw.Text(title,
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12))),
            pw.SizedBox(height: 10),
            pw.Divider(),
            _buildTotalRow(
                'Total Revenue', '${totalRevenue.toStringAsFixed(2)} SAR'),
            _buildTotalRow('Total Orders', '$totalOrders'),
            _buildTotalRow('Avg Ticket', '${avgOrder.toStringAsFixed(2)} SAR'),
            pw.Divider(),
            pw.Text("Orders Summary:",
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.SizedBox(height: 5),
            ...orders.map((o) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                          '#${o.ticketNumber} (${DateFormat('HH:mm').format(o.dateTime)})',
                          style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(o.total.toStringAsFixed(2),
                          style: const pw.TextStyle(fontSize: 9)),
                    ])),
            pw.SizedBox(height: 20),
            pw.Center(
                child: pw.Text(
                    "Printed: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}",
                    style: const pw.TextStyle(
                        fontSize: 8, color: PdfColors.grey))),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(value,
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ]),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            pw.Text(value,
                style:
                    pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          ]),
    );
  }
}
