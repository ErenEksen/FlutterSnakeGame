// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(485, 630),
    center: true,
    backgroundColor: Color.fromARGB(255, 0, 0, 0),
    skipTaskbar: true,
    title: "Snake Game"
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  final int rows = 20;
  final int columns = 20;
  final int speed = 300;
  bool readyToChangeDirection = true;
  Timer? timer;
  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> direction = const Point(0, -1);
  Point<int> food = const Point(15, 15);
  int score = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    timer?.cancel();
    timer = Timer.periodic(Duration(milliseconds: speed), (Timer timer) {
      setState(() {
        moveSnake();
      });
    });
  }

  void moveSnake() {
    final newHead = snake.first + direction;
    if (newHead == food) {
      snake.insert(0, newHead);
      score++;
      generateFood();
    } else if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= columns ||
        newHead.y >= rows ||
        snake.contains(newHead)) {
      timer?.cancel();
      showGameOverDialog();
    } else {
      snake.insert(0, newHead);
      snake.removeLast();
    }
    readyToChangeDirection = true;

  }

  void generateFood() {
    final random = Random();
    food = Point(random.nextInt(columns), random.nextInt(rows));
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score: $score'),
          actions: [
            TextButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  snake = [const Point(10, 10)];
                  direction = const Point(0, -1);
                  score = 0;
                  startGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void changeDirection(Point<int> newDirection) {
    if (direction + newDirection != const Point(0, 0)) {
      direction = newDirection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[900],
      appBar: AppBar(
        title: const Text('Snake Game'),
        backgroundColor: Colors.green[800],
      ),
      body: Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            switch (event.logicalKey.keyLabel) {
              case 'Arrow Up':
                if(readyToChangeDirection) changeDirection(const Point(0, -1));
                readyToChangeDirection = false;
                break;
              case 'Arrow Down':
                if(readyToChangeDirection) changeDirection(const Point(0, 1));
                readyToChangeDirection = false;
                break;
              case 'Arrow Left':
                if(readyToChangeDirection) changeDirection(const Point(-1, 0));
                readyToChangeDirection = false;
                break;
              case 'Arrow Right':
                if(readyToChangeDirection) changeDirection(const Point(1, 0));
                readyToChangeDirection = false;
                break;
            }
          }
          return KeyEventResult.handled;
        },
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final x = index % columns;
                  final y = index ~/ columns;
                  final point = Point(x, y);
                  final isSnakeBody = snake.contains(point);
                  final isFood = point == food;
                  return Container(
                    margin: const EdgeInsets.all(1.0),
                    decoration: BoxDecoration(
                      color: isSnakeBody
                          ? Colors.green[400]
                          : (isFood ? Colors.red : Colors.black),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  );
                },
                itemCount: rows * columns,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Score: $score', style: const TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
