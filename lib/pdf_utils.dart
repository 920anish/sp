import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

void generatePdf(String name, String membershipDate) async {
  print('Generate PDF button clicked');

  try {
    // Request permissions to write to external storage (Android specific)
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (status.isDenied) {
        throw Exception('Permission denied to access storage.');
      }
    }

    // Get the directory for storing the generated PDF file
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      throw Exception('Failed to get the storage directory.');
    }

    String filePath = '${directory.path}/membership_certificate.pdf';

    // Load the template png from the assets folder
    final ByteData templateBytes = await rootBundle.load('assets/certificate920.png');
    final Uint8List templateData = templateBytes.buffer.asUint8List();

    // Use a PDF package (e.g., pdf or pdf_flutter) to modify the template and generate the final PDF
    final pdfDocument = pw.Document();

    final ttf = await rootBundle.load('assets/Helvetica.ttf');
    final font = pw.Font.ttf(ttf);

    pdfDocument.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Existing template PDF as the background
              pw.Image(pw.MemoryImage(templateData)),
              // Name positioned in the center
              pw.Positioned(
          top: 400,
          left: 187,
                child: pw.Center(
                  child: pw.Text(
                    '$name',
                    style: pw.TextStyle(font: font, fontSize: 20),
                  ),
                ),
              ),
              // Membership date positioned in the bottom left
              pw.Positioned(
                left: 50,
                bottom: 50,
                child: pw.Text(
                  '$membershipDate',
                  style: pw.TextStyle(font: font, fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdfDocument.save();

    // Save the modified PDF to a file
    final File pdfFile = File(filePath);
    await pdfFile.writeAsBytes(pdfBytes);

    print('PDF file generated at: $filePath');

    // Open the PDF file using the open_file package
    final result = await OpenFile.open(filePath);
    if (result.type == ResultType.error) {
      print('Error opening PDF: ${result.message}');
    }
  } catch (error) {
    print('Error generating PDF: $error');
  }
}
