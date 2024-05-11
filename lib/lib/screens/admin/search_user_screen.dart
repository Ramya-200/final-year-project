

import 'package:flutter/cupertino.dart';
import 'package:student_details/widgets/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchUserByEmailPage extends StatefulWidget {
  @override
  _SearchUserByEmailPageState createState() => _SearchUserByEmailPageState();
}

class _SearchUserByEmailPageState extends State<SearchUserByEmailPage> {
  String searchQuery = '';
  List<String> searchResults = [];
  int selectedSearchTypeIndex = 0; // Index of the selected search type

  void searchUsers(String query, int searchTypeIndex) {
    if (searchTypeIndex == 0) {
      Supabase.instance.client
          .from('students')
          .select()
          .ilike('email', '%$searchQuery%')
          .execute()
          .then((response) {
        if (response.error == null) {
          for (var user in response.data) {
            setState(() {
              searchResults.add(user['email'] as String);
            });
          }
        }
      });
    } else if (searchTypeIndex == 1) {
      Supabase.instance.client
          .from('students')
          .select()
          .eq('reg_no', searchQuery)
          .execute()
          .then((response) {
        if (response.error == null) {
          for (var user in response.data) {
            setState(() {
              searchResults.add(user['email'] as String);
            });
          }
        }
      });
    }
  }

  void navigateToUserProfile(String userEmail) {
    Navigator.push(
      context,
      CupertinoPageRoute(
          builder: (context) => UserProfilePage(email: userEmail)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Search User'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CupertinoTextField(
                    placeholder: 'Search',
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Icon(
                        CupertinoIcons.search,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    onSubmitted: (value) {
                      setState(() {
                        searchResults.clear();
                      });
                      searchUsers(searchQuery, selectedSearchTypeIndex);
                    },
                  ),
                  SizedBox(height: 16.0),
                  CupertinoSlidingSegmentedControl<int>(
                    groupValue: selectedSearchTypeIndex,
                    children: {
                      0: DefaultTextStyle(
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: CupertinoColors.systemBlue),
                        child: Text('Email Address'),
                      ),
                      1: DefaultTextStyle(
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: CupertinoColors.systemBlue),
                        child: Text('Register Number'),
                      ),
                    },
                    onValueChanged: (value) {
                      setState(() {
                        selectedSearchTypeIndex = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final userEmail = searchResults[index];
                  return CupertinoListTile(
                    title: Text(userEmail),
                    onTap: () {
                      navigateToUserProfile(userEmail);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}