import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_details/components/auth_required_state.dart';
import '/components/manage_admins.dart';

import 'package:student_details/utils/showModal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewAdminsPage extends StatefulWidget {
  @override
  _ViewAdminsPageState createState() => _ViewAdminsPageState();
}

class _ViewAdminsPageState extends AuthRequiredState<ViewAdminsPage> {
  List<String> adminsList = [];
  User? user;
  String email = '';

  @override
  void onAuthenticated(Session session) {
    final _user = session.user;
    if (_user != null) {
      setState(() {
        user = _user;
        email = _user.email!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadAdmins();
  }

  Future<void> loadAdmins() async {
    try {
      final response =
          await Supabase.instance.client.from('admins').select().execute();

      if (response.error == null && response.data.length > 0) {
        List<String> admins = [];
        for (var i = 0; i < response.data.length; i++) {
            admins.add(response.data[i]['email']);
        }

        if (admins.length > 0) {
          if (mounted) {
            setState(() {
              adminsList = admins;
            });
          }
        } else {
          showModal('Not Found', 'You Are The Only Admin', context);
        }
      }
    } catch (error) {
      showModal('Error', error.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('View Admins'),
      ),
      child: SafeArea(
        child: ListView.builder(
          itemCount: adminsList.length,
          itemBuilder: (context, index) {
            final adminEmail = adminsList[index];
            return AdminListItem(
              adminEmail: adminEmail,
              onRemove: () {
                removeAdmin(context, adminEmail);
                setState(() {
                  adminsList.removeAt(index);
                });
              },
            );
          },
        ),
      ),
    );
  }
}

class AdminListItem extends StatelessWidget {
  final String adminEmail;
  final VoidCallback onRemove;

  const AdminListItem({required this.adminEmail, required this.onRemove});

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Confirm Removal'),
          content: Text('Are you sure you want to remove this admin?'),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                onRemove();
                Navigator.pop(context);
              },
              child: Text('Remove'),
              isDestructiveAction: true,
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.separator)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            adminEmail,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.black,
              decoration: TextDecoration.none,
            ),
          ),
          CupertinoButton(
            onPressed: () {
              _showConfirmDialog(context);
            },
            padding: EdgeInsets.zero,
            child: Icon(
              CupertinoIcons.minus_circled,
              color: CupertinoColors.systemRed,
            ),
          ),
        ],
      ),
    );
  }
}
