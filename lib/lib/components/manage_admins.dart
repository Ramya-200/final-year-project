import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '/utils/helpers.dart';
import '/utils/showModal.dart';

import 'package:supabase/supabase.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

void addAdmin(BuildContext context, String email, String password) {
  if (email == '' || password == '') {
    showModal('Error', 'Please Enter an Email and Password', context);
    return;
  }
  if (validateEmail(email) == null) {
    Supabase.instance.client.auth
        .signUp(email, password,
            options: supabase.AuthOptions(redirectTo: authRedirectUri))
        .then((response) {
      if (response.error == null) {
        Supabase.instance.client
            .from('admins')
            .insert({
              'email': email,
              'id': response.data!.user!.id,
            })
            .execute()
            .then((response) {
              if (response.error == null) {
                showModal('Success', '$email is Now an Admin', context);
              } else {
                showModal('Error', '${response.error!.message}', context);
              }
            });
      } else {
        showModal('Error', '${response.error!.message}', context);
      }
    });
  } else {
    showModal('Invalid Email', "Email Address Format is Invalid", context);
  }
}

void removeAdmin(BuildContext context, String email) {
  if (validateEmail(email) == null) {
    Supabase.instance.client
        .from('admins')
        .select('id')
        .eq('email', email)
        .execute()
        .then((response) {
      if (response.error == null) {
        final url =
            'https://tkllusqoyiedlkxpoiwu.supabase.co/functions/v1/deleteuser';
        final headers = {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRrbGx1c3FveWllZGxreHBvaXd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTAyMTExOTksImV4cCI6MjAwNTc4NzE5OX0.0PxJfq6fXqTRk5WrzzTzlJoHXFSMZasXjm8TaVyQCf4',
          'Content-Type': 'application/json'
        };
        final data = {'name': 'Functions', 'user_id': response.data![0]['id']};

        http
            .post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(data),
        )
            .then((value) {
          if (value.statusCode == 200) {
            showModal('Success', '$email is No Longer an Admin', context);
          } else {
            showModal('Error', 'Failed to Remove $email as Admin', context);
          }
        });
      } else {
        showModal('Error', 'Failed to Remove $email as Admin', context);
      }
    });

    // Supabase.instance.client
    //     .from('admins')
    //     .delete()
    //     .match({'email': email})
    //     .execute()
    //     .then((response) {
    //       if (response.error == null) {
    //         showModal('Success', '$email is No Longer an Admin', context);
    //       } else {
    //         showModal('Error', 'Failed to Remove $email as Admin', context);
    //       }
    //     });
  } else {
    showModal('Error', "Invalid Email Address Format", context);
  }
}