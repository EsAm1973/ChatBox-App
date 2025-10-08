import 'dart:io';

import 'package:chatbox/Core/widgets/custom_bottom.dart';
import 'package:chatbox/Features/auth/presentation/manager/register/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChoosePictureFinishButton extends StatelessWidget {
  final File? selectedImage;
  final String name;
  final String email;
  final String password;

  const ChoosePictureFinishButton({
    super.key,
    required this.selectedImage,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        if (state is RegisterLoading) {
          return const CircularProgressIndicator();
        }
        return CustomBottom(
          text: 'Finish Creating Account',
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
          onTap: () {
            if (selectedImage != null) {
              context.read<RegisterCubit>().registerUser(
                name: name,
                email: email,
                password: password,
                imageFile: selectedImage!,
              );
            }
          },
        );
      },
    );
  }
}