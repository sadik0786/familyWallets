import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/finance_models.dart';
import 'package:intl/intl.dart';

class PDFService {
  Future<void> generateFamilyReportPDF({
    required String familyName,
    required double totalContributions,
    required double totalExpenses,
    required double balance,
    required List<ContributionModel> contributions,
    required List<ExpenseModel> expenses,
    required String monthYear,
  }) async {
    final pdf = pw.Document();

    final currencyFormatter = NumberFormat('Rs. #,##0.00', 'en_IN');
    final dateFormatter = DateFormat('yyyy-MM-dd');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // HEADER BAR
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF5F67EC), // Brand Purple/Blue
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'FAMILY WALLET REPORT',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Workspace: $familyName',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        monthYear.toUpperCase(),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated on ${dateFormatter.format(DateTime.now())}',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // OVERVIEW METRICS
            pw.Text(
              'Financial Summary',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF1E293B),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildMetricCard('Total Contributions', currencyFormatter.format(totalContributions), PdfColors.green),
                _buildMetricCard('Total Expenses', currencyFormatter.format(totalExpenses), PdfColors.red),
                _buildMetricCard('Net Balance', currencyFormatter.format(balance), PdfColors.blue),
              ],
            ),
            pw.SizedBox(height: 24),

            // CONTRIBUTIONS SECTION
            pw.Text(
              'Contributions Log',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF1E293B),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.symmetric(inside: const pw.BorderSide(width: 0.5, color: PdfColors.grey300)),
              headerAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF3B82F6)),
              headers: ['Date', 'Contributor', 'Note', 'Amount'],
              data: contributions.map((c) => [
                dateFormatter.format(c.date),
                c.contributorName,
                c.note ?? '-',
                currencyFormatter.format(c.amount),
              ]).toList(),
            ),
            pw.SizedBox(height: 24),

            // EXPENSES SECTION
            pw.Text(
              'Expenses Log',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF1E293B),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.symmetric(inside: const pw.BorderSide(width: 0.5, color: PdfColors.grey300)),
              headerAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEF4444)),
              headers: ['Date', 'Category', 'Description', 'Added By', 'Amount'],
              data: expenses.map((e) => [
                dateFormatter.format(e.date),
                e.category,
                e.description ?? '-',
                e.addedByName,
                currencyFormatter.format(e.amount),
              ]).toList(),
            ),
          ];
        },
      ),
    );

    // Render print view/share sheet
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${familyName.replaceAll(' ', '_')}_Report_$monthYear.pdf',
    );
  }

  pw.Widget _buildMetricCard(String title, String value, PdfColor valueColor) {
    return pw.Container(
      width: 140,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 1),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
