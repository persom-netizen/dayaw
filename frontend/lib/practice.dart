import 'package:flutter/material.dart';

void main() {
  runApp(MyPracticeApp());
}

class MyPracticeApp extends StatelessWidget {
  const MyPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // hides the "debug" label
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Practice App'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(
          child: CounterWidget(), // a custom widget below
        ),
      ),
    );
  }
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Hello, Dayaw!',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          'You pressed the button $count times.',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              count++;
            });
          },
          child: const Text('Press me'),
        ),
      ],
    );
  }
}
