import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const BoxBreathingApp());
}

class BoxBreathingApp extends StatelessWidget {
  const BoxBreathingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const BreathingScreen(),
    );
  }
}

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;
  
  String _instruction = "Ready?";
  int _counter = 4;
  Timer? _timer;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    // Using .chain(CurveTween) for smoother, more organic movement
    _sizeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0).chain(CurveTween(curve: Curves.easeInOutCubic)), weight: 25), 
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 25),                                          
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4).chain(CurveTween(curve: Curves.easeInOutCubic)), weight: 25), 
      TweenSequenceItem(tween: ConstantTween<double>(0.4), weight: 25),                                          
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0);
      }
    });
  }

  void _toggleBreathing() {
    setState(() {
      if (_isActive) {
        _isActive = false;
        _controller.stop();
        _timer?.cancel();
        _instruction = "Paused";
      } else {
        _isActive = true;
        _counter = 4;
        _controller.forward(from: 0);
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel(); // Safety clear
    _updateInstruction();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_counter > 1) {
          _counter--;
        } else {
          _counter = 4;
        }
        _updateInstruction();
      });
    });
  }

  void _updateInstruction() {
    double val = _controller.value;
    if (val < 0.25) _instruction = "Inhale";
    else if (val < 0.50) _instruction = "Hold";
    else if (val < 0.75) _instruction = "Exhale";
    else _instruction = "Hold";
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _instruction.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                letterSpacing: 4,
                fontWeight: FontWeight.w300,
                // Updated to new .withValues syntax
                color: Colors.cyanAccent.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isActive ? "$_counter" : "",
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w200),
            ),
            const SizedBox(height: 40),
            
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer decorative glow - Updated .withValues
                    Container(
                      width: 280 * _sizeAnimation.value,
                      height: 280 * _sizeAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                    ),
                    // Main breathing circle - Updated .withValues
                    Container(
                      width: 220 * _sizeAnimation.value,
                      height: 220 * _sizeAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.cyanAccent.withValues(alpha: 0.6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 100),
            
            ElevatedButton(
              onPressed: _toggleBreathing,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              ),
              child: Text(_isActive ? "STOP" : "START"),
            ),
          ],
        ),
      ),
    );
  }
}
