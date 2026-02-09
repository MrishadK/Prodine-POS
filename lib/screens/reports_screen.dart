import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/history_provider.dart';
import '../models/order.dart';

// Providers for date filtering
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final reportViewTypeProvider =
    StateProvider<ReportViewType>((ref) => ReportViewType.daily);

enum ReportViewType { daily, weekly, monthly, yearly }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _isDateRange = false;
  ReportViewType _currentView = ReportViewType.daily;

  // ✅ STATE FOR CHART INTERACTION
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  // ... [Date Picking Logic - Kept Same] ...
  Future<void> _pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C5F7C),
              onPrimary: Colors.white,
              surface: Color(0xFFF5F7FA),
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _isDateRange = true;
      });
    }
  }

  Future<void> _pickSingleDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2C5F7C),
              onPrimary: Colors.white,
              surface: Color(0xFFF5F7FA),
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _endDate = picked.add(const Duration(days: 1));
        _isDateRange = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // EXPORT FUNCTIONS (PDF/EXCEL)
  // ---------------------------------------------------------------------------
  Future<void> _exportPdf(List<Order> filtered, Map<String, double> revenue,
      List<String> sorted) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildPdfHeader(),
          pw.SizedBox(height: 20),
          _buildPdfSummary(filtered),
          pw.SizedBox(height: 20),
          _buildPdfTopItems(sorted, revenue),
          pw.SizedBox(height: 20),
          _buildPdfTimeRange(),
          pw.SizedBox(height: 20),
          pw.Text(
              'Report generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
              style: pw.TextStyle(
                  fontSize: 10, color: const PdfColor.fromInt(0xFF666666))),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  Future<void> _exportExcel(List<Order> filtered, Map<String, double> revenue,
      List<String> sorted) async {
    final csvContent = _generateCsvContent(filtered, revenue, sorted);
    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/sales_report_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csvContent);

    await Share.shareXFiles([XFile(file.path)],
        text:
            'Sales Report ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
  }

  String _generateCsvContent(
      List<Order> filtered, Map<String, double> revenue, List<String> sorted) {
    final buffer = StringBuffer();
    buffer.writeln('Sales Report');
    buffer.writeln(
        'Date Range: ${DateFormat('yyyy-MM-dd').format(_startDate)} to ${DateFormat('yyyy-MM-dd').format(_endDate)}');
    buffer.writeln();
    buffer.writeln('SUMMARY');
    buffer.writeln(
        'Total Revenue,${filtered.fold<double>(0, (sum, order) => sum + order.total)}');
    buffer.writeln('Total Orders,${filtered.length}');
    buffer.writeln(
        'Average Bill,${filtered.isEmpty ? 0 : filtered.fold<double>(0, (sum, order) => sum + order.total) / filtered.length}');
    buffer.writeln();
    buffer.writeln('TOP SELLING ITEMS');
    buffer.writeln('Item Name,Revenue,Quantity');
    for (final item in sorted.take(10)) {
      buffer.writeln(
          '$item,${revenue[item]?.toStringAsFixed(2)},${_getItemQuantity(filtered, item)}');
    }
    buffer.writeln();
    buffer.writeln('ORDER DETAILS');
    buffer.writeln('Order ID,Date,Time,Total Items,Total Amount');
    for (final order in filtered) {
      buffer.writeln(
          '${order.id},${DateFormat('yyyy-MM-dd').format(order.dateTime)},${DateFormat('HH:mm').format(order.dateTime)},${order.items.length},${order.total}');
    }
    return buffer.toString();
  }

  int _getItemQuantity(List<Order> orders, String itemName) {
    return orders.fold<int>(0, (sum, order) {
      return sum +
          order.items.fold<int>(0, (itemSum, item) {
            return itemSum +
                (item.menuItem.name == itemName ? item.quantity.toInt() : 0);
          });
    });
  }

  // ---------------------------------------------------------------------------
  // PDF WIDGET HELPERS
  // ---------------------------------------------------------------------------
  pw.Widget _buildPdfHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('SALES ANALYTICS REPORT',
                style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: const PdfColor.fromInt(0xFF2C5F7C))),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border:
                    pw.Border.all(color: const PdfColor.fromInt(0xFF2C5F7C)),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text('CONFIDENTIAL',
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF2C5F7C))),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: const PdfColor.fromInt(0xFF2C5F7C)),
      ],
    );
  }

  pw.Widget _buildPdfSummary(List<Order> filtered) {
    final totalRevenue =
        filtered.fold<double>(0, (sum, order) => sum + order.total);
    final avgBill = filtered.isEmpty ? 0 : totalRevenue / filtered.length;
    final peakHour = _calculatePeakHour(filtered);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('SUMMARY',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _buildPdfStatCard(
                'Total Revenue', '${totalRevenue.toStringAsFixed(2)} SAR'),
            pw.SizedBox(width: 10),
            _buildPdfStatCard('Total Orders', '${filtered.length}'),
            pw.SizedBox(width: 10),
            _buildPdfStatCard('Avg Bill', '${avgBill.toStringAsFixed(2)} SAR'),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            _buildPdfStatCard('Peak Hour', peakHour),
            pw.SizedBox(width: 10),
            _buildPdfStatCard('Top Category', _getTopCategory(filtered)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfStatCard(String title, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: const PdfColor.fromInt(0xFFE0E0E0)),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title,
                style: const pw.TextStyle(
                    fontSize: 12, color: PdfColor.fromInt(0xFF666666))),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildPdfTopItems(
      List<String> sorted, Map<String, double> revenue) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('TOP SELLING ITEMS',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        pw.Table(
          border: pw.TableBorder.all(color: const PdfColor.fromInt(0xFFE0E0E0)),
          columnWidths: {
            0: const pw.FlexColumnWidth(4),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration:
                  const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF5F7FA)),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Item Name',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Revenue',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('Share %',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            for (final item in sorted.take(10))
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(item),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text('${revenue[item]?.toStringAsFixed(2)} SAR'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(_calculatePercentage(revenue[item]!,
                            revenue.values.reduce((a, b) => a + b))
                        .toStringAsFixed(1)),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfTimeRange() {
    return pw.Row(
      children: [
        pw.Icon(pw.IconData(0xe192),
            size: 12, color: const PdfColor.fromInt(0xFF666666)),
        pw.SizedBox(width: 8),
        pw.Text(
          '${DateFormat('yyyy-MM-dd').format(_startDate)} to ${DateFormat('yyyy-MM-dd').format(_endDate)}',
          style: const pw.TextStyle(
              fontSize: 12, color: PdfColor.fromInt(0xFF666666)),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DATA CALCULATION HELPERS
  // ---------------------------------------------------------------------------
  double _calculatePercentage(double value, double total) {
    return total > 0 ? (value / total) * 100 : 0;
  }

  String _calculatePeakHour(List<Order> orders) {
    if (orders.isEmpty) return 'N/A';
    final hourCounts = <int, int>{};
    for (final order in orders) {
      final hour = order.dateTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    if (hourCounts.isEmpty) return 'N/A';
    final peakHour =
        hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return '$peakHour:00';
  }

  String _getTopCategory(List<Order> orders) {
    if (orders.isEmpty) return 'N/A';
    final categoryCounts = <String, int>{};
    for (final order in orders) {
      for (final item in order.items) {
        final category = item.menuItem.category;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }
    }
    if (categoryCounts.isEmpty) return 'N/A';
    return categoryCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  List<Order> _filterOrders(List<Order> allOrders) {
    return allOrders.where((order) {
      return order.dateTime.isAfter(_startDate) &&
          order.dateTime.isBefore(_endDate);
    }).toList();
  }

  Map<String, dynamic> _calculateReportData(List<Order> filtered) {
    double totalRevenue = 0;
    final Map<String, int> popularity = {};
    final Map<String, double> revenue = {};

    for (final order in filtered) {
      totalRevenue += order.total;
      for (final item in order.items) {
        popularity[item.menuItem.name] =
            (popularity[item.menuItem.name] ?? 0) + item.quantity.toInt();
        revenue[item.menuItem.name] =
            (revenue[item.menuItem.name] ?? 0) + item.subtotal;
      }
    }

    final sortedItems = popularity.keys.toList()
      ..sort((a, b) => popularity[b]!.compareTo(popularity[a]!));

    final avgBill = filtered.isEmpty ? 0 : totalRevenue / filtered.length;
    final peakHour = _calculatePeakHour(filtered);

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': filtered.length,
      'avgBill': avgBill,
      'peakHour': peakHour,
      'popularity': popularity,
      'revenue': revenue,
      'sortedItems': sortedItems,
    };
  }

  List<Map<String, dynamic>> _getDailyRevenueData(List<Order> orders) {
    final Map<DateTime, double> dailyRevenue = {};
    for (final order in orders) {
      final dateOnly = DateTime(
          order.dateTime.year, order.dateTime.month, order.dateTime.day);
      dailyRevenue[dateOnly] = (dailyRevenue[dateOnly] ?? 0) + order.total;
    }
    final sortedKeys = dailyRevenue.keys.toList()..sort();
    return sortedKeys.map((date) {
      return {
        'label': DateFormat('MMM dd').format(date),
        'revenue': dailyRevenue[date],
      };
    }).toList();
  }

  List<Map<String, dynamic>> _getHourlyData(List<Order> orders) {
    final hourlyCounts = List<int>.filled(24, 0);
    for (final order in orders) {
      final hour = order.dateTime.hour;
      hourlyCounts[hour]++;
    }
    final maxCount =
        hourlyCounts.isEmpty ? 0 : hourlyCounts.reduce((a, b) => a > b ? a : b);
    return List.generate(24, (index) {
      final hour = index;
      final count = hourlyCounts[hour];
      return {
        'hour': hour,
        'count': count.toDouble(),
        'label': '$hour',
        'isPeak': count == maxCount && maxCount > 0,
      };
    }).toList();
  }

  Color _getChartColor(int index) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
    ];
    return colors[index % colors.length];
  }

  // ---------------------------------------------------------------------------
  // MAIN UI BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final filteredOrders = _filterOrders(history);
    final data = _calculateReportData(filteredOrders);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Reports & Analytics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2C5F7C),
        centerTitle: true,
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'pdf') {
                _exportPdf(
                    filteredOrders,
                    data['revenue'] as Map<String, double>,
                    data['sortedItems'] as List<String>);
              } else if (value == 'excel') {
                _exportExcel(
                    filteredOrders,
                    data['revenue'] as Map<String, double>,
                    data['sortedItems'] as List<String>);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Export as Excel'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildViewTypeSelector(),
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildSummaryCards(data),
                        const SizedBox(height: 16),
                        _buildTopItemsSection(data),
                        const SizedBox(height: 16),
                        _buildHourlyAnalysis(filteredOrders),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickSingleDate(context),
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2C5F7C),
                side: const BorderSide(color: Color(0xFF2C5F7C)),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _pickDateRange(context),
              icon: const Icon(Icons.date_range, size: 16),
              label: Text(_isDateRange
                  ? '${DateFormat('MMM dd').format(_startDate)} - ${DateFormat('MMM dd').format(_endDate)}'
                  : 'Select Range'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2C5F7C),
                side: const BorderSide(color: Color(0xFF2C5F7C)),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewTypeSelector() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ReportViewType.values.map((type) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_getViewTypeLabel(type)),
                  selected: _currentView == type,
                  onSelected: (selected) {
                    setState(() {
                      _currentView = type;
                      _updateDateRangeByView();
                    });
                  },
                  selectedColor: const Color(0xFF2C5F7C),
                  labelStyle: TextStyle(
                    color: _currentView == type ? Colors.white : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _getViewTypeLabel(ReportViewType type) {
    switch (type) {
      case ReportViewType.daily:
        return 'Daily';
      case ReportViewType.weekly:
        return 'Weekly';
      case ReportViewType.monthly:
        return 'Monthly';
      case ReportViewType.yearly:
        return 'Yearly';
    }
  }

  void _updateDateRangeByView() {
    final now = DateTime.now();
    switch (_currentView) {
      case ReportViewType.daily:
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = _startDate.add(const Duration(days: 1));
        break;
      case ReportViewType.weekly:
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case ReportViewType.monthly:
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case ReportViewType.yearly:
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31);
        break;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No sales data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a different date range',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    final totalRevenue = data['totalRevenue'] as double;
    final totalOrders = data['totalOrders'] as int;
    final avgBill = data['avgBill'] as double;
    final peakHour = data['peakHour'] as String;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  'Total Revenue',
                  '$totalRevenue SAR',
                  Icons.attach_money,
                  const Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactStatCard(
                  'Total Orders',
                  totalOrders.toString(),
                  Icons.receipt,
                  const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  'Avg. Order Value',
                  '$avgBill SAR',
                  Icons.shopping_cart,
                  const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCompactStatCard(
                  'Peak Hour',
                  peakHour,
                  Icons.access_time,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            radius: 20,
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C5F7C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ✅ MODIFIED: Layout with Row (Chart Left, Table Right)
  // ---------------------------------------------------------------------------
  Widget _buildTopItemsSection(Map<String, dynamic> data) {
    final sortedItems = data['sortedItems'] as List<String>;
    final popularity = data['popularity'] as Map<String, int>;
    final revenue = data['revenue'] as Map<String, double>;
    final totalRevenue = data['totalRevenue'] as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Selling Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C5F7C),
              ),
            ),
            Text(
              'Showing top ${sortedItems.take(5).length}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          // ✅ HERE IS THE ROW LAYOUT
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Chart (Left Side) - Flex 1
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 250, // Fixed height to match table area
                  child: Column(
                    children: [
                      const Text("Distribution",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _buildItemsPieChart(sortedItems, revenue),
                      ),
                    ],
                  ),
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 250,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

              // 2. Table (Right Side) - Flex 2
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 250,
                  child: _buildTopItemsTable(
                      sortedItems, popularity, revenue, totalRevenue),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopItemsTable(
      List<String> sortedItems,
      Map<String, int> popularity,
      Map<String, double> revenue,
      double totalRevenue) {
    // Wrap in SingleChildScrollView for vertical scrolling if list is long
    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 0, // Tight layout
        headingRowHeight: 40,
        dataRowHeight: 45,
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('Qty'), numeric: true),
          DataColumn(label: Text('Revenue'), numeric: true),
          DataColumn(label: Text('Share'), numeric: true),
        ],
        rows: sortedItems.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final itemRevenue = revenue[item] ?? 0;
          final share =
              totalRevenue > 0 ? (itemRevenue / totalRevenue * 100) : 0;

          return DataRow(cells: [
            DataCell(Text('${index + 1}')),
            DataCell(
              SizedBox(
                width: 140, // Fixed width for name
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
            DataCell(Text('${popularity[item]}')),
            DataCell(Text('${itemRevenue.toStringAsFixed(1)} SAR')),
            DataCell(Text('${share.toStringAsFixed(1)}%')),
          ]);
        }).toList(),
      ),
    );
  }

  // ✅ INTERACTIVE PIE CHART
  Widget _buildItemsPieChart(
      List<String> sortedItems, Map<String, double> revenue) {
    final topItems = sortedItems.take(5).toList();
    final topItemsRevenue =
        topItems.fold<double>(0, (sum, item) => sum + (revenue[item] ?? 0));
    final otherRevenue =
        revenue.values.fold<double>(0, (sum, value) => sum + value) -
            topItemsRevenue;

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: [
          ...topItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemRevenue = revenue[item] ?? 0;
            final isTouched = index == _touchedIndex;
            final fontSize = isTouched ? 14.0 : 10.0;
            final radius = isTouched ? 60.0 : 50.0;

            return PieChartSectionData(
              value: itemRevenue,
              color: _getChartColor(index),
              title:
                  '${(itemRevenue / (topItemsRevenue + otherRevenue) * 100).toStringAsFixed(1)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
          if (otherRevenue > 0)
            PieChartSectionData(
              value: otherRevenue,
              color: Colors.grey[300]!,
              title: 'Other',
              radius: 50, // Keep 'Other' static for now
              titleStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHourlyAnalysis(List<Order> orders) {
    final hourlyData = _getHourlyData(orders);
    double maxYValue = 10;
    if (hourlyData.isNotEmpty) {
      final maxCount = hourlyData
          .map<double>((d) => d['count'] as double)
          .reduce((a, b) => a > b ? a : b);
      maxYValue = maxCount == 0 ? 10 : maxCount * 1.2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hourly Analysis',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C5F7C),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxYValue,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} orders\n${hourlyData[groupIndex]['label']}:00',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 4,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < hourlyData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${hourlyData[index]['label']}:00',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: maxYValue > 5 ? maxYValue / 5 : 1,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 != 0) return const SizedBox.shrink();
                      return Text(
                        value.toInt().toString(),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: hourlyData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data['count'] as double,
                      width: 8,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                      color: data['isPeak']
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF2C5F7C),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxYValue,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
