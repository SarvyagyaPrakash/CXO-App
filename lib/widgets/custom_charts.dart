import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// --- Custom Sparkline Graph ---

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double maxVal = data.reduce((a, b) => a > b ? a : b);
    final double minVal = data.reduce((a, b) => a < b ? a : b);
    final double range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final double stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - ((data[i] - minVal) / range) * (size.height - 10.0) - 5.0;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Draw ending point circle
    final double endX = size.width;
    final double endY = size.height - ((data.last - minVal) / range) * (size.height - 10.0) - 5.0;
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(endX, endY), 4.0, pointPaint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

class SparklineWidget extends StatelessWidget {
  final List<double> data;
  final Color color;
  final double width;
  final double height;

  const SparklineWidget({
    Key? key,
    required this.data,
    required this.color,
    this.width = 100,
    this.height = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: SparklinePainter(data: data, color: color),
      ),
    );
  }
}

// --- Custom Donut Chart ---

class DonutSegment {
  final double value; // Percentage value (out of 100)
  final Color color;
  final String label;

  DonutSegment({required this.value, required this.color, required this.label});
}

class DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;

  DonutChartPainter({required this.segments, this.strokeWidth = 12.0});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // Draw background track
    final bgPaint = Paint()
      ..color = const Color(0xFFE3E8E4).withOpacity(0.3)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -pi / 2; // Start from top
    for (var seg in segments) {
      final double sweepAngle = (seg.value / 100.0) * 2 * pi;
      final segmentPaint = Paint()
        ..color = seg.color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Draw active segment sweep
      canvas.drawArc(rect, startAngle, sweepAngle, false, segmentPaint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) => true;
}

class DonutChartWidget extends StatelessWidget {
  final List<DonutSegment> segments;
  final double size;
  final double strokeWidth;
  final Widget? centerWidget;

  const DonutChartWidget({
    Key? key,
    required this.segments,
    this.size = 140,
    this.strokeWidth = 12.0,
    this.centerWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: DonutChartPainter(segments: segments, strokeWidth: strokeWidth),
          ),
        ),
        if (centerWidget != null) centerWidget!,
      ],
    );
  }
}

// --- Interactive Problem Carousel (3D Depth Slider) ---

class SlidingProblemCarousel extends StatefulWidget {
  final List<Map<String, String>> slides;
  const SlidingProblemCarousel({Key? key, required this.slides}) : super(key: key);

  @override
  State<SlidingProblemCarousel> createState() => _SlidingProblemCarouselState();
}

class _SlidingProblemCarouselState extends State<SlidingProblemCarousel> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8, initialPage: 0);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.slides.length,
        itemBuilder: (context, index) {
          // Calculate scale and offset factor
          double delta = index - _currentPage;
          double scale = 1.0 - (delta.abs() * 0.12).clamp(0.0, 0.15);
          double opacity = 1.0 - (delta.abs() * 0.4).clamp(0.0, 0.4);
          double blur = (delta.abs() * 5.0).clamp(0.0, 5.0);

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                clipBehavior: Clip.antiAlias,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.slides[index]['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF0D1A18), Color(0xFF0C0F0D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Icon(Icons.business, size: 80, color: Color(0xFF0EB59A)),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.95),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EB59A).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF0EB59A).withOpacity(0.5)),
                              ),
                              child: Text(
                                widget.slides[index]['tag'] ?? 'INSIGHT',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0EB59A),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.slides[index]['title']!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.slides[index]['content']!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[300],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
