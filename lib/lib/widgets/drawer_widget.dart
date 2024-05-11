import 'package:flutter/material.dart';

import '/utils/drawer_items.dart';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        radius: 35,
        backgroundImage: const AssetImage('assets/images/noavatar.jpeg'),
      );
    } else {
      return CircleAvatar(
        radius: 35,
        backgroundImage: _getImage(),
      );
    }
  }
}

class DrawerWidget extends StatelessWidget {
  final List<DrawerItem> drawerItems;
  final Map<String, dynamic> data;

  const DrawerWidget(
      {Key? key, required this.drawerItems, required this.data})
      : super(key: key);

  String get imageUrl {
    return data['avatar_url'] as String? ?? '';
  }

  String get username {
    return data['username'] as String? ?? '';
  }

  String get email {
    return data['email'] as String? ?? '';
  }

  String convertFirstLetterToUppercase(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  String get getUsername {
    final parts = data['email'].split('@');
    if (username != '') {
      return username;
    }
    return convertFirstLetterToUppercase(parts[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.green),
              accountName: Text(getUsername),
              accountEmail: Text(email),
              currentAccountPicture: Column(
                children: [
                  AvatarContainer(
                    url: imageUrl,
                    onUpdatePressed: () {},
                  ),
                ],
              )),
          ...drawerItems.map((item) {
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              onTap: () {
                item.onTap(context, data);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
