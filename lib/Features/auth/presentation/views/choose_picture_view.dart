import 'dart:io';
import 'package:chatbox/Core/helper%20functions/animated_error_dialog.dart';
import 'package:chatbox/Core/helper%20functions/animated_success_dialog.dart';
import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Features/auth/presentation/manager/register/register_cubit.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_app_bar.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ChoosePictureScreen extends StatefulWidget {
  const ChoosePictureScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  State<ChoosePictureScreen> createState() => _ChoosePictureScreenState();
}

class _ChoosePictureScreenState extends State<ChoosePictureScreen> {
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChoosePictureAppBar(),
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterEmailVerificationSent) {
            openSuccessAnimatedDialog(
              context,
              'success',
              'Welcome aboard!',
              'Your account was created successfully. We’ve sent a verification email to your inbox — please click the link to confirm your account and start chatting with your contacts',
              'Go to Login',
              (context) =>
                  GoRouter.of(context).pushReplacement(AppRouter.kLoginRoute),
            );
          } else if (state is RegisterError) {
            openErrorAnimatedDialog(
              context,
              'Error',
              'Error in register',
              state.errorMessage,
              'Ok',
              (context) {},
            );
          }
        },
        child: ChoosePictureViewBody(
          selectedImage: _selectedImage,
          onPickImage: _pickImage,
          name: widget.name,
          email: widget.email,
          password: widget.password,
        ),
      ),
    );
  }
}
