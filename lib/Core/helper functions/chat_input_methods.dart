import 'package:chatbox/Core/service/file_picker_service.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/voice_recorder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInputMethods {
  // Send text message
  static void sendMessage({
    required BuildContext context,
    required TextEditingController messageController,
    required String receiverId,
  }) {
    if (messageController.text.trim().isEmpty) return;

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: FirebaseAuth.instance.currentUser!.uid,
      receiverId: receiverId,
      content: messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
      type: MessageType.text,
    );

    context.read<ChatCubit>().sendMessage(message);
    messageController.clear();
  }

  // Send voice message
  static void sendVoiceMessage({
    required BuildContext context,
    required File voiceFile,
    required String receiverId,
    required int duration,
    required Function(bool) updateRecordingState,
  }) {
    context.read<ChatCubit>().sendVoiceMessage(
      voiceFile: voiceFile,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      receiverId: receiverId,
      duration: duration,
    );

    updateRecordingState(false);
  }

  // Send image attachment
  static void sendImageAttachment({
    required BuildContext context,
    required File imageFile,
    required String receiverId,
  }) {
    context.read<ChatCubit>().sendImageAttachment(
      imageFile: imageFile,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      receiverId: receiverId,
    );
  }

  // Send file attachment
  static void sendFileAttachment({
    required BuildContext context,
    required File file,
    required String receiverId,
  }) {
    context.read<ChatCubit>().sendFileAttachment(
      file: file,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      receiverId: receiverId,
    );
  }

  // Show attachment menu
  static void showAttachmentMenu({
    required BuildContext context,
    required VoidCallback onPickImage,
    required VoidCallback onTakePhoto,
    required VoidCallback onPickFile,
  }) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.photo,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: const Text('Select Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickImage();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    onTakePhoto();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.attach_file,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: const Text('Select File'),
                  onTap: () {
                    Navigator.pop(context);
                    onPickFile();
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Pick and send image
  static Future<void> pickAndSendImage({
    required BuildContext context,
    required String receiverId,
  }) async {
    final files = await FilePickerService.pickImages();
    if (files != null && files.isNotEmpty) {
      final file = files.first;
      sendImageAttachment(
        // ignore: use_build_context_synchronously
        context: context,
        imageFile: file,
        receiverId: receiverId,
      );
    }
  }

  // Take and send photo
  static Future<void> takeAndSendPhoto({
    required BuildContext context,
    required String receiverId,
  }) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (photo != null) {
      final file = File(photo.path);
      sendImageAttachment(
        // ignore: use_build_context_synchronously
        context: context,
        imageFile: file,
        receiverId: receiverId,
      );
    }
  }

  // Pick and send file
  static Future<void> pickAndSendFile({
    required BuildContext context,
    required String receiverId,
  }) async {
    final files = await FilePickerService.pickFiles();
    if (files != null && files.isNotEmpty) {
      final file = files.first;
      sendFileAttachment(
        // ignore: use_build_context_synchronously
        context: context,
        file: file,
        receiverId: receiverId,
      );
    }
  }

  // Build chat input widget
  static Widget buildChatInput({
    required BuildContext context,
    required TextEditingController messageController,
    required bool isRecording,
    required bool isSending,
    required String receiverId,
    required Function(bool) updateRecordingState,
    required VoidCallback onTextChanged, // أضف هذا الباراميتر
  }) {
    if (isRecording) {
      return VoiceRecorderWidget(
        onVoiceRecorded: (voiceFile, duration) {
          sendVoiceMessage(
            context: context,
            voiceFile: voiceFile,
            receiverId: receiverId,
            updateRecordingState: updateRecordingState,
            duration: duration,
          );
        },
        onCancel: () {
          updateRecordingState(false);
        },
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 8.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.attachment,
              color: Theme.of(context).iconTheme.color,
              size: 28.r,
            ),
            onPressed:
                isSending
                    ? null
                    : () {
                      showAttachmentMenu(
                        context: context,
                        onPickImage:
                            () => pickAndSendImage(
                              context: context,
                              receiverId: receiverId,
                            ),
                        onTakePhoto:
                            () => takeAndSendPhoto(
                              context: context,
                              receiverId: receiverId,
                            ),
                        onPickFile:
                            () => pickAndSendFile(
                              context: context,
                              receiverId: receiverId,
                            ),
                      );
                    },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30.0.r),
              ),
              child: TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: 'Write your message',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.0.h,
                    horizontal: 20.0.w,
                  ),
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                onSubmitted:
                    isSending
                        ? null
                        : (_) => sendMessage(
                          context: context,
                          messageController: messageController,
                          receiverId: receiverId,
                        ),
                enabled: !isSending,
                onChanged: (value) {
                  onTextChanged(); // أضف هذا السطر
                },
              ),
            ),
          ),

          // Microphone or Send button
          if (messageController.text.trim().isEmpty)
            IconButton(
              icon: Icon(
                Icons.mic_none_outlined,
                color: Theme.of(context).iconTheme.color,
                size: 28.r,
              ),
              onPressed:
                  isSending
                      ? null
                      : () {
                        updateRecordingState(true);
                      },
            )
          else
            isSending
                ? Padding(
                  padding: EdgeInsets.all(8.0.r),
                  child: SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                : IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).iconTheme.color,
                    size: 28.r,
                  ),
                  onPressed:
                      () => sendMessage(
                        context: context,
                        messageController: messageController,
                        receiverId: receiverId,
                      ),
                ),
        ],
      ),
    );
  }
}
