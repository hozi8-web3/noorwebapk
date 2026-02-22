import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../app/theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  // Mecca coordinates
  static const double meccaLat = 21.422487;
  static const double meccaLon = 39.826206;

  double? _qiblaBearing;
  bool _calculating = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initBearing();
  }

  Future<void> _initBearing() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() {
          _error = 'Location permission is required to calculate accurate Qibla direction.';
          _calculating = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      final bearing = Geolocator.bearingBetween(
        pos.latitude, pos.longitude, meccaLat, meccaLon,
      );

      if (mounted) setState(() {
        _qiblaBearing = (bearing + 360) % 360;
        _calculating = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = 'Failed to get location. Ensure GPS is enabled.';
        _calculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_calculating) {
      return Scaffold(
        appBar: AppBar(title: const Text('Qibla Finder')),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Qibla Finder')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() { _calculating = true; _error = null; });
                    _initBearing();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Qibla Finder')),
      body: StreamBuilder<CompassEvent>(
        stream: FlutterCompass.events,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.explore_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Compass not available on this device.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }

          final heading = snapshot.data!.heading ?? 0;
          final direction = _qiblaBearing! - heading;

          return _buildCompass(context, direction, heading);
        },
      ),
    );
  }

  Widget _buildCompass(BuildContext context, double direction, double heading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Point the arrow toward\nAl-Masjid Al-Haram',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(),
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              // Compass circle
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _CompassPainter(heading),
                ),
              ),
              // Qibla arrow
              Transform.rotate(
                angle: direction * math.pi / 180,
                child: Column(
                  children: [
                    Icon(Icons.navigation_rounded,
                        color: AppColors.primary, size: 60),
                    Text('Qibla',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Heading: ${heading.toStringAsFixed(1)}°',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Qibla Direction: ${_qiblaBearing!.toStringAsFixed(1)}°',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double heading;
  _CompassPainter(this.heading);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circle
    canvas.drawCircle(center, radius, paint);

    // Draw cardinal directions
    const directions = ['N', 'E', 'S', 'W'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - heading) * math.pi / 180;
      final x = center.dx + (radius - 20) * math.sin(angle);
      final y = center.dy - (radius - 20) * math.cos(angle);
      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 ? Colors.red : AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.heading != heading;
}
