import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> requestPermissions() async {
  if (Platform.isAndroid) {
    if (Platform.version.contains('33')) {
      // Android 13 and above
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
    } else if (Platform.version.contains('30')) {
      // Android 11 and above
      if (await Permission.manageExternalStorage.isDenied) {
        await Permission.manageExternalStorage.request();
      }
    } else {
      // Android 10 and below
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
    }
  }
}

void generatePdf(String name, String membershipDate) async {
  await requestPermissions();

  print('Generate PDF button clicked');

  try {
    // Get the directory for storing the generated PDF file
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    }
    if (directory == null) {
      throw Exception('Failed to get the storage directory.');
    }

    // Generate a unique file name using a timestamp
    String timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    String filePath = '${directory.path}/membership_certificate_$timestamp.pdf';

    // Load the template PDF from the assets folder
    final ByteData templateBytes = await rootBundle.load('assets/template.pdf');
    final Uint8List templateData = templateBytes.buffer.asUint8List();

    // Load the template PDF document
    final PdfDocument templatePdf = PdfDocument(inputBytes: templateData);

    // Create a new PDF document to hold the modified content
    final PdfDocument pdfDocument = PdfDocument();
    pdfDocument.pageSettings.margins.all = 0.0;


    // Import all pages from the template PDF to the new document
    for (int i = 0; i < templatePdf.pages.count; i++) {
      pdfDocument.pages.add().graphics.drawPdfTemplate(
          templatePdf.pages[i].createTemplate(), Offset(0, 0));
    }

    // Set the font for text drawing
    final ByteData fontData = await rootBundle.load('assets/Helvetica.ttf');
    final PdfFont font = PdfTrueTypeFont(fontData.buffer.asUint8List(), 20);

    // Draw name and membership date on the first page
    final PdfPage firstPage = pdfDocument.pages[0];
    firstPage.graphics.drawString(name, font,
        bounds: Rect.fromLTWH(200, 391, 200, 40));
    firstPage.graphics.drawString(membershipDate, font,
        bounds: Rect.fromLTWH(67, 639, 200, 20));

    // Save the modified PDF to a file
    final List<int> pdfBytes = await pdfDocument.save();
    final File pdfFile = File(filePath);
    await pdfFile.writeAsBytes(pdfBytes);

    print('PDF file generated at: $filePath');

    // Open the PDF file using the open_file package
    final result = await OpenFile.open(filePath);
    if (result.type == ResultType.error) {
      print('Error opening PDF: ${result.message}');
    }

    // Dispose the documents
    pdfDocument.dispose();
    templatePdf.dispose();
  } catch (error) {
    print('Error generating PDF: $error');
  }
}
