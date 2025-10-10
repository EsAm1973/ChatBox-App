import 'package:chatbox/Core/widgets/custom_textfeild.dart';
import 'package:chatbox/Features/auth/data/mixins/auth_validator_mixin.dart';
import 'package:flutter/material.dart';

class RecoverPassEmailTextFeild extends StatelessWidget with AppValidators {
  const RecoverPassEmailTextFeild({super.key, required this.emailController});
  final TextEditingController emailController;
  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: emailController,
      labelText: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: validateEmail,
    );
  }
}
