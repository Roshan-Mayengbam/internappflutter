import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internappflutter/chat/chatscreen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.black),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFD4B5FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Filter Buttons
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('Featured', true),
                  const SizedBox(width: 12),
                  _buildFilterChip('Live', false),
                  const SizedBox(width: 12),
                  _buildFilterChip('Upcoming', false),
                  const SizedBox(width: 12),
                  _buildFilterChip('Always Open', false),
                  const SizedBox(width: 12),
                  _buildFilterChip('Active', false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Chat List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chats')
                    .where('users', arrayContains: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No chats yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // Sort chats by lastMessageTime
                  final chatDocs = snapshot.data!.docs.toList();
                  chatDocs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['lastMessageTime'] as Timestamp?;
                    final bTime = bData['lastMessageTime'] as Timestamp?;

                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;

                    return bTime.compareTo(aTime);
                  });

                  // Apply search filter
                  final filteredChats = chatDocs.where((doc) {
                    if (searchQuery.isEmpty) return true;
                    final chatData = doc.data() as Map<String, dynamic>;
                    final otherUserName = chatData['otherusername'] ?? '';
                    return otherUserName.toLowerCase().contains(searchQuery);
                  }).toList();

                  if (filteredChats.isEmpty) {
                    return const Center(
                      child: Text(
                        'No chats found',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredChats.length,
                    itemBuilder: (context, index) {
                      final chatDoc = filteredChats[index];
                      final chatData = chatDoc.data() as Map<String, dynamic>;
                      final chatId = chatDoc.id;

                      // Extract other user ID from chat ID
                      final otherUserId = _getOtherUserId(chatId);
                      final otherUserName =
                          chatData['otherusername'] ?? 'Unknown User';
                      final lastMessage =
                          chatData['lastMessage'] ?? 'No messages yet';
                      final lastMessageTime =
                          chatData['lastMessageTime'] as Timestamp?;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildChatCard(
                          chatId: chatId,
                          userName: otherUserName,
                          otherUserId: otherUserId,
                          lastMessage: lastMessage,
                          lastMessageTime: lastMessageTime,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getOtherUserId(String chatId) {
    // Chat ID format: senderId_receiverId
    final parts = chatId.split('_');
    if (parts.length == 2) {
      return parts[0] == currentUserId ? parts[1] : parts[0];
    }
    return '';
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD4FF6B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildChatCard({
    required String chatId,
    required String userName,
    required String otherUserId,
    required String lastMessage,
    required Timestamp? lastMessageTime,
  }) {
    // Format timestamp
    String formattedTime = '';
    if (lastMessageTime != null) {
      final timestamp = lastMessageTime.toDate();
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays == 0) {
        formattedTime =
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        formattedTime = 'Yesterday';
      } else if (difference.inDays < 7) {
        formattedTime = '${difference.inDays}d ago';
      } else {
        formattedTime = '${timestamp.day}/${timestamp.month}';
      }
    }

    // Truncate long messages
    String displayMessage = lastMessage;
    if (displayMessage.length > 30) {
      displayMessage = '${displayMessage.substring(0, 30)}...';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              otherUserId: otherUserId,
              otherUserName: userName,
              currentUserId: currentUserId,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B4FC4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Chat Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayMessage,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Time
              if (formattedTime.isNotEmpty)
                Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
