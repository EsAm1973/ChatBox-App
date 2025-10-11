class ChatMessage {
  final String name;
  final String lastMessage;
  final String time;
  final String avatarUrl;
  final bool isOnline;
  final int unreadCount;

  ChatMessage({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarUrl,
    this.isOnline = false,
    this.unreadCount = 0, // Default to 0
  });
}

// Mock data to display in the list
final List<ChatMessage> mockChats = [
  ChatMessage(
    name: "John Ahraham",
    lastMessage: "Hey! Can you join the meeting?",
    time: "2 min ago",
    avatarUrl: "assets/user_pic_test.png",
    isOnline: true,
    unreadCount: 0, // No unread
  ),
  ChatMessage(
    name: "Sabila Sayma",
    lastMessage: "How are you today?",
    time: "5 min ago",
    avatarUrl: "assets/user_pic_test.png",
    isOnline: false,
    unreadCount: 4, // 4 unread messages, like in your image
  ),
  ChatMessage(
    name: "David Smith",
    lastMessage: "I finished the report.",
    time: "1 hr ago",
    avatarUrl: "assets/user_pic_test.png",
    isOnline: true,
    unreadCount: 1, // 1 unread
  ),
  ChatMessage(
    name: "Aisha Mohammed",
    lastMessage: "Okay, sounds good.",
    time: "Yesterday",
    avatarUrl: "assets/user_pic_test.png",
    isOnline: false,
    unreadCount: 0,
  ),
];
