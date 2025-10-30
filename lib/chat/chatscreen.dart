import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:internappflutter/chat/fileshow.dart';
import 'package:video_player/video_player.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ScrollController _scrollController = ScrollController();
  late String chatId;

  bool _isUploadingFile = false;

  @override
  void initState() {
    super.initState();
    List<String> ids = [widget.currentUserId, widget.otherUserId];
    ids.sort();
    chatId = ids.join('_');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final picked = result.files.first;
        final filePath = picked.path!;
        final file = File(filePath);

        final mimeType = lookupMimeType(filePath) ?? '';

        print('📄 Picked file: ${picked.name}');
        print('📂 MIME type: $mimeType');
        print('📏 File size: ${(picked.size / 1024).toStringAsFixed(2)} KB');

        if (mimeType.startsWith('image/') || mimeType.startsWith('video/')) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Fileshow(
                file: file,
                currentUserId: widget.currentUserId,
                otherUserId: widget.otherUserId,
                chatId: chatId,
              ),
            ),
          );
        } else {
          print('Selected file is not image/video. Uploading file...');
          await _uploadAndSendFile(file, picked.name, mimeType);
        }
      } else {
        print('No file selected.');
      }
    } catch (e) {
      print('❌ Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadAndSendFile(
    File file,
    String fileName,
    String mimeType,
  ) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to send files'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploadingFile = true;
    });

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';
      final storageRef = _storage.ref().child(
        'chat_files/$chatId/$uniqueFileName',
      );

      print('📤 Uploading file: $uniqueFileName');

      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✅ File uploaded successfully: $downloadUrl');

      await _sendFileMessage(
        fileUrl: downloadUrl,
        fileName: fileName,
        mimeType: mimeType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      print('❌ Auth Error: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } on FirebaseException catch (e) {
      print('❌ Firebase Error: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print('❌ Error uploading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingFile = false;
      });
    }
  }

  Future<void> _sendFileMessage({
    required String fileUrl,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      // Determine type based on mime type
      String messageType = 'file';
      if (mimeType.startsWith('image/')) {
        messageType = 'image';
      } else if (mimeType.startsWith('video/')) {
        messageType = 'video';
      }

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'senderId': widget.currentUserId,
            'receiverId': widget.otherUserId,
            'message': fileUrl,
            'fileName': fileName,
            'mimeType': mimeType,
            'type': messageType,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

      String previewText = messageType == 'video'
          ? '🎥 $fileName'
          : messageType == 'image'
          ? '🖼️ $fileName'
          : '📎 $fileName';

      await _firestore.collection('chats').doc(chatId).set({
        'users': [widget.currentUserId, widget.otherUserId],
        'lastMessage': previewText,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _scrollToBottom();
      print('✅ File message sent to Firestore');
    } catch (e) {
      print('❌ Error sending file message: $e');
      rethrow;
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'senderId': widget.currentUserId,
            'receiverId': widget.otherUserId,
            'message': message,
            'type': 'text',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

      await _firestore.collection('chats').doc(chatId).set({
        'users': [widget.currentUserId, widget.otherUserId],
        'otherusername': widget.otherUserName,

        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error sending message: $e')));
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _markMessagesAsRead(List<QueryDocumentSnapshot> messages) async {
    for (var doc in messages) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['receiverId'] == widget.currentUserId &&
          data['isRead'] == false) {
        await doc.reference.update({'isRead': true});
      }
    }
  }

  void _showFullImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullVideo(String videoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFF7DD3C0),
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              widget.otherUserName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // or fade, clip
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,

                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        // actions: [
        //   Container(
        //     margin: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       border: Border.all(color: Colors.black, width: 2),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: IconButton(
        //       icon: const Icon(Icons.search, color: Colors.black),
        //       onPressed: () {},
        //       padding: EdgeInsets.zero,
        //     ),
        //   ),
        //   Container(
        //     margin: const EdgeInsets.all(8),
        //     decoration: BoxDecoration(
        //       border: Border.all(color: Colors.black, width: 2),
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: IconButton(
        //       icon: const Icon(Icons.more_vert, color: Colors.black),
        //       onPressed: () {},
        //       padding: EdgeInsets.zero,
        //     ),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                _markMessagesAsRead(messages);

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    final isMe = data['senderId'] == widget.currentUserId;
                    final message = data['message'] ?? '';
                    final messageType = data['type'] ?? 'text';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final fileName = data['fileName'];
                    final mimeType = data['mimeType'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildMessageBubble(
                        message: message,
                        isMe: isMe,
                        timestamp: timestamp,
                        type: messageType,
                        fileName: fileName,
                        mimeType: mimeType,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isMe,
    Timestamp? timestamp,
    String type = 'text',
    String? fileName,
    String? mimeType,
  }) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMe)
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF7DD3C0),
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),
        if (!isMe) const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (type == 'image' || type == 'video') ? 6 : 26,
                  vertical: (type == 'image' || type == 'video') ? 4 : 12,
                ),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFFE6D5F5) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isMe ? const Color(0xFFD4B5F0) : Colors.grey,
                    width: 1,
                  ),
                ),
                child: _buildMessageContent(
                  type: type,
                  message: message,
                  fileName: fileName,
                  mimeType: mimeType,
                ),
              ),
              if (timestamp != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: Text(
                    _formatTimestamp(timestamp),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
        if (isMe) const SizedBox(width: 8),
        if (isMe)
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFFFB4A8),
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),
      ],
    );
  }

  Widget _buildMessageContent({
    required String type,
    required String message,
    String? fileName,
    String? mimeType,
  }) {
    switch (type) {
      case 'image':
        return GestureDetector(
          onTap: () => _showFullImage(message),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              message,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 50, color: Colors.red),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

      case 'video':
        return GestureDetector(
          onTap: () => _showFullVideo(message),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: VideoThumbnail(videoUrl: message),
          ),
        );

      case 'file':
        return GestureDetector(
          onTap: () => _openFile(message, fileName ?? 'file'),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getFileIcon(mimeType), size: 32, color: Colors.blue),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName ?? 'File',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap to view',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case 'text':
      default:
        return Text(
          message,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        );
    }
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;

    if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description;
    } else if (mimeType.contains('excel') || mimeType.contains('spreadsheet')) {
      return Icons.table_chart;
    } else if (mimeType.contains('powerpoint') ||
        mimeType.contains('presentation')) {
      return Icons.slideshow;
    } else if (mimeType.contains('zip') || mimeType.contains('rar')) {
      return Icons.folder_zip;
    } else if (mimeType.contains('audio')) {
      return Icons.audio_file;
    } else if (mimeType.contains('video')) {
      return Icons.video_file;
    } else {
      return Icons.insert_drive_file;
    }
  }

  Future<void> _openFile(String fileUrl, String fileName) async {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: $fileName'),
              const SizedBox(height: 16),
              const Text('Options:'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Download functionality coming soon'),
                  ),
                );
              },
              child: const Text('Download'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          if (_isUploadingFile)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Uploading file...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.black),
                  onPressed: _isUploadingFile ? null : _pickFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isUploadingFile,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _isUploadingFile ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Video Thumbnail Widget
class VideoThumbnail extends StatelessWidget {
  final String videoUrl;

  const VideoThumbnail({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Full Video Player Screen
class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
      _controller.play();
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _hasError
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              )
            : !_isInitialized
            ? const CircularProgressIndicator(color: Colors.white)
            : AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            size: 80,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
