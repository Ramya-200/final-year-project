import 'package:flutter/material.dart';

import 'config.dart';

import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/parent_screen.dart';
import 'screens/bank_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/change_password.dart';
import 'screens/add_academic_details.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/admin/add_admin_screen.dart';
import 'screens/admin/view_admins_screen.dart';
import 'screens/admin/search_user_screen.dart';
import 'screens/admin/view_users_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Details',
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/signIn': (_) => SignInScreen(),
        '/signUp': (_) => SignUpScreen(),
        '/forgotPassword': (_) => ForgotPasswordScreen(),
        '/home': (_) => HomeScreen(),
        '/profile': (_) => ProfileScreen(),
        '/profile/parent': (_) => ParentScreen(),
        '/profile/bank': (_) => BankScreen(),
        '/profile/contact': (_) => ContactScreen(),
        '/profile/changePassword': (_) => ChangePasswordScreen(),
        '/addAcademicDetails': (_) => AcademicDetailsScreen(),
        '/admin': (_) => AdminPage(),
        '/admin/add': (_) => AddAdminPage(),
        '/admin/view': (_) => ViewAdminsPage(),
        '/admin/search': (_) => SearchUserByEmailPage(),
        '/admin/allusers': (_) => ViewAllUsersPage(),
      },
      onGenerateRoute: generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    default:
      return MaterialPageRoute(
          builder: (_) => SplashScreen()
        );
  }
}