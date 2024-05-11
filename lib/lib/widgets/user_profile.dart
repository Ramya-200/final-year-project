import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:student_details/utils/savePDF.dart';
import 'package:student_details/widgets/twocolumn_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfilePage extends StatefulWidget {
  final String email;

  UserProfilePage({required this.email});

  @override
  _UserProfilePage createState() => _UserProfilePage();
}

class _UserProfilePage extends State<UserProfilePage> {
  Map<String, dynamic> student = {};
  Map<String, dynamic> parent = {};
  Map<String, dynamic> bank = {};
  Map<String, dynamic> contact = {};
  List<Map<String, dynamic>> marks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Supabase.instance.client
        .from('students')
        .select()
        .eq('email', widget.email)
        .maybeSingle()
        .execute()
        .then((response) {
      if (response.error == null) {
        setState(() {
          student = response.data as Map<String, dynamic>;
        });
        Supabase.instance.client
            .from('parent_info')
            .select()
            .eq('reg_no', student['reg_no'] as int)
            .maybeSingle()
            .execute()
            .then((response) {
          if (response.error == null) {
            setState(() {
              parent = response.data as Map<String, dynamic>;
            });
            Supabase.instance.client
                .from('bank_info')
                .select()
                .eq('reg_no', student['reg_no'])
                .maybeSingle()
                .execute()
                .then((response) {
              if (response.error == null) {
                setState(() {
                  bank = response.data as Map<String, dynamic>;
                });
                Supabase.instance.client
                    .from('contact_info')
                    .select()
                    .eq('reg_no', student['reg_no'])
                    .maybeSingle()
                    .execute()
                    .then((response) {
                  if (response.error == null) {
                    setState(() {
                      contact = response.data as Map<String, dynamic>;
                    });
                    Supabase.instance.client
                        .from('sem_marks')
                        .select()
                        .eq('email', student['email'])
                        .execute()
                        .then((response) {
                      if (response.error == null) {
                        for (int i = 0; i < response.data.length; i++) {
                          setState(() {
                            marks.add(response.data[i] as Map<String, dynamic>);
                          });
                        }
                        setState(() {
                          _loading = false;
                        });
                      }
                    });
                  }
                });
              }
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Loading...'),
        ),
        child: SafeArea(
          child: Center(
            child: CupertinoActivityIndicator(),
          ),
        ),
      );
    } else {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('User Profile'),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              try {
                await Permission.storage.request();
              } catch (e) {
                showErrorDialog(context, 'Storage permission required');
              }
              final permission = await Permission.storage.status;
              if (permission.isGranted) {
                await saveAsPDF(student['username'] as String, student, parent,
                    bank, contact);
                showSuccessDialog(context);
              } else {
                showErrorDialog(context, 'Storage permission required');
              }
            },
            child: Icon(CupertinoIcons.cloud_download),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 80.0),
              DefaultTextStyle(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.activeBlue),
                child: Text('Student Information'),
              ),
              const SizedBox(height: 8.0),
              TwoColumnTable(
                leftColumn: [
                  'Name',
                  'Register No',
                  'Date of Birth',
                  'Gender',
                  'Blood Group',
                ],
                rightColumn: [
                  student['username'] as String,
                  student['reg_no'].toString(),
                  student['dob'].toString(),
                  student['gender'] as String,
                  student['blood_group'] as String,
                ],
              ),
              const SizedBox(height: 8.0),
              DefaultTextStyle(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.activeBlue),
                child: Text('Parent Information'),
              ),
              const SizedBox(height: 8.0),
              TwoColumnTable(
                leftColumn: [
                  'Mother Name',
                  'Mother Occupation',
                  'Father Name',
                  'Father Occupation',
                  'Annual Income',
                ],
                rightColumn: [
                  parent['mother_name'] as String,
                  parent['mother_work'] as String,
                  parent['father_name'] as String,
                  parent['father_work'] as String,
                  parent['annual_income'].toString(),
                ],
              ),
              const SizedBox(height: 8.0),
              DefaultTextStyle(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.activeBlue),
                child: Text('Bank Information'),
              ),
              const SizedBox(height: 8.0),
              TwoColumnTable(
                leftColumn: [
                  'Bank Name',
                  'Account No',
                  'Branch Name',
                  'IFSC Code',
                ],
                rightColumn: [
                  bank['bank_name'] as String,
                  bank['account_no'].toString(),
                  bank['branch_name'] as String,
                  bank['ifsc_code'] as String,
                ],
              ),
              const SizedBox(height: 8.0),
              DefaultTextStyle(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.activeBlue),
                child: Text('Contact Information'),
              ),
              const SizedBox(height: 8.0),
              TwoColumnTable(
                leftColumn: [
                  'Aadhar No',
                  'Mobile No',
                  'Email',
                  'Address',
                ],
                rightColumn: [
                  contact['aadhar_no'].toString(),
                  contact['mobile_no'].toString(),
                  student['email'] as String,
                  contact['address'] as String,
                ],
              ),
              const SizedBox(height: 8.0),
              
              DefaultTextStyle(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.activeBlue),
                child: Text('Semester Marks'),
              ),
              const SizedBox(height: 8.0),
              buildMarksTable(),
              const SizedBox(height: 8.0),
              DefaultTextStyle(
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: CupertinoColors.activeBlue),
                child: Text('Blackmark Details'),
              ),
              const SizedBox(height: 8.0),
              TwoColumnTable(
                leftColumn: [
                  'Blackmark',
                ],
                rightColumn: [
                  student['blackmark'] == null
                      ? 'No Blackmark'
                      : student['blackmark'].toString(),
                ],
              ),
              const SizedBox(height: 8.0),
              CupertinoButton(
                child: Text('Add Blackmark'),
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) {
                      String blackmark = '';
                      return CupertinoAlertDialog(
                        title: Text('Add Blackmark'),
                        content: CupertinoTextField(
                          onChanged: (value) {
                            blackmark = value;
                          },
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          CupertinoDialogAction(
                            child: Text('Add'),
                            onPressed: () {
                              Supabase.instance.client
                                  .from('students')
                                  .update({'blackmark': blackmark})
                                  .eq('reg_no', student['reg_no'])
                                  .execute();
                              print('Adding blackmark: $blackmark');
                              setState(() {
                                student['blackmark'] = blackmark;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 15.0),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: CupertinoColors.systemGrey3,
                ),
                child: Text(
                  'Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(student['updated_at']).toLocal())}',
                ),
              ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      );
    }
  }

  Widget buildMarksTable() {
    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            TableCell(
              child: Center(
                child: Text('Subject'),
              ),
            ),
            TableCell(
              child: Center(
                child: Text('Mark'),
              ),
            ),
          ],
        ),
        for (int i = 0; i < marks.length; i++)
          TableRow(
            children: [
              TableCell(
                child: Center(
                  child: Text(marks[i]['subname'].toString()),
                ),
              ),
              TableCell(
                child: Center(
                  child: Text(marks[i]['mark'].toString()),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

Future<void> showSuccessDialog(BuildContext context) async {
  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Success'),
        content: Text('PDF has been saved to Downloads folder.'),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

Future<void> showErrorDialog(BuildContext context, String message) async {
  await showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}
