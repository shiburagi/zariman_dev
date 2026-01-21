import 'dart:math';
import 'package:flutter/material.dart';

class TetrisBackground extends StatefulWidget {
  const TetrisBackground({Key? key}) : super(key: key);

  @override
  State<TetrisBackground> createState() => _TetrisBackgroundState();
}

class _TetrisBackgroundState extends State<TetrisBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Only one piece active at a time
  _FallingPiece? _currentPiece;

  // Track grid width for centering
  int _gridCols = 15;

  @override
  void initState() {
    super.initState();
    // Use controller as a game loop driver
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updateGame);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateGame() {
    // 1. Spawn Logic: Only if no current piece
    if (_currentPiece == null) {
      _spawnPiece();
      return;
    }

    // 2. Move Logic: Update Y position (Gravity)
    // Reduced speed from 0.15 to 0.05 for slower fall
    _currentPiece!.y += 0.05;

    // 3. Random Actions (Rotate / Move Horizontal)
    // 60fps approx, so use low probability per frame
    final r = Random();

    // 2% chance to rotate per frame
    if (r.nextDouble() < 0.02) {
      _currentPiece!.rotate();
    }

    // 3% chance to move left/right per frame
    if (r.nextDouble() < 0.03) {
      final moveDir = r.nextBool() ? 1 : -1;
      _currentPiece!.x += moveDir;
    }

    // 4. Cleanup Logic: Remove piece after it reaches bottom
    // (Assuming grid height around 40-50 blocks is sufficient buffer)
    if (_currentPiece!.y > 60) {
      _currentPiece = null; // This allows the next piece to spawn in next frame
    }
  }

  void _spawnPiece() {
    final r = Random();

    // Calculate center column based on current grid width
    // Subtracting 2 to center the piece shape roughly
    int centerCol = (_gridCols / 2).floor() - 2;
    if (centerCol < 0) centerCol = 0;

    _currentPiece = _FallingPiece(
      shapeIndex: r.nextInt(_FallingPiece.shapes.length),
      x: centerCol,
      y: -4.0, // Start just above the visible area
    );
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder ensures the CustomPaint rebuilds every frame
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate columns based on width and block size (24.0)
        _gridCols = (constraints.maxWidth / 24.0).ceil();

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _TetrisPainter(
                piece: _currentPiece,
                color: Colors.white.withOpacity(0.08),
              ),
              child: Container(),
            );
          },
        );
      },
    );
  }
}

// Simple class to hold piece state
class _FallingPiece {
  // Store actual points so they can be rotated
  List<Point<int>> points;
  int x;
  double y;

  _FallingPiece({required int shapeIndex, required this.x, required this.y})
    : points = List.from(shapes[shapeIndex]); // Copy shapes to allow mutation

  void rotate() {
    // Rotate 90 degrees around relative origin (0,0)
    // Transformation: (x, y) -> (-y, x)
    points = points.map((p) => Point(-p.y, p.x)).toList();
  }

  static const List<List<Point<int>>> shapes = [
    [Point(0, 0), Point(1, 0), Point(0, 1), Point(1, 1)], // O
    [Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3)], // I
    [Point(0, 0), Point(1, 0), Point(1, 1), Point(2, 1)], // S
    [Point(1, 0), Point(2, 0), Point(0, 1), Point(1, 1)], // Z
    [Point(0, 0), Point(0, 1), Point(0, 2), Point(1, 2)], // L
    [Point(1, 0), Point(1, 1), Point(1, 2), Point(0, 2)], // J
    [Point(0, 0), Point(1, 0), Point(2, 0), Point(1, 1)], // T
  ];
}

class _TetrisPainter extends CustomPainter {
  final _FallingPiece? piece;
  final Color color;

  _TetrisPainter({required this.piece, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (piece == null) return;

    final paint = Paint()..color = color;
    const double blockSize = 24.0;

    final shape = piece!.points;

    for (var p in shape) {
      // Calculate drawing position
      final double drawX = (piece!.x + p.x) * blockSize;
      final double drawY = (piece!.y + p.y) * blockSize;

      // Draw only if strictly within horizontal bounds and vertically reasonable
      // We allow drawing slightly off top/bottom to ensure smooth entry/exit
      if (drawX < size.width && drawY < size.height + blockSize) {
        canvas.drawRect(
          Rect.fromLTWH(drawX + 2, drawY + 2, blockSize - 4, blockSize - 4),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TetrisPainter oldDelegate) => true;
}
