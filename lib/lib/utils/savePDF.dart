import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

List<pw.Widget> generateTwoColumnTable(
    List<String> leftColumn, List<String> rightColumn) {
  List<pw.Widget> tableWidgets = [];
  for (int i = 0; i < leftColumn.length; i++) {
    tableWidgets.add(
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(leftColumn[i]),
          pw.Text(rightColumn[i]),
        ],
      ),
    );
  }
  return tableWidgets;
}

Future<File> writeFile(Uint8List data, String name) async {
  // the downloads folder path
  Directory? tempDir = await DownloadsPathProvider.downloadsDirectory;
  String? tempPath = tempDir?.path;
  var filePath = tempPath! + '/$name';
  //

  // the data
  var bytes = ByteData.view(data.buffer);
  final buffer = bytes.buffer;
  // save the data in the path
  return File(filePath)
      .writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Future<void> saveAsPDF(
    String username,
    Map<String, dynamic> student,
    Map<String, dynamic> parent,
    Map<String, dynamic> bank,
    Map<String, dynamic> contact) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('User Profile', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            // Student Information
            pw.Text('Student Information', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 8),
            ...generateTwoColumnTable([
              'Name',
              'Register No',
              'Date of Birth',
              'Gender',
              'Blood Group',
            ], [
              student['username'] as String,
              student['reg_no'].toString(),
              student['dob'].toString(),
              student['gender'] as String,
              student['blood_group'] as String,
            ]),
            // Parent Information
            pw.Text('Parent Information', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 8),
            ...generateTwoColumnTable([
              'Mother Name',
              'Mother Occupation',
              'Father Name',
              'Father Occupation',
              'Annual Income',
            ], [
              parent['mother_name'] as String,
              parent['mother_work'] as String,
              parent['father_name'] as String,
              parent['father_work'] as String,
              parent['annual_income'].toString(),
            ]),
            // Bank Information
            pw.Text('Bank Information', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 8),
            ...generateTwoColumnTable([
              'Bank Name',
              'Account No',
              'Branch Name',
              'IFSC Code',
            ], [
              bank['bank_name'] as String,
              bank['account_no'].toString(),
              bank['branch_name'] as String,
              bank['ifsc_code'] as String,
            ]),
            // Contact Information
            pw.Text('Contact Information', style: pw.TextStyle(fontSize: 18)),
            pw.SizedBox(height: 8),
            ...generateTwoColumnTable([
              'Aadhar No',
              'Mobile No',
              'Email',
              'Address',
            ], [
              contact['aadhar_no'].toString(),
              contact['mobile_no'].toString(),
              student['email'] as String,
              contact['address'] as String,
            ]),
            pw.SizedBox(height: 15),
            // Created At
            pw.Text(
              'Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(student['updated_at']).toLocal())}',
              style: pw.TextStyle(fontSize: 16, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 40),
          ],
        );
      },
    ),
  );

  await writeFile(await pdf.save(), '$username.pdf');
}