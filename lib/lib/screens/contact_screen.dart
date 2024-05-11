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

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends AuthRequiredState<ContactScreen> {
  _ContactScreenState();

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final RoundedLoadingButtonController _updateProfileBtnController =
      RoundedLoadingButtonController();

  final _picker = ImagePicker();

  User? user;
  bool loadingProfile = true;
  String _appBarTitle = '';
  int reg_no = 0;
  int aadhar_no = 0;
  int mobile_no = 0;
  String address = '';
  String avatarUrl = '';
  String avatarKey = '';

  @override
  void onAuthenticated(Session session) {
    final _user = session.user;
    if (_user != null) {
      setState(() {
        _appBarTitle = 'Contact Information';
        user = _user;
      });
      _loadProfile(_user.id);
    }
  }

  Future _loadProfile(String userId) async {
    try {
      final res = await Supabase.instance.client
          .from('students')
          .select(
              'username, reg_no, avatar_url, updated_at, email, blood_group, gender, dob')
          .eq('id', userId)
          .maybeSingle()
          .execute();
      final response = await Supabase.instance.client
          .from('contact_info')
          .select('reg_no, aadhar_no, mobile_no, address, updated_at')
          .eq('reg_no', res.data['reg_no'] as int? ?? 0)
          .maybeSingle()
          .execute();

      if (response.error != null) {
        throw "Load profile failed: ${response.error!.message}";
      }

      setState(() {
        print(response.data);
        reg_no = res.data?['reg_no'] as int? ?? 0;
        aadhar_no = response.data?['aadhar_no'] as int? ?? 0;
        mobile_no = response.data?['mobile_no'] as int? ?? 0;
        address = response.data?['address'] as String? ?? '';
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
        'reg_no': reg_no,
        'aadhar_no': aadhar_no,
        'mobile_no': mobile_no,
        'address': address,
        'updated_at': DateTime.now().toString(),
      };

      if (aadhar_no == 0) {
        throw "Aadhar no is required.";
      } else if (mobile_no == 0) {
        throw "Mobile no is required.";
      } else if (address == '') {
        throw "Address is required.";
      }

      final response = await Supabase.instance.client
          .from('contact_info')
          .upsert(updates)
          .execute();

      if (response.error != null) {
        final message = response.error!.message;
        throw message;
      }

      final complete_response = await Supabase.instance.client
          .from('students')
          .update({'profile_completed': true}).eq('reg_no', reg_no).execute();

      if (complete_response.error != null) {
        final message = complete_response.error!.message;
        throw message;
      }

      showMessage("Profile updated!");
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
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
                        text: 'Personal', isActive: false, isFinished: true),
                    Text(' > '),
                    BreadcrumbText(
                        text: 'Parent', isActive: false, isFinished: true),
                    Text(' > '),
                    BreadcrumbText(
                        text: 'Bank', isActive: false, isFinished: true),
                    Text(' > '),
                    BreadcrumbText(
                        text: 'Contact', isActive: true, isFinished: false),
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
                  value: aadhar_no == 0 ? '' : '$aadhar_no',
                  keyboardType: TextInputType.number,
                  label: 'Aadhar No',
                  prefixIcon: Icon(Icons.ballot_rounded),
                  onChanged: (newValue) {
                    setState(() {
                      if (newValue.length <= 12) {
                        aadhar_no = int.tryParse(newValue) ?? 0;
                      }
                    });
                  },
                ),
                const SizedBox(height: 15.0),
                CustomTextField(
                  value: mobile_no == 0 ? '' : '$mobile_no',
                  keyboardType: TextInputType.number,
                  label: 'Mobile No',
                  prefixIcon: Icon(Icons.call),
                  onChanged: (newValue) {
                    setState(() {
                      if (newValue.length <= 10) {
                        mobile_no = int.tryParse(newValue) ?? 0;
                      }
                    });
                  },
                ),
                const SizedBox(height: 15.0),
                CustomTextField(
                  value: address,
                  keyboardType: TextInputType.text,
                  label: 'Address',
                  prefixIcon: Icon(Icons.format_color_text_rounded),
                  onChanged: (newValue) {
                    setState(() {
                      address = newValue;
                    });
                  },
                ),
                const SizedBox(height: 35.0),
                RoundedLoadingButton(
                  color: Colors.green,
                  controller: _updateProfileBtnController,
                  onPressed: () {
                    _onUpdateProfilePress(context);
                  },
                  child: const Text('Complete Profile',
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
