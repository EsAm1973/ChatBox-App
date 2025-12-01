import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

// Additional imports required for handleNotification
import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/service/getit_service.dart';
import 'package:chatbox/Core/utils/app_router.dart'; // Assuming AppRouter is where kChatScreenRoute is defined
// Removed chat_view.dart as it's not directly used for navigation but the route.

Future<String> getAccessToken() async {
  final jsonString = await rootBundle.loadString(
    'assets/notification_key/chatbox-ee37f-6e3c33e943d5.json',
  );

  final accountCredentials = auth.ServiceAccountCredentials.fromJson(
    jsonString,
  );

  final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

  return client.credentials.accessToken.data;
}

Future<void> sendNotification({
  required String token,
  required String title,
  required String body,
  required Map<String, String> data,
}) async {
  log('Sending notification...');
  log('Token: $token');
  log('Title: $title');
  log('Body: $body');
  log('Data: $data');

  try {
    final String accessToken = await getAccessToken();
    final String fcmUrl =
        'https://fcm.googleapis.com/v1/projects/chatbox-ee37f/messages:send';

    final response = await http.post(
      Uri.parse(fcmUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'message': {
          'token': token,
          'notification': {'title': title, 'body': body},
          'data': data, // Add custom data here

          'android': {
            'notification': {
              "sound": "custom_sound",
              'click_action':
                  'FLUTTER_NOTIFICATION_CLICK', // Required for tapping to trigger response
              'channel_id': 'high_importance_channel',
            },
          },
          'apns': {
            'payload': {
              'aps': {"sound": "custom_sound.caf", 'content-available': 1},
            },
          },
        },
      }),
    );

    if (response.statusCode == 200) {
      log('Notification sent successfully');
    } else {
      log('Failed to send notification. Status code: ${response.statusCode}');
      log('Response body: ${response.body}');
    }
  } catch (e) {
    log('Error sending notification: $e');
  }
}

void handleNotification(BuildContext context, Map<String, dynamic> data) async {
  log('Handling notification with data: $data');

  // Ensure data contains the necessary fields
  if (data['route'] == AppRouter.kChatScreenRoute && data['senderId'] != null) {
    final senderId = data['senderId'] as String;

    try {
      // Use getIt to get an instance of UserRepo
      final userRepo = getIt<UserRepo>();

      // Fetch the user data for the sender
      final userResult = await userRepo.getUserData(senderId);

      userResult.fold(
        (failure) {
          log(
            'Failed to get user data for notification: ${failure.errorMessage}',
          );
        },
        (user) {
          // Navigate to the chat screen with the sender's UserModel
          // Ensure the context is mounted before navigating
          if (context.mounted) {
            context.push(AppRouter.kChatScreenRoute, extra: user);
          }
        },
      );
    } catch (e) {
      log('Error handling notification navigation: $e');
    }
  } else {
    log('Notification data is not in the expected format for chat navigation.');
  }
}
