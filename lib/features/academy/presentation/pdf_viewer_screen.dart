import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:babytracker/features/academy/providers/academy_providers.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.guide,
  });

  final AcademyGuide guide;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.guide.title),
        backgroundColor: cs.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
            tooltip: 'Yer İmleri',
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.guide.pdfUrl,
        key: _pdfViewerKey,
        canShowScrollHead: false,
        canShowScrollStatus: false,
      ),
    );
  }
}
