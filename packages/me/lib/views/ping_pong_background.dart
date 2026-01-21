import 'dart:math';
import 'package:flutter/material.dart';

class PingPongBackground extends StatefulWidget {
  final Color color;
  const PingPongBackground({Key? key, this.color = Colors.white})
    : super(key: key);

  @override
  State<PingPongBackground> createState() => _PingPongBackgroundState();
}

class _PingPongBackgroundState extends State<PingPongBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Game state
  final List<_Ball> _balls = [];

  double _leftPaddleY = 0.5;
  double _rightPaddleY = 0.5;
  final double _paddleHeight = 0.15; // 15% of height

  @override
  void initState() {
    super.initState();

    // Initialize 4 balls
    for (int i = 0; i < 4; i++) {
      _balls.add(_createResetBall());
    }

    // Use AnimationController for smooth 60fps animation
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
    // 1. Update Balls
    for (var ball in _balls) {
      _updateBall(ball);
    }

    // 2. AI Movement
    // Left paddle tracks the ball closest to the left side
    final leftTarget = _findTargetBall(true);
    if (leftTarget != null) {
      _leftPaddleY = _movePaddle(_leftPaddleY, leftTarget.y);
    }

    // Right paddle tracks the ball closest to the right side
    final rightTarget = _findTargetBall(false);
    if (rightTarget != null) {
      _rightPaddleY = _movePaddle(_rightPaddleY, rightTarget.y);
    }
  }

  void _updateBall(_Ball ball) {
    // Move Ball
    ball.x += ball.velX;
    ball.y += ball.velY;

    // Wall Collisions (Top/Bottom)
    if (ball.y <= 0.02 || ball.y >= 0.98) {
      ball.velY = -ball.velY;
    }

    // Paddle Collisions
    // Left Paddle (x approx 0.05)
    if (ball.x <= 0.06 && ball.x >= 0.04) {
      if ((ball.y - _leftPaddleY).abs() < _paddleHeight / 2 + 0.05) {
        ball.velX = ball.velX.abs() * 1.05; // Bounce right & speed up
        ball.velY += (Random().nextDouble() - 0.5) * 0.005;
      }
    }

    // Right Paddle (x approx 0.95)
    if (ball.x >= 0.94 && ball.x <= 0.96) {
      if ((ball.y - _rightPaddleY).abs() < _paddleHeight / 2 + 0.05) {
        ball.velX = -ball.velX.abs() * 1.05; // Bounce left & speed up
        ball.velY += (Random().nextDouble() - 0.5) * 0.005;
      }
    }

    // Reset if out of bounds (Score)
    if (ball.x < -0.1 || ball.x > 1.1) {
      _resetBall(ball);
    }
  }

  _Ball? _findTargetBall(bool forLeftPaddle) {
    _Ball? target;
    double bestDist = double.infinity;

    for (var ball in _balls) {
      // For left paddle, we care about balls moving left (velX < 0) or close to left
      // For right paddle, we care about balls moving right (velX > 0) or close to right

      // Calculate distance to the paddle's x-plane (0.0 or 1.0)
      double dist = forLeftPaddle ? ball.x : (1.0 - ball.x);

      // Simple heuristic: prioritize balls coming towards us
      bool isIncoming = forLeftPaddle ? ball.velX < 0 : ball.velX > 0;

      // If incoming, treat it as closer to prioritize it
      if (isIncoming) dist *= 0.5;

      if (dist < bestDist) {
        bestDist = dist;
        target = ball;
      }
    }
    return target;
  }

  double _movePaddle(double currentY, double targetY) {
    double speed = 0.01; // Slightly faster paddle for multi-ball
    if (currentY < targetY - 0.05) {
      currentY += speed;
    } else if (currentY > targetY + 0.05) {
      currentY -= speed;
    }
    return currentY.clamp(_paddleHeight / 2, 1.0 - _paddleHeight / 2);
  }

  _Ball _createResetBall() {
    final ball = _Ball(0.5, 0.5, 0, 0);
    _resetBall(ball);
    return ball;
  }

  void _resetBall(_Ball ball) {
    ball.x = 0.5;
    ball.y = 0.5;
    // Reset speed and random direction
    ball.velX =
        (Random().nextBool() ? 0.008 : -0.008) *
        (0.8 + Random().nextDouble() * 0.4);
    ball.velY = (Random().nextDouble() - 0.5) * 0.015;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _PingPongPainter(
            balls: _balls,
            leftPaddleY: _leftPaddleY,
            rightPaddleY: _rightPaddleY,
            paddleHeight: _paddleHeight,
            color: widget.color,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _Ball {
  double x;
  double y;
  double velX;
  double velY;

  _Ball(this.x, this.y, this.velX, this.velY);
}

class _PingPongPainter extends CustomPainter {
  final List<_Ball> balls;
  final double leftPaddleY;
  final double rightPaddleY;
  final double paddleHeight;
  final Color color;

  _PingPongPainter({
    required this.balls,
    required this.leftPaddleY,
    required this.rightPaddleY,
    required this.paddleHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final ballPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    // Draw Center Line (Dashed)
    final dashHeight = 10.0;
    final dashSpace = 10.0;
    double startY = 0;
    final centerPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = 2;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        centerPaint,
      );
      startY += dashHeight + dashSpace;
    }

    // Draw Paddles
    final paddleW = 4.0;
    final paddleH = size.height * paddleHeight;

    // Left Paddle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.05, size.height * leftPaddleY),
          width: paddleW,
          height: paddleH,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Right Paddle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.95, size.height * rightPaddleY),
          width: paddleW,
          height: paddleH,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Draw Balls
    for (var ball in balls) {
      canvas.drawCircle(
        Offset(size.width * ball.x, size.height * ball.y),
        4.0,
        ballPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PingPongPainter oldDelegate) => true;
}
