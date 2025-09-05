import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  Map notifications = {
    'msg': [
      'UI/UX Designer',
      'UI/UX Designer',
      'UI/UX Designer',
      'UI/UX Designer',
      'UI/UX Designer',
    ],
    'week': [
      '1 week ago',
      '1 week ago',
      '1 week ago',
      '1 week ago',
      '1 week ago',
    ],
  };

  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      notifications['msg'].length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _animations = List.generate(
      notifications['msg'].length,
      (index) => Tween<Offset>(begin: Offset.zero, end: Offset(1.5, 0)).animate(
        CurvedAnimation(parent: _controllers[index], curve: Curves.easeInOut),
      ),
    );
  }

  void _slideAndRemove(int index) async {
    await _controllers[index].forward();
    setState(() {
      notifications['msg'].removeAt(index);
      notifications['week'].removeAt(index);
      _controllers.removeAt(index);
      _animations.removeAt(index);
    });
  }

  void _slideAllAndRemove() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(Duration(milliseconds: 100));
      _controllers[i].forward();
    }
    await Future.delayed(Duration(milliseconds: 400));
    setState(() {
      notifications['msg'].clear();
      notifications['week'].clear();
      _controllers.clear();
      _animations.clear();
    });
  }

  @override
  void didUpdateWidget(covariant NotificationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initAnimations();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Builder(
            builder: (context) => InkWell(
              onTap: () => Scaffold.of(context).openEndDrawer(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.blue,
                ),
                child: Image.asset(
                  'assets/notificationbutton.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      endDrawer: Drawer(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 72.0),
              child: ListView.builder(
                itemCount: notifications['msg'].length,
                itemBuilder: (context, index) {
                  return SlideTransition(
                    position: _animations[index],
                    child: Dismissible(
                      key: Key(notifications['msg'][index] + index.toString()),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        //_slideAndRemove(index);
                      },
                      movementDuration: const Duration(milliseconds: 400),
                      child: Card(
                        child: ListTile(
                          title: Text(notifications['msg'][index]),
                          subtitle: Text(notifications['week'][index]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                child: Text('Clear All'),
                onPressed: _slideAllAndRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
