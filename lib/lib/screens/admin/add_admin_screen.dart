import '/components/manage_admins.dart';
import 'package:flutter/cupertino.dart';

class AddAdminPage extends StatefulWidget {
  @override
  _AddAdminPageState createState() => _AddAdminPageState();
}

class _AddAdminPageState extends State<AddAdminPage> {
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Manage Admins'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              AddAdminTextField(
                placeholder: 'Enter New Admin Email',
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              SizedBox(height: 20),
              AddAdminTextField(
                placeholder: 'Enter New Admin Password',
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              SizedBox(height: 20),
              CupertinoButton(
                onPressed: () {
                  addAdmin(context, _email, _password);
                },
                color: CupertinoColors.systemGreen,
                child: Text('Add Admin', style: TextStyle(color: CupertinoColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddAdminTextField extends StatefulWidget {
  final Function(String) onChanged;
  final String placeholder;

  const AddAdminTextField({required this.onChanged, required this.placeholder});

  @override
  _AddAdminTextFieldState createState() => _AddAdminTextFieldState();
}

class _AddAdminTextFieldState extends State<AddAdminTextField> {
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _emailController,
      placeholder: widget.placeholder,
      onChanged: widget.onChanged,
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
      clearButtonMode: OverlayVisibilityMode.editing,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}