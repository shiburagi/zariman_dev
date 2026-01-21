import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SnakeBackground extends StatefulWidget {
  final Color color;
  const SnakeBackground({Key? key, this.color = Colors.white})
    : super(key: key);

  @override
  State<SnakeBackground> createState() => _SnakeBackgroundState();
}

class _SnakeBackgroundState extends State<SnakeBackground> {
  // Snake state
  final List<Point<int>> _snake = [const Point(0, 0)];
  Point<int> _direction = const Point(1, 0);
  Point<int> _target = const Point(5, 5);

  // Grid configuration
  int _rows = 10;
  int _cols = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update snake position periodically
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) return;
      setState(() {
        _moveSnake();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _moveSnake() {
    if (_snake.isEmpty) return;

    final head = _snake.first;

    // Simple AI: Move towards target, but strictly on grid
    List<Point<int>> possibleMoves = [
      const Point(0, 1), // Down
      const Point(0, -1), // Up
      const Point(1, 0), // Right
      const Point(-1, 0), // Left
    ];

    // Filter out moves that immediately reverse direction
    possibleMoves = possibleMoves
        .where((m) => (m.x != -_direction.x || m.y != -_direction.y))
        .toList();

    // Pick best move towards target
    possibleMoves.sort((a, b) {
      final posA = Point(head.x + a.x, head.y + a.y);
      final posB = Point(head.x + b.x, head.y + b.y);
      final distA = _distance(posA, _target);
      final distB = _distance(posB, _target);
      return distA.compareTo(distB);
    });

    // Add some randomness so it's not robotic
    Point<int> move = possibleMoves.first;
    if (Random().nextDouble() < 0.2 && possibleMoves.length > 1) {
      move = possibleMoves[1];
    }

    _direction = move;

    // Calculate new head position wrapping around grid
    int newX = (head.x + move.x) % _cols;
    int newY = (head.y + move.y) % _rows;
    if (newX < 0) newX += _cols;
    if (newY < 0) newY += _rows;

    final newHead = Point(newX, newY);

    _snake.insert(0, newHead);
    if (_snake.length > 8) {
      _snake.removeLast();
    }

    // Move target if reached
    if (head == _target || Random().nextDouble() < 0.05) {
      _target = Point(Random().nextInt(_cols), Random().nextInt(_rows));
    }
  }

  double _distance(Point<int> a, Point<int> b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Recalculate grid size based on available space
        const double blockSize = 20.0;
        _cols = (constraints.maxWidth / blockSize).ceil();
        _rows = (constraints.maxHeight / blockSize).ceil();
        // Ensure minimum grid size
        if (_cols < 1) _cols = 1;
        if (_rows < 1) _rows = 1;

        return CustomPaint(
          painter: _SnakePainter(
            snake: _snake,
            target: _target,
            cols: _cols,
            rows: _rows,
            color: widget.color,
            blockSize: blockSize,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> target;
  final int cols;
  final int rows;
  final Color color;
  final double blockSize;

  _SnakePainter({
    required this.snake,
    required this.target,
    required this.cols,
    required this.rows,
    required this.color,
    required this.blockSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final snakePaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Draw grid dots
    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        canvas.drawCircle(
          Offset(i * blockSize + blockSize / 2, j * blockSize + blockSize / 2),
          2, // Small dot radius
          dotPaint,
        );
      }
    }

    // Draw snake body
    for (int i = 0; i < snake.length; i++) {
      final part = snake[i];
      // Skip if out of bounds (due to resize)
      if (part.x >= cols || part.y >= rows) continue;

      final opacity = 1.0 - (i / snake.length);
      snakePaint.color = color.withOpacity(0.4 * opacity + 0.2);

      canvas.drawCircle(
        Offset(
          part.x * blockSize + blockSize / 2,
          part.y * blockSize + blockSize / 2,
        ),
        4, // Snake body slightly larger
        snakePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SnakePainter oldDelegate) {
    return true; // Always repaint on tick
  }
}
