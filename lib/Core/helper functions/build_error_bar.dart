import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/auth/manager/register/register_cubit.dart';
import 'package:flutter/material.dart';

void buildErrorBar(BuildContext context, RegisterError state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.errorMessage,
          style: AppTextStyles.regular14,
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }