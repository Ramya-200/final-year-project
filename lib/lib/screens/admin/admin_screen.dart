import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Admin Page'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Card(
              margin: EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                height: 143,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset('assets/images/admin_banner.png'),
                ),
              ),
            ),
            CupertinoListTile(
              leading: Icon(CupertinoIcons.add),
              title: Text('Add Admin'),
              onTap: () {
                Navigator.pushNamed(context, '/admin/add');
              },
            ),
            CupertinoListTile(
              leading: Icon(CupertinoIcons.person_crop_circle),
              title: Text('View Admins'),
              onTap: () {
                Navigator.pushNamed(context, '/admin/view');
              },
            ),
            CupertinoListTile(
              leading: Icon(CupertinoIcons.search),
              title: Text('Search User'),
              onTap: () {
                Navigator.pushNamed(context, '/admin/search');
              },
            ),
            CupertinoListTile(
              leading: Icon(CupertinoIcons.group_solid),
              title: Text('View All Users'),
              onTap: () {
                Navigator.pushNamed(context, '/admin/allusers');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback? onTap;

  const CupertinoListTile({
    required this.leading,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            leading,
            SizedBox(width: 16.0),
            Expanded(child: title),
            Icon(CupertinoIcons.forward, color: CupertinoColors.systemGrey),
          ],
        ),
      ),
    );
  }
}
