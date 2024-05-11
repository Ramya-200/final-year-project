//create a home page and import the drawer widget
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:student_details/widgets/user_profile.dart';

import '/components/auth_required_state.dart';
import '/widgets/drawer_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/utils/drawer_items.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends AuthRequiredState<HomeScreen> {
  _HomeScreenState();

  List<DrawerItem> drawerItems = [
    DrawerItem(
      icon: Icons.account_circle,
      title: 'Profile',
      onTap: (context, data) {
        if (data['is_admin'] == false) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/profile', (route) => true);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('Not Found'),
                content: Text('Admin Cannot Access Profile'),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () {
                      // Close the modal when the button is pressed
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      },
    ),
    DrawerItem(
      icon: Icons.logout,
      title: 'Sign Out',
      onTap: (context, data) async {
        Navigator.pop(context);
        await Supabase.instance.client.auth.signOut();
      },
    ),
    DrawerItem(
      icon: Icons.lock,
      title: 'Admin Settings',
      onTap: (context, data) {
        if (data['is_admin'] == true) {
          Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => true);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CupertinoAlertDialog(
                title: Text('No Access'),
                content: Text('Admin Access Are Not Available'),
                actions: [
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed: () {
                      // Close the modal when the button is pressed
                      Navigator.pop(context);
                    },
                    child: Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      },
    ),
  ];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _signOutBtnController =
      RoundedLoadingButtonController();

  User? user;
  bool loadingProfile = true;
  String _appBarTitle = 'Hello';
  String username = '';
  int reg_no = 0;
  String avatarUrl = '';
  String avatarKey = '';
  String email = '';
  bool isAdmin = false;
  bool isVerified = false;
  bool isADCompleted = false;

  @override
  void onAuthenticated(Session session) {
    final _user = session.user;
    if (_user != null) {
      setState(() {
        // _appBarTitle = '${username != '' ? username : _user.email}';
        _appBarTitle = 'Student Details';
        user = _user;
        email = _user.email!;
      });
      _loadProfile(_user.id);
    }
  }

  @override
  void initState() {
    super.initState();
    final _user = Supabase.instance.client.auth.currentUser;
    if (_user != null) {
      setState(() {
        // _appBarTitle = '${username != '' ? username : _user.email}';
        _appBarTitle = 'Student Details';
        user = _user;
        email = _user.email!;
      });
      _loadProfile(_user.id);
    }
  }

  Future _loadProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('students')
          .select(
              'username, reg_no, avatar_url, updated_at, email, profile_completed')
          .eq('id', userId)
          .maybeSingle()
          .execute();
      if (response.error != null) {
        throw "Load profile failed: ${response.error!.message}";
      }

      final admin_response = await Supabase.instance.client
          .from('admins')
          .select('email')
          .eq('id', userId)
          .maybeSingle()
          .execute();

      if (admin_response.error != null) {
        throw "Load profile failed: ${admin_response.error!.message}";
      }

      final sem_response = await Supabase.instance.client
          .from('sem_marks')
          .select()
          .eq('user_id', userId)
          .execute();

      setState(() {
        username = response.data?['username'] as String? ?? '';
        reg_no = response.data?['reg_no'] as int? ?? 0;
        avatarUrl = response.data?['avatar_url'] as String? ?? '';
        final updatedAt = response.data?['updated_at'] as String? ?? '';
        avatarKey = '$avatarUrl-$updatedAt';
        isAdmin = admin_response.data != null;
        isVerified = response.data?['profile_completed'] as bool? ?? false;
        isADCompleted = sem_response.data != null;
      });

      if (!isVerified && !isAdmin) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/profile', (route) => false);
      }
    } catch (e) {
      showMessage(e.toString());
    } finally {
      setState(() {
        loadingProfile = false;
      });
    }
  }

  Future _onSignOutPress(BuildContext context) async {
    Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
    await Supabase.instance.client.auth.signOut();
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  Map<String, dynamic> get profile {
    return {
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'is_admin': isAdmin,
      'is_verified': isVerified,
      'is_ad_completed': isADCompleted,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (loadingProfile) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(_appBarTitle),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (!isAdmin) {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(_appBarTitle),
          backgroundColor: Colors.green,
        ),
        drawer: DrawerWidget(
          drawerItems: drawerItems,
          data: profile,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 4.0),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.grey[800],
                  ),
                  child: Text('Welcome,'),
                ),
              ),
              Card(
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  height: 143,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.asset('assets/images/home_banner.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 4.0),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.grey[800],
                  ),
                  child: Text('Actions'),
                ),
              ),
              //create a card widget with action like edit profile and signout
              Card(
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '✓ Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/profile', (route) => true);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              if (isADCompleted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return UserProfilePage(
                                        email: Supabase.instance.client.auth
                                            .currentUser!.email!);
                                  }),
                                );
                              } else {
                              Navigator.pushNamedAndRemoveUntil(context,
                                  '/addAcademicDetails', (route) => true);
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  isADCompleted == true
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                  SizedBox(width: 4),
                                  Text(
                                    isADCompleted == true
                                        ? 'View Details'
                                        : 'Add Academic Details',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 4.0),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.grey[800],
                  ),
                  child: Text('About Us'),
                ),
              ),
              //create a card widget to display the about us text
              Card(
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'The Student Management System is a web application developed for the students to manage their academic activities. The system is designed to help the students to manage their academic activities such as attendance, marks, assignments, etc. The system is developed using Flutter and Supabase.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              // ElevatedButton(
              //     onPressed: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => UserProfilePage(
              //                   email: Supabase.instance.client.auth
              //                       .currentUser!.email!)));
              //     },
              //     child: Text('Show Profile')),
              RoundedLoadingButton(
                color: Colors.red,
                controller: _signOutBtnController,
                onPressed: () {
                  _onSignOutPress(context);
                },
                child: const Text('Sign out',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              const SizedBox(height: 35.0),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(_appBarTitle),
          backgroundColor: Colors.green,
        ),
        drawer: DrawerWidget(
          drawerItems: drawerItems,
          data: profile,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 4.0),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.grey[800],
                  ),
                  child: Text('Welcome,'),
                ),
              ),
              Card(
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  height: 143,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.asset('assets/images/home_banner.png'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 4.0),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.grey[800],
                  ),
                  child: Text('Actions'),
                ),
              ),
              //create a card widget with action like edit profile and signout
              Card(
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '✓ Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Managements',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/admin', (route) => true);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.blue),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Admin Panel >',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 16.0, 4.0),
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: Colors.grey[800],
                  ),
                  child: Text('About Us'),
                ),
              ),
              //create a card widget to display the about us text
              Card(
                margin: EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'The Student Management System is a web application developed for the students to manage their academic activities. The system is designed to help the students to manage their academic activities such as attendance, marks, assignments, etc. The system is developed using Flutter and Supabase.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15.0),
              RoundedLoadingButton(
                color: Colors.red,
                controller: _signOutBtnController,
                onPressed: () {
                  _onSignOutPress(context);
                },
                child: const Text('Sign out',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              const SizedBox(height: 35.0),
            ],
          ),
        ),
      );
    }
  }
}
