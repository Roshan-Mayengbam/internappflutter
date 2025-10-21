import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';

class Fileshow extends StatefulWidget {
  final File file;
  final String currentUserId;
  final String otherUserId;
  final String chatId;

  const Fileshow({
    super.key,
    required this.file,
    required this.currentUserId,
    required this.otherUserId,
    required this.chatId,
  });

  @override
  State<Fileshow> createState() => _FileshowState();
}

class _FileshowState extends State<Fileshow> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  late String _mimeType;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _mimeType = lookupMimeType(widget.file.path) ?? '';

    // If it's a video, initialize video player
    if (_mimeType.startsWith('video/')) {
      _videoController = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _uploadAndSendFile() async {
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(widget.file.path)}';
      final storagePath = _mimeType.startsWith('video/')
          ? 'chat_videos/${widget.chatId}/$fileName'
          : 'chat_images/${widget.chatId}/$fileName';
      final storageRef = _storage.ref().child(storagePath);

      final uploadTask = storageRef.putFile(widget.file);

      uploadTask.snapshotEvents.listen((snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _sendFileMessage(downloadUrl, fileName);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_mimeType.startsWith('video/') ? 'Video' : 'Image'} sent successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error uploading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  Future<void> _sendFileMessage(String fileUrl, String fileName) async {
    final type = _mimeType.startsWith('video/') ? 'video' : 'image';
    try {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
            'senderId': widget.currentUserId,
            'receiverId': widget.otherUserId,
            'message': fileUrl,
            'fileName': fileName,
            'type': type,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
          });

      await _firestore.collection('chats').doc(widget.chatId).set({
        'users': [widget.currentUserId, widget.otherUserId],
        'lastMessage': type == 'video' ? '🎥 Video' : '📷 Image',
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Firestore error: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = _mimeType.startsWith('video/');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isVideo ? 'Preview Video' : 'Preview Image',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: isVideo
                ? _videoController != null &&
                          _videoController!.value.isInitialized
                      ? AspectRatio(
                          aspectRatio: _videoController!.value.aspectRatio,
                          child: VideoPlayer(_videoController!),
                        )
                      : const CircularProgressIndicator(color: Colors.white)
                : Image.file(widget.file, fit: BoxFit.contain),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _uploadProgress,
                      color: Colors.white,
                      strokeWidth: 6,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _isUploading
          ? null
          : FloatingActionButton.extended(
              onPressed: _uploadAndSendFile,
              backgroundColor: Colors.blue,
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text('Send', style: TextStyle(color: Colors.white)),
            ),
    );
  }
}
