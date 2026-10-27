import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Typing Speed Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TypingSpeedTestScreen(),
    );
  }
}

class TypingSpeedTestScreen extends StatefulWidget {
  const TypingSpeedTestScreen({super.key});

  @override
  State<TypingSpeedTestScreen> createState() => _TypingSpeedTestScreenState();
}

class _TypingSpeedTestScreenState extends State<TypingSpeedTestScreen> {
  final TextEditingController _textController = TextEditingController();
  String _currentText = '';
  String _typedText = '';
  int _correctChars = 0;
  int _incorrectChars = 0;
  int _timerSeconds = 60;
  Timer? _timer;
  bool _isPlaying = false;
  List<String> _quotes = [
    "The quick brown fox jumps over the lazy dog.",
    "Never underestimate the power of a good book.",
    "The early bird catches the worm.",
    "Practice makes perfect.",
    "Innovation distinguishes between a leader and a follower.",
    "The only way to do great work is to love what you do.",
    "Believe you can and you're halfway there.",
    "The future belongs to those who believe in the beauty of their dreams.",
    "Strive not to be a success, but rather to be of value.",
    "The mind is everything. What you think you become.",
  ];

  @override
  void initState() {
    super.initState();
    _generateNewText();
  }

  void _generateNewText() {
    final random = Random();
    _currentText = _quotes[random.nextInt(_quotes.length)];
    _typedText = '';
    _textController.clear();
    _correctChars = 0;
    _incorrectChars = 0;
    _timerSeconds = 60;
    _isPlaying = false;
    _timer?.cancel();
    setState(() {});
  }

  void _startTest() {
    _generateNewText();
    _isPlaying = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timer?.cancel();
          _isPlaying = false;
          _showResultDialog();
        }
      });
    });
  }

  void _onTextChanged(String newText) {
    if (!_isPlaying) {
      _startTest();
    }
    setState(() {
      _typedText = newText;
      _correctChars = 0;
      _incorrectChars = 0;
      for (int i = 0; i < _typedText.length; i++) {
        if (i < _currentText.length && _typedText[i] == _currentText[i]) {
          _correctChars++;
        } else {
          _incorrectChars++;
        }
      }
      if (_typedText.length == _currentText.length &&
          _correctChars == _currentText.length) {
        _timer?.cancel();
        _isPlaying = false;
        _showResultDialog();
      }
    });
  }

  int _calculateWPM() {
    if (_timerSeconds == 60) return 0;
    final timeElapsed = 60 - _timerSeconds;
    final wordsTyped = _correctChars / 5; // Average word length is 5 characters
    return ((wordsTyped / timeElapsed) * 60).round();
  }

  double _calculateAccuracy() {
    if (_typedText.isEmpty) return 0.0;
    return (_correctChars / _typedText.length) * 100;
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Test Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Words Per Minute (WPM): ${_calculateWPM()}'),
              Text('Accuracy: ${_calculateAccuracy().toStringAsFixed(2)}%'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _generateNewText();
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Typing Speed Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Time: $_timerSeconds s',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: RichText(
                text: TextSpan(
                  children: List.generate(_currentText.length, (index) {
                    TextStyle style = const TextStyle(
                      fontSize: 22,
                      color: Colors.grey,
                    );
                    if (index < _typedText.length) {
                      if (_typedText[index] == _currentText[index]) {
                        style = const TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                        );
                      } else {
                        style = const TextStyle(
                          fontSize: 22,
                          color: Colors.red,
                        );
                      }
                    }
                    return TextSpan(text: _currentText[index], style: style);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              onChanged: _onTextChanged,
              enabled: _isPlaying,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Start typing here...',
              ),
              style: const TextStyle(fontSize: 20),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isPlaying ? null : _startTest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: Text(_isPlaying ? 'Typing...' : 'Start Test'),
            ),
            const SizedBox(height: 20),
            Text(
              'WPM: ${_calculateWPM()}',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            Text(
              'Accuracy: ${_calculateAccuracy().toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
