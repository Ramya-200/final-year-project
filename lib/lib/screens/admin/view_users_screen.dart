import 'package:flutter/cupertino.dart';
import 'package:student_details/utils/showModal.dart';
import 'package:student_details/widgets/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAllUsersPage extends StatefulWidget {
  @override
  _ViewAllUsersPageState createState() => _ViewAllUsersPageState();
}

class _ViewAllUsersPageState extends State<ViewAllUsersPage> {
  List<dynamic> users = [];

  void getAllUsers() {
    Supabase.instance.client
          .from('students')
          .select()
          .execute()
          .then((response) {
        if (response.error == null) {
          for (var user in response.data) {
            setState(() {
              users.add(user);
            });
          }
          if (users.length == 0) {
            showModal('Not Found', 'No Users Found In Database', context);
          }
        }
      });
  }

  void navigateToUserProfile(String userEmail) {
    Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => UserProfilePage(email: userEmail)),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('All Users'),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return CupertinoListTile(
              title: Text('${index+1}. ' + users[index]['email'] + ' - ' + users[index]['username']),
              onTap: () {
                navigateToUserProfile(users[index]['email']);
              },
            );
          },
        ),
      ),
    );
  }
}