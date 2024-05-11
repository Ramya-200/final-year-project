import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AcademicDetailsScreen extends StatefulWidget {
  @override
  _AcademicDetailsScreenState createState() => _AcademicDetailsScreenState();
}

class _AcademicDetailsScreenState extends State<AcademicDetailsScreen> {
  List<TextEditingController> subjects = [];
  List<TextEditingController> marks = [];

  void addMarkstodatabase() {
    for (int i = 0; i < subjects.length; i++) {
      if (subjects[i].text.isEmpty || marks[i].text.isEmpty) {
        continue;
      }
      if (marks[i].text.contains(RegExp(r'[a-zA-Z]'))) {
        continue;
      }
      Supabase.instance.client.from('sem_marks').insert([
        {
          'subname': subjects[i].text,
          'mark': int.parse(marks[i].text),
          'user_id': Supabase.instance.client.auth.currentUser!.id,
          'email': Supabase.instance.client.auth.currentUser!.email,
        }
      ]).execute().then((value) => print(value.error));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Academic Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildSemesterForm(),
            ElevatedButton(
              onPressed: () {
                addMarkstodatabase();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSemesterForm() {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(subjects.length, (index) {
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: subjects[index],
                    decoration: InputDecoration(labelText: 'Enter subject'),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    controller: marks[index],
                    decoration: InputDecoration(labelText: 'Enter marks'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            );
          })..add(
            ElevatedButton(
              onPressed: () {
                setState(() {
                  subjects.add(TextEditingController());
                  marks.add(TextEditingController());
                });

              },
              child: Text('Add Subject'),
            ),
          ),
        ),
      ),
    );
  }
}

