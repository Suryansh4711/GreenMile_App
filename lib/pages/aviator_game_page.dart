import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class AviatorGamePage extends StatefulWidget {
  const AviatorGamePage({super.key});

  @override
  State<AviatorGamePage> createState() => _AviatorGamePageState();
}

class _AviatorGamePageState extends State<AviatorGamePage> with SingleTickerProviderStateMixin {
  double _multiplier = 1.00;
  double _crashPoint = 0.0;
  bool _isPlaying = false;
  bool _hasCrashed = false;
  double _betAmount = 10.0;
  double _balance = 1000.0;
  Timer? _timer;
  late AnimationController _planeController;
  late Animation<double> _curveAnimation;

  @override
  void initState() {
    super.initState();
    _planeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _curveAnimation = CurvedAnimation(
      parent: _planeController,
      curve: Curves.easeOutQuad,
    );
  }

  void _startGame() {
    if (_betAmount > _balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient balance!')),
      );
      return;
    }

    setState(() {
      _balance -= _betAmount;
      _multiplier = 1.00;
      _hasCrashed = false;
      _isPlaying = true;
      _crashPoint = Random().nextDouble() * 5 + 1.5;
    });

    _planeController.reset();
    _planeController.forward();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _multiplier += 0.01;
        if (_multiplier >= _crashPoint) {
          _crash();
        }
      });
    });
  }

  void _crash() {
    _timer?.cancel();
    _planeController.reverse();
    setState(() {
      _isPlaying = false;
      _hasCrashed = true;
    });
  }

  void _cashOut() {
    if (_isPlaying && !_hasCrashed) {
      _timer?.cancel();
      setState(() {
        _isPlaying = false;
        _balance += _betAmount * _multiplier;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B1F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Balance: \$${_balance.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {/* Show history */},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomPaint(
              painter: _FlightPathPainter(
                progress: _curveAnimation.value,
                crashed: _hasCrashed,
                multiplier: _multiplier,
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      '${_multiplier.toStringAsFixed(2)}x',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: _hasCrashed ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _curveAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: MediaQuery.of(context).size.width * 0.1 +
                            (MediaQuery.of(context).size.width * 0.8 * _curveAnimation.value),
                        top: MediaQuery.of(context).size.height * 0.5 -
                            (sin(pi * _curveAnimation.value) * 200),
                        child: Transform.rotate(
                          angle: pi / 8,
                          child: const Icon(
                            Icons.airplanemode_active,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Bet Amount',
                          prefixText: '\$',
                          filled: true,
                          fillColor: Colors.black12,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _betAmount = double.tryParse(value) ?? _betAmount;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isPlaying ? _cashOut : _startGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPlaying ? Colors.orange : Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        _isPlaying ? 'CASH OUT' : 'BET',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _planeController.dispose();
    super.dispose();
  }
}

class _FlightPathPainter extends CustomPainter {
  final double progress;
  final bool crashed;
  final double multiplier;

  _FlightPathPainter({
    required this.progress,
    required this.crashed,
    required this.multiplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = crashed ? Colors.red : Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.5);

    for (double i = 0; i <= progress; i += 0.01) {
      path.lineTo(
        size.width * 0.1 + (size.width * 0.8 * i),
        size.height * 0.5 - (sin(pi * i) * 200),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
