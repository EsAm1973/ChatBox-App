import 'dart:io';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/auth/manager/register/register_cubit.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_app_bar.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'User Created Successfully',
                  style: AppTextStyles.regular14,
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state is RegisterRollback) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Registration rolled back: ${state.errorMessage}',
                  style: AppTextStyles.regular14,
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is RegisterError) {
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
