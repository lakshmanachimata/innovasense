import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PDFViewerPopup extends StatefulWidget {
  final String pdfPath;
  final String title;

  const PDFViewerPopup({
    super.key,
    required this.pdfPath,
    required this.title,
  });

  @override
  State<PDFViewerPopup> createState() => _PDFViewerPopupState();
}

class _PDFViewerPopupState extends State<PDFViewerPopup> {
  bool _isLoading = true;
  String? _error;
  String? _localPdfPath;
  PDFViewController? _pdfViewController;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Download PDF from network
      final response = await http.get(Uri.parse('https://api.innovosens.com/Hydrosense.pdf'));
      
      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/Hydrosense.pdf');
        
        // Write PDF to temporary file
        await tempFile.writeAsBytes(response.bodyBytes);
        
        setState(() {
          _localPdfPath = tempFile.path;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to download PDF: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with title and close button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // PDF content area
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: _buildPdfContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Loading PDF...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Please wait while we load the Hydrosense research document',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPdf,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_localPdfPath != null) {
      return Column(
        children: [
          // Page navigation bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _currentPage > 1
                          ? () => _pdfViewController?.setPage(_currentPage - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      tooltip: 'Previous Page',
                    ),
                    IconButton(
                      onPressed: _currentPage < _totalPages
                          ? () => _pdfViewController?.setPage(_currentPage + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      tooltip: 'Next Page',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // PDF viewer
          Expanded(
            child: PDFView(
              filePath: _localPdfPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
                             onRender: (pages) {
                 setState(() {
                   _totalPages = pages ?? 0;
                 });
               },
               onViewCreated: (PDFViewController controller) {
                 _pdfViewController = controller;
               },
               onPageChanged: (page, total) {
                 setState(() {
                   _currentPage = (page ?? 0) + 1;
                 });
               },
              onError: (error) {
                setState(() {
                  _error = 'Error displaying PDF: $error';
                });
              },
            ),
          ),
        ],
      );
    }

    return const Center(
      child: Text('No PDF loaded'),
    );
  }
}
