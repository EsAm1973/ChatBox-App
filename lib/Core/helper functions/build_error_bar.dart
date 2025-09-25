import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

void buildErrorBar(BuildContext context, String stateErrrorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          stateErrrorMessage,
          style: AppTextStyles.regular14,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }