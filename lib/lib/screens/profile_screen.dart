import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:student_details/widgets/breadcrumbs.dart';
import 'package:student_details/widgets/textfield_styled.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/components/auth_required_state.dart';
import '/utils/helpers.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends AuthRequiredState<ProfileScreen> {
  _ProfileScreenState();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _updateProfileBtnController =
      RoundedLoadingButtonController();

  final _picker = ImagePicker();

  User? user;
  bool loadingProfile = true;
  String _appBarTitle = '';
  String username = '';
  int reg_no = 0;
  String blood_group = '';
  String gender = 'Male';
  String? dob;
  String avatarUrl = '';
  String avatarKey = '';

  @override
  void onAuthenticated(Session session) {
    final _user = session.user;
    if (_user != null) {
      setState(() {
        _appBarTitle = 'Personal Information';
        user = _user;
      });
      _loadProfile(_user.id);
    }
  }

  Future _loadProfile(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('students')
          .select(
              'username, reg_no, avatar_url, updated_at, email, blood_group, gender, dob')
          .eq('id', userId)
          .maybeSingle()
          .execute();
      if (response.error != null) {
        throw "Load profile failed: ${response.error!.message}";
      }

      setState(() {
        print(response.data);
        username = response.data?['username'] as String? ?? '';
        reg_no = response.data?['reg_no'] as int? ?? 0;
        blood_group = response.data?['blood_group'] as String? ?? '';
        gender = response.data?['gender'] as String? ?? 'Male';
        dob = response.data?['dob'] as String? ?? null;
        avatarUrl = response.data?['avatar_url'] as String? ?? '';
        final updatedAt = response.data?['updated_at'] as String? ?? '';
        avatarKey = '$avatarUrl-$updatedAt';
      });
    } catch (e) {
      showMessage(e.toString());
    } finally {
      setState(() {
        loadingProfile = false;
      });
    }
  }

  // Future _onSignOutPress(BuildContext context) async {
  //   Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
  //   await Supabase.instance.client.auth.signOut();
  // }

  Future _updateAvatar(BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 600,
        maxWidth: 600,
      );
      if (pickedFile == null) {
        return;
      }

      final size = await pickedFile.length();
      if (size > 1000000) {
        throw "The file is too large. Allowed maximum size is 1 MB.";
      }

      final bytes = await pickedFile.readAsBytes();
      final fileName = avatarUrl == '' ? '${randomString(15)}.jpg' : avatarUrl;
      const fileOptions = FileOptions(upsert: true);
      final uploadRes = await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(fileName, bytes, fileOptions: fileOptions);

      if (uploadRes.error != null) {
        throw uploadRes.error!.message;
      }

      final updatedAt = DateTime.now().toString();
      final res = await Supabase.instance.client.from('students').upsert({
        'id': user!.id,
        'avatar_url': fileName,
        'updated_at': updatedAt,
        'email': user!.email,
      }).execute();
      if (res.error != null) {
        throw res.error!.message;
      }

      if (this.mounted) {
        setState(() {
          avatarUrl = fileName;
          avatarKey = '$avatarUrl-$updatedAt';
        });
      }
      showMessage("Avatar updated!");
      setState(() {
        loadingProfile = true;
      });
      await Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      });
    } catch (e) {
      showMessage(e.toString());
    }
  }

  Future _onUpdateProfilePress(BuildContext context) async {
    try {
      FocusScope.of(context).unfocus();

      final updates = {
        'id': user?.id,
        'username': username,
        'reg_no': reg_no,
        'blood_group': blood_group,
        'gender': gender,
        'dob': dob,
        'updated_at': DateTime.now().toString(),
        'email': user?.email,
      };

      if (dob == null) {
        throw "Please select your date of birth";
      }

      final response = await Supabase.instance.client
          .from('students')
          .upsert(updates)
          .execute();

      if (response.error != null) {
        final message = response.error!.message;

        if (message.contains('username_length')) {
          throw "Username must be between 3 and 20 characters";
        } else if (username.contains(RegExp(r'[0-9]'))) {
          throw "Username must not contain numbers";
        } else if (message.contains('reg_no_key')) {
          throw "Registration number already exists";
        } else if (message.contains('reg_no_check')) {
          throw "Fill in your registration number";
        } else if (message.contains('blood_group_check')) {
          throw "Invalid blood group";
        } else {
          throw message;
        }
      }

      showMessage("Profile updated!");
      Navigator.pushNamed(context, '/profile/parent');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      _updateProfileBtnController.reset();
    }
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    if (loadingProfile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitle),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(_appBarTitle),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BreadcrumbText(
                        text: 'Personal', isActive: true, isFinished: false),
                    Text(' > '),
                    BreadcrumbText(
                        text: 'Parent', isActive: false, isFinished: false),
                    Text(' > '),
                    BreadcrumbText(
                        text: 'Bank', isActive: false, isFinished: false),
                    Text(' > '),
                    BreadcrumbText(
                        text: 'Contact', isActive: false, isFinished: false),
                  ],
                ),
                const SizedBox(height: 15.0),
                AvatarContainer(
                  url: avatarUrl,
                  onUpdatePressed: () => _updateAvatar(context),
                  key: Key(avatarKey),
                ),
                const SizedBox(height: 15.0),
                CustomTextField(
                  value: username,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Username',
                  prefixIcon: Icon(Icons.person),
                  onChanged: (newValue) {
                    setState(() {
                      username = newValue;
                    });
                  },
                ),
                const SizedBox(height: 15.0),
                CustomTextField(
                  value: reg_no == 0 ? '' : '$reg_no',
                  keyboardType: TextInputType.number,
                  label: 'Registration Number',
                  prefixIcon: Icon(Icons.info),
                  onChanged: (newValue) {
                    setState(() {
                      reg_no = newValue == '' ? 0 : int.parse(newValue);
                    });
                  },
                ),
                const SizedBox(height: 15.0),
                CustomTextField(
                  value: blood_group,
                  keyboardType: TextInputType.text,
                  label: 'Blood Group',
                  prefixIcon: Icon(Icons.bloodtype),
                  onChanged: (newValue) {
                    setState(() {
                      blood_group = newValue;
                    });
                  },
                ),
                const SizedBox(height: 15.0),
                CupertinoFormRow(
                  prefix: Text(
                    'Gender',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemBlue,
                      fontSize: 16,
                    ),
                  ),
                  child: CupertinoSlidingSegmentedControl<String>(
                    groupValue: gender,
                    onValueChanged: (newValue) {
                      setState(() {
                        gender = newValue!;
                      });
                    },
                    children: <String, Widget>{
                      'Male': Text(
                        'Male',
                        style: TextStyle(
                            color: gender == 'Male'
                                ? CupertinoColors.white
                                : CupertinoColors.systemBlue),
                      ),
                      'Female': Text(
                        'Female',
                        style: TextStyle(
                            color: gender == 'Female'
                                ? CupertinoColors.white
                                : CupertinoColors.systemBlue),
                      ),
                      'Other': Text(
                        'Other',
                        style: TextStyle(
                            color: gender == 'Other'
                                ? CupertinoColors.white
                                : CupertinoColors.systemBlue),
                      ),
                    },
                    thumbColor: CupertinoColors.systemBlue,
                    backgroundColor: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 15.0),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              dob = '${date.year}-${date.month}-${date.day}';
                            });
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey[200]),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              dob == null
                                  ? 'Date of Birth'
                                  : 'Date of Birth: $dob',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35.0),
                RoundedLoadingButton(
                  color: Colors.green,
                  controller: _updateProfileBtnController,
                  onPressed: () {
                    _onUpdateProfilePress(context);
                  },
                  child: const Text('Next',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
                const SizedBox(height: 15.0),
                TextButton(
                  onPressed: () {
                    stopAuthObserver();
                    Navigator.pushNamed(context, '/profile/changePassword')
                        .then((_) => startAuthObserver());
                  },
                  child: const Text("Change password"),
                ),
                const SizedBox(height: 15.0),
                // RoundedLoadingButton(
                //   color: Colors.red,
                //   controller: _signOutBtnController,
                //   onPressed: () {
                //     _onSignOutPress(context);
                //   },
                //   child: const Text('Sign out',
                //       style: TextStyle(fontSize: 20, color: Colors.white)),
                // ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class AvatarContainer extends StatefulWidget {
  final String url;
  final void Function() onUpdatePressed;
  const AvatarContainer(
      {required this.url, required this.onUpdatePressed, Key? key})
      : super(key: key);

  @override
  _AvatarContainerState createState() => _AvatarContainerState();
}

class _AvatarContainerState extends State<AvatarContainer> {
  _AvatarContainerState();

  bool loadingImage = false;
  Uint8List? image;

  @override
  void initState() {
    super.initState();

    if (widget.url != '') {
      downloadImage(widget.url);
    }
  }

  Future<bool> downloadImage(String path) async {
    setState(() {
      loadingImage = true;
    });

    final response =
        await Supabase.instance.client.storage.from('avatars').download(path);
    if (response.error == null) {
      setState(() {
        image = response.data;
        loadingImage = false;
      });
    } else {
      print(response.error!.message);
      setState(() {
        loadingImage = false;
      });
    }
    return true;
  }

  ImageProvider<Object> _getImage() {
    if (image != null) {
      return MemoryImage(image!);
    } else {
      return const AssetImage('assets/images/noavatar.jpeg');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loadingImage) {
      return const CircleAvatar(
        radius: 65,
        child: Align(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return CircleAvatar(
        radius: 65,
        backgroundImage: _getImage(),
        child: Stack(children: [
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white70,
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 18,
                ),
              ),
              onPressed: () => widget.onUpdatePressed(),
            ),
          ),
        ]),
      );
    }
  }
}
