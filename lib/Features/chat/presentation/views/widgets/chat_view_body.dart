import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/chat_appbar.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/chat_input.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/message_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({super.key, required this.otherUser});
  final UserModel otherUser;

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  late String _chatId;
  late String _currentUserId;
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = true;

  // متغيرات جديدة لإدارة حالة التمرير
  double? _savedScrollPosition;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<UserCubit>().getCurrentUser()!.uid;
    _chatId = _generateChatRoomId(_currentUserId, widget.otherUser.uid);

    // Initialize chat
    context.read<ChatCubit>().initializeChat(
      _currentUserId,
      widget.otherUser.uid,
    );

    _scrollController.addListener(_onScroll);

    // Display latest message immediately without animation when opening chat
    _scheduleInitialScroll();
  }

  void _scheduleInitialScroll() {
    // انتظار للتأكد من تحميل الرسائل بالكامل
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _displayLatestMessageImmediately();
        _markMessagesAsSeen();
      }
    });
  }

  @override
  void dispose() {
    // حفظ موقع التمرير قبل إغلاق الشاشة
    if (_scrollController.hasClients) {
      _savedScrollPosition = _scrollController.position.pixels;
    }

    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Mark all messages as seen when leaving
    _markMessagesAsSeen();
    super.dispose();
  }

  void _onScroll() {
    // حفظ موقع التمرير الحالي عند بدء التمرير
    if (_scrollController.hasClients) {
      _savedScrollPosition = _scrollController.position.pixels;
    }

    final isAtBottom =
        _scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 50;

    if (isAtBottom != _isAtBottom) {
      _isAtBottom = isAtBottom;
      if (_isAtBottom) {
        _markMessagesAsSeen();
      }
    }
  }

  String _generateChatRoomId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return 'chat_${sortedIds[0]}_${sortedIds[1]}';
  }

  void _displayLatestMessageImmediately() {
    if (!_scrollController.hasClients) return;

    // استرداد الموقع المحفوظ إذا كان موجوداً
    if (_savedScrollPosition != null && !_isFirstLoad) {
      _scrollController.jumpTo(_savedScrollPosition!);
    } else {
      // عرض آخر رسالة فوراً دون انيميشن
      _jumpToBottomForce();
    }

    _isFirstLoad = false;
  }

  void _jumpToBottomForce() {
    if (!_scrollController.hasClients) return;

    // استخدم animateTo مع margin إضافي للتأكد من الوصول لآخر رسالة
    final targetPosition = _scrollController.position.maxScrollExtent + 200.0;
    _scrollController.animateTo(
      targetPosition,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );

    // محاولة ثانية للتأكد
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 250.0,
          duration: const Duration(milliseconds: 50),
          curve: Curves.linear,
        );
      }
    });
  }

  void _markMessagesAsSeen() {
    context.read<ChatCubit>().markMessagesAsSeen(_chatId, _currentUserId);
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        if (state is MessagesLoaded ||
            state is MessageSent ||
            state is MessageSending) {
          final messages =
              (state is MessagesLoaded)
                  ? state.messages
                  : (state is MessageSent
                      ? state.messages
                      : (state as MessageSending).messages);

          // Auto-scroll to bottom when new messages are added and user was at bottom
          if (state is MessagesLoaded && _isAtBottom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom(animated: true);
            });
          }

          return Column(
            children: [
              // ✅ ChatAppBar with call buttons
              ChatAppBar(otherUser: widget.otherUser),
              Expanded(
                child: MessageList(
                  messages: messages,
                  scrollController: _scrollController,
                ),
              ),
              ChatInput(otherUser: widget.otherUser),
            ],
          );
        } else if (state is ChatLoading) {
          return Column(
            children: [
              ChatAppBar(otherUser: widget.otherUser),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        } else if (state is ChatError) {
          return Column(
            children: [
              ChatAppBar(otherUser: widget.otherUser),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.error}'),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChatCubit>().initializeChat(
                            _currentUserId,
                            widget.otherUser.uid,
                          );
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              ChatAppBar(otherUser: widget.otherUser),
              const Expanded(child: Center(child: CircularProgressIndicator())),
            ],
          );
        }
      },
    );
  }
}
