// lib/screens/history_export_page.dart
import 'dart:io';
import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:calculator_plus_history_notes/models/history_item.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_button.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_card.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_segmented_control.dart';
import 'package:calculator_plus_history_notes/widgets/reponsive_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

enum ExportFormat {
  csv,
  pdf,
}

class HistoryExportPage extends StatefulWidget {
  final List<HistoryItem> history;

  const HistoryExportPage({
    super.key,
    required this.history,
  });

  @override
  State<HistoryExportPage> createState() => _HistoryExportPageState();
}

class _HistoryExportPageState extends State<HistoryExportPage> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  bool _isExporting = false;
  String? _exportPath;
  bool _includeTimestamp = true;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');
  
  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeNotifier>(context);
    final theme = themeManager.currentTheme;
    
    return CupertinoPageScaffold(
      backgroundColor: theme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.backgroundColor.withOpacity(0.9),
        middle: Text(
          'Export History',
          style: TextStyle(color: theme.textColor),
        ),
        border: null,
      ),
      child: ResponsiveLayout(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(theme),
            SizedBox(height: 16),
            _buildOptionsCard(theme),
            SizedBox(height: 16),
            if (widget.history.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No history to export',
                    style: TextStyle(
                      color: theme.textColor.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: _buildPreviewCard(theme),
              ),
            SizedBox(height: 16),
            AdaptiveButton(
              text: 'Export',
              onPressed: widget.history.isEmpty || _isExporting ? null : _exportHistory,
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textColor: CupertinoColors.white,
              isLoading: _isExporting,
            ),
            if (_exportPath != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: AdaptiveCard(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export Complete',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          kIsWeb 
                            ? 'File has been downloaded to your device.'
                            : 'File has been saved to:',
                          style: TextStyle(
                            color: theme.textColor.withOpacity(0.8),
                          ),
                        ),
                        if (!kIsWeb)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _exportPath!,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _shareExportedFile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  CupertinoIcons.share,
                                  color: CupertinoColors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Share File',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderCard(theme) {
    return AdaptiveCard(
      backgroundColor: theme.displayColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.share,
                color: theme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Export Calculation History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Export your calculation history to CSV or PDF for record keeping or analysis.',
            style: TextStyle(
              fontSize: 14,
              color: theme.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOptionsCard(theme) {
    return AdaptiveCard(
      backgroundColor: theme.displayColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Format:',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AdaptiveSegmentedControl(
                  children: {
                    0: Text('CSV'),
                    1: Text('PDF'),
                  },
                  groupValue: _selectedFormat == ExportFormat.csv ? 0 : 1,
                  onValueChanged: (value) {
                    setState(() {
                      _selectedFormat = value == 0 ? ExportFormat.csv : ExportFormat.pdf;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Include Timestamps',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CupertinoSwitch(
                value: _includeTimestamp,
                onChanged: (value) {
                  setState(() {
                    _includeTimestamp = value;
                  });
                },
                activeColor: theme.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreviewCard(theme) {
    return AdaptiveCard(
      backgroundColor: theme.displayColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CupertinoScrollbar(
              child: ListView.builder(
                itemCount: widget.history.length,
                itemBuilder: (context, index) {
                  final item = widget.history[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            color: theme.textColor.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name ?? 'Calculation ${widget.history.length - index}',
                                style: TextStyle(
                                  color: theme.textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${item.equation} = ${_formatResult(item.result)}',
                                style: TextStyle(
                                  color: theme.textColor,
                                ),
                              ),
                              if (_includeTimestamp)
                                Text(
                                  DateFormat('MMM d, y HH:mm').format(item.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textColor.withOpacity(0.6),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatResult(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
  
  Future<void> _exportHistory() async {
    if (widget.history.isEmpty) return;
    
    setState(() {
      _isExporting = true;
      _exportPath = null;
    });
    
    try {
      switch (_selectedFormat) {
        case ExportFormat.csv:
          await _exportToCsv();
          break;
        case ExportFormat.pdf:
          await _exportToPdf();
          break;
      }
    } catch (e) {
      if (mounted) {
        _showExportError('Failed to export history: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
  
  Future<void> _exportToCsv() async {
    // Build CSV data
    List<List<dynamic>> rows = [];
    
    // Add header row
    if (_includeTimestamp) {
      rows.add(['Name', 'Equation', 'Result', 'Timestamp']);
    } else {
      rows.add(['Name', 'Equation', 'Result']);
    }
    
    // Add data rows
    for (final item in widget.history) {
      if (_includeTimestamp) {
        rows.add([
          item.name ?? '',
          item.equation,
          _formatResult(item.result),
          DateFormat('yyyy-MM-dd HH:mm:ss').format(item.timestamp),
        ]);
      } else {
        rows.add([
          item.name ?? '',
          item.equation,
          _formatResult(item.result),
        ]);
      }
    }
    
    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);
    
    // Save to file
    final directory = await _getExportDirectory();
    final timestamp = _dateFormat.format(DateTime.now());
    final fileName = 'calculator_history_$timestamp.csv';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsString(csv);
    
    setState(() {
      _exportPath = file.path;
    });
  }
  
  Future<void> _exportToPdf() async {
    // Create PDF document
    final pdf = pw.Document();
    
    // Add title page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Calculator History',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Total Calculations: ${widget.history.length}',
                  style: pw.TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    
    // Add data pages
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Calculation History',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Expanded(
                child: pw.ListView.builder(
                  itemCount: widget.history.length,
                  itemBuilder: (pw.Context context, int index) {
                    final item = widget.history[index];
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 12),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            item.name ?? 'Calculation ${widget.history.length - index}',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            '${item.equation} = ${_formatResult(item.result)}',
                          ),
                          if (_includeTimestamp)
                            pw.Text(
                              DateFormat('MMM d, y HH:mm').format(item.timestamp),
                              style: pw.TextStyle(
                                fontSize: 10,
                                color: PdfColors.grey700,
                              ),
                            ),
                          pw.Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Save PDF to file
    final directory = await _getExportDirectory();
    final timestamp = _dateFormat.format(DateTime.now());
    final fileName = 'calculator_history_$timestamp.pdf';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsBytes(await pdf.save());
    
    setState(() {
      _exportPath = file.path;
    });
  }
  
  Future<Directory> _getExportDirectory() async {
    if (kIsWeb) {
      throw UnsupportedError('File export is not supported on web.');
    }
    
    // Get app's documents directory
    final directory = await getApplicationDocumentsDirectory();
    
    // Create 'exports' subdirectory if it doesn't exist
    final exportsDir = Directory('${directory.path}/exports');
    if (!await exportsDir.exists()) {
      await exportsDir.create(recursive: true);
    }
    
    return exportsDir;
  }
  
  void _showExportError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _shareExportedFile() {
    if (_exportPath == null) return;
    
    Share.shareFiles([_exportPath!], 
      subject: 'Calculator History',
      text: 'Exported calculator history from Calculator Plus app',
    );
  }
}