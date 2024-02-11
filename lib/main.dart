import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final CountdownController timerController =
      CountdownController(autoStart: false);

  List<String> board = List.filled(9, '');

  String currentPlayer = 'X';

  static const int remainingTime = 10;
  int xScore = 0;
  int oScore = 0;
  String? winner;

  late String status;
  late AnimationController animationController;
  double progress = 0;

  @override
  void initState() {
    super.initState();
    timerController.start();
    animationController = AnimationController(
        vsync: this, duration: const Duration(seconds: remainingTime));

    animationController.addListener(() {
      setState(() {
        progress = animationController.value;
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void switchPlayer() {
    if (currentPlayer == 'X') {
      currentPlayer = 'O';
    } else {
      currentPlayer = 'X';
    }
  }

  void onTap(int index) {
    if (board[index] == '' && winner == null) {
      setState(() {
        board[index] = currentPlayer;
        checkGameOver();
        if (winner == null) {
          switchPlayer();
          timerController.restart();
          animationController.reset();
          animationController.forward();
        }
      });
    }
  }

  void statusDialog(String status) async {
    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              insetPadding: const EdgeInsets.all(20),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              content: SizedBox(
                width: 200,
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            board.fillRange(0, 9, '');
                            timerController.restart();
                            animationController.reset();
                            animationController.forward();
                          });
                        },
                        icon: const Icon(
                          Icons.replay,
                          color: Colors.green,
                          size: 40,
                        )),
                    IconButton(
                        onPressed: () {
                          exit(0);
                        },
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: Colors.red,
                          size: 40,
                        ))
                  ],
                ),
              ),
            ));
  }

  void checkGameOver() {
    for (int i = 0; i < 9; i += 3) {
      if (board[i] != '' &&
          board[i] == board[i + 1] &&
          board[i] == board[i + 2]) {
        winner = board[i];
        winner == 'X' ? xScore++ : oScore++;
        status = 'Player $winner won';
        stopCounter();
        statusDialog(status);
        return;
      }
    }
    for (int i = 0; i < 3; i++) {
      if (board[i] != '' &&
          board[i] == board[i + 3] &&
          board[i] == board[i + 6]) {
        winner = board[i];
        winner == 'X' ? xScore++ : oScore++;

        status = 'Player $winner won';
        statusDialog(status);
        stopCounter();

        return;
      }
    }
    if (board[0] != '' && board[0] == board[4] && board[0] == board[8]) {
      winner = board[0];
      status = 'Player $winner won';
      statusDialog(status);
      winner == 'X' ? xScore++ : oScore++;
      stopCounter();
      return;
    }
    if (board[2] != '' && board[2] == board[4] && board[2] == board[6]) {
      winner = board[2];
      status = 'Player $winner won';
      statusDialog(status);
      winner == 'X' ? xScore++ : oScore++;
      stopCounter();
      return;
    }
    bool isFull = true;
    for (int i = 0; i < 9; i++) {
      if (board[i] == '') {
        isFull = false;
        break;
      }
    }
    if (isFull) {
      status = 'The game is a draw';
      statusDialog(status);
      stopCounter();
    }
  }

  void stopCounter() {
    timerController.pause();
    animationController.stop();
  }

  Widget buildCell(int index) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Text(
            board[index],
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      "Player O",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      oScore.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "Player X",
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      xScore.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1.3,
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) => buildCell(index),
            ),
            const SizedBox(
              height: 30,
            ),
            CustomPaint(
              painter: TimerWidget(progress),
              size: const Size(100, 100),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: Countdown(
                      onFinished: () {
                        setState(() {
                          currentPlayer == 'X' ? oScore++ : xScore++;
                        });
                        statusDialog(
                            'Time Out! \nPlayer ${currentPlayer == 'X' ? 'O' : 'X'
                                ''} '
                            'won');
                      },
                      controller: timerController,
                      seconds: 10,
                      build: (p0, p1) => Text(
                        p1.toString(),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TimerWidget extends CustomPainter {
  final double progress;

  TimerWidget(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    var radius = centerX;
    final Paint blankArea = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(Offset(centerX, centerY), radius, blankArea);

    final Paint mid = Paint()
      ..color = const Color.fromARGB(255, 248, 189, 0)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 12;
    canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        (3 * pi / 2),
        ((2 * pi) * progress),
        false,
        mid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
