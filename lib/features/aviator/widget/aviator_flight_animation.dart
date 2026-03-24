import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_images.dart';
import '../core/theme/theme.dart';
import '../core/utils/sound_manager.dart';
import '../providers/aviator_music_provider.dart';
import '../providers/aviator_round_provider.dart';
import 'aviator_settings_drawer.dart';

class AviatorFlightAnimation extends ConsumerStatefulWidget {
  const AviatorFlightAnimation({super.key});

  @override
  ConsumerState<AviatorFlightAnimation> createState() =>
      _AnimatedContainerState();
}

class _AnimatedContainerState extends ConsumerState<AviatorFlightAnimation>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _takeoffController;
  late AnimationController _waveController;
  late AnimationController _flyAwayController;
  late AnimationController _enterController;

  late Animation<double> _takeoffAnimation;
  late Animation<double> _flyAwayAnimation;

  bool _isWaving = false;
  bool _isAnimating = false;

  bool _hasReachedWave = false;
  bool _hasFlownAway = false;
  bool _hasPlayedStartSound =
      false; // Track if start sound has been played for current round
  bool _hasStartedMusic = false;

  final List<Offset> _pathPoints = [];
  Offset? _currentPlanePosition;
  Offset? _flyAwayStartPosition;

  double _waveProgress = 0.0;
  final double _waveAmplitude = 15.0;
  late AnimationController _waveAmplitudeController;
  late Animation<double> _waveAmplitudeAnimation;
  final double _waveFrequency = 0.05;

  // 👈 PREPARE state countdown variables
  late AnimationController _prepareController;
  bool _hasStartedPrepareAnimation = false;
  late final AnimationController _controller;
  bool _isControllerRepeating = false;

  // Your image size (must match actual image OR container you use)
  final double imgWidth = 396;
  final double imgHeight = 294;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      duration: const Duration(seconds: 120),
      vsync: this,
    );

    _takeoffController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2900),
    );
    _takeoffAnimation = CurvedAnimation(
      parent: _takeoffController,
      curve: Curves.easeInOutCubic,
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    double lastWaveTick = 0.0;

    _waveController.addListener(() {
      if (_isWaving) {
        final now =
            _waveController.lastElapsedDuration?.inMilliseconds.toDouble() ??
                0.0;
        final delta = now - lastWaveTick;
        lastWaveTick = now;

        const speed = 0.03;
        setState(() {
          _waveProgress += delta * speed;
        });
      }
    });

    _flyAwayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _flyAwayAnimation = CurvedAnimation(
      parent: _flyAwayController,
      curve: Curves.easeInOutCubic,
    );

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _prepareController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _waveAmplitudeController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ), // Ramp up over 1 second; adjust for smoother/faster transition
    );
    _waveAmplitudeAnimation =
        Tween<double>(begin: 0.0, end: _waveAmplitude).animate(
      CurvedAnimation(
        parent: _waveAmplitudeController,
        curve: Curves.easeInOut,
      ),
    );

    // Auto-play music if switch is ON
    // Music start logic moved to build method to wait for socket connection
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final isMusicOn = ref.read(aviatorMusicProvider);
    //   if (isMusicOn) {
    //     SoundManager.aviatorMusic();
    //   }
    // });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _takeoffController.dispose();
    _waveController.dispose();
    _flyAwayController.dispose();
    _enterController.dispose();
    _prepareController.dispose();
    _waveAmplitudeController.dispose();

    // Stop background music when widget is disposed
    SoundManager.stopAviatorMusic();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      SoundManager.pauseBackground();
    } else if (state == AppLifecycleState.resumed) {
      // Check if music should be playing (based on provider) before resuming
      final isMusicOn = ref.read(aviatorMusicProvider);
      if (isMusicOn) {
        SoundManager.resumeBackground();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final round = ref.watch(aviatorRoundNotifierProvider);
    final tick = ref.watch(aviatorTickProvider);

    // Determine if we already have any tick data
    final hasTickData = tick.maybeWhen(data: (_) => true, orElse: () => false);

    // Control the background animation controller based on tick data
    if (hasTickData && !_isControllerRepeating) {
      _controller.repeat(period: const Duration(seconds: 12));
      _isControllerRepeating = true;
    } else if (!hasTickData && _isControllerRepeating) {
      _controller.stop();
      _isControllerRepeating = false;
    }

    // 👇 Detect if socket is connecting (no data yet)
    // Consider it "connected" as soon as either round state or tick arrives
    final isSocketConnecting = round == null && !hasTickData;

    if (isSocketConnecting) {
      // 🛫 Initial loader + plane
      return Container(
        width: double.infinity,
        height: 294,
        decoration: const BoxDecoration(
          color: AppColors.aviatorThirtyFiveColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            // Lottie.asset(
            //   'assets/images/aviator_loading.json',
            //   width: 150,
            //   height: 150,
            // ),
            // Plane at (0,0)

            // Positioned(
            //   left: 0,
            //   bottom: 0,
            //   child: Image.asset(AppImages.graphContainerplaneImage, width: 70),
            // ),

            // // Circular progress indicator
            CircularProgressIndicator(
              color: AppColors.aviatorTwentyEighthColor,
              strokeWidth: 3,
            ),
          ],
        ),
      );
    }

    // Socket is connected here
    if (!_hasStartedMusic) {
      _hasStartedMusic = true;
      // Use addPostFrameCallback to avoid state changes during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final isMusicOn = ref.read(aviatorMusicProvider);
          if (isMusicOn) {
            SoundManager.aviatorMusic();
          }
        }
      });
    }

    // PREPARE countdown logic
    if (round?.state == 'pending') {
      final msRemaining = int.tryParse(round?.msRemaining ?? '0') ?? 0;

      if (!_hasStartedPrepareAnimation && msRemaining > 0) {
        _prepareController.duration = Duration(milliseconds: msRemaining);
        _prepareController.reverse(from: 1.0);
        _hasStartedPrepareAnimation = true;
      }

      // When we enter PREPARE after a CRASHED round / fly-away,
      // ensure all animation state is reset exactly once here,
      // instead of from the fly-away controller callback. This
      // avoids wiping the new round's path if a new takeoff starts
      // before the previous fly-away animation completes.
      if (_isAnimating ||
          _hasFlownAway ||
          _takeoffController.isAnimating ||
          _flyAwayController.isAnimating ||
          _waveController.isAnimating) {
        _resetAnimation();
      }

      // Stop the background animation in PREPARE state
      _controller.stop();
      _isControllerRepeating = false;
    } else {
      if (_hasStartedPrepareAnimation) {
        _prepareController.stop();
        _hasStartedPrepareAnimation = false;
      }
    }

    // Current multiplier from tick stream
    final currentValue = tick.when(
      data: (data) => double.tryParse(data.multiplier ?? '0') ?? 0.0,
      error: (_, __) => 0.0,
      loading: () => 0.0,
    );

    // Play start sound only when multiplier is within 1.00 - 1.10 (at the very start)
    if (currentValue >= 1.00 &&
        currentValue <= 1.10 &&
        !_hasPlayedStartSound &&
        round?.state == 'running') {
      final isStartSoundOn = ref.read(aviatorStartSoundProvider);
      if (isStartSoundOn) {
        SoundManager.aviatorStartSound();
      }
      _hasPlayedStartSound = true;
    }

    // Animation triggers
    //
    // Start takeoff when we actually receive a tick value from the server,
    // instead of only relying on the round.state == 'RUNNING'. This keeps
    // the plane animation in sync with the tick stream.
    if (currentValue > 0 && !_isAnimating && round?.state == 'running') {
      _startTakeoff();
    }

    // Trigger fly-away when the round crashes.
    if (round?.state == 'crashed' && !_hasFlownAway) {
      _startFlyAway();
    }

    // Stop the background animation in CRASHED state
    if (round?.state == 'crashed') {
      _controller.stop();
      _isControllerRepeating = false;
    }

    return Container(
      width: double.infinity,
      height: 294,
      decoration: const BoxDecoration(
        color: AppColors.aviatorThirtyFiveColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: -imgWidth / 2, // Move image center to bottom-left
            bottom: -imgHeight / 2,
            child: hasTickData || round?.state == 'running'
                ? AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _controller.value * 2 * pi,
                        alignment:
                            Alignment.center, // rotate around the offset center
                        child: Transform.scale(scale: 5, child: child),
                      );
                    },
                    child: SizedBox(
                      width: imgWidth,
                      height: imgHeight,
                      child: SvgPicture.asset(
                        AppImages.aviatorbg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Transform.scale(
                    scale: 5,
                    child: SizedBox(
                      width: imgWidth,
                      height: imgHeight,
                      child: SvgPicture.asset(
                        AppImages.aviatorbg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          Column(
            children: [
              // Top bar
              Container(
                height: 50,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.aviatorThirteenthColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48), // Balance the hamburger icon
                    Text(
                      'FUN MODE',
                      style: Theme.of(context).textTheme.aviatorBodyTitleMdeium,
                    ),
                    Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: AppColors.aviatorTertiaryColor,
                          ),
                          onPressed: () {
                            final RenderBox renderBox =
                                context.findRenderObject() as RenderBox;
                            final position = renderBox.localToGlobal(
                              Offset.zero,
                            );
                            final size = renderBox.size;
                            showAviatorSettingsDrawer(
                              context: context,
                              position: position,
                              size: size,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // PREPARE UI
              if (round?.state == 'pending')
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _prepareController,
                          builder: (context, child) {
                            return Container(
                              width: 200, // adjust width as needed
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.aviatorFourtyFiveColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _prepareController
                                    .value, // controls fill percentage
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .aviatorGraphBarColor, // active color
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 50),
                            //! 20s center text
                            // Text(
                            //   "$_prepareSecondsLeft",
                            //   style: Theme.of(
                            //     context,
                            //   ).textTheme.aviatorDisplayLarge,
                            // ),
                            const SizedBox(height: 28),
                            Text(
                              "Next round starts",
                              style: Theme.of(
                                context,
                              ).textTheme.aviatorBodyTitleMdeium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              else
                // RUNNING / CRASHED UI
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;

                      return AnimatedBuilder(
                        animation: Listenable.merge([
                          _takeoffController,
                          _waveController,
                          _flyAwayController,
                        ]),
                        builder: (context, _) {
                          double x, y;
                          double planeAngle = -pi / 12;

                          if (_flyAwayController.isAnimating) {
                            final t = _flyAwayAnimation.value;

                            // Start directly from the plane's current position
                            final start = _flyAwayStartPosition ??
                                Offset(width * 0.65, height * 0.5);
                            // Define control and end relative to start for a consistent curve shape
                            final control = Offset(
                              start.dx + (width * 0.2),
                              start.dy + (height * 0.3),
                            );
                            final end = Offset(
                              start.dx + (width * 0.55),
                              start.dy + height + 150,
                            );

                            x = (1 - t) * (1 - t) * start.dx +
                                2 * (1 - t) * t * control.dx +
                                t * t * end.dx;
                            y = (1 - t) * (1 - t) * start.dy +
                                2 * (1 - t) * t * control.dy +
                                t * t * end.dy;
                            planeAngle = -pi / 6;
                          } else {
                            final t = _takeoffAnimation.value;
                            const start = Offset(24, 24);
                            final control = Offset(width * 0.5, height * 0.1);
                            final end = Offset(width * 0.7, height * 0.5);

                            x = (1 - t) * (1 - t) * start.dx +
                                2 * (1 - t) * t * control.dx +
                                t * t * end.dx;
                            y = (1 - t) * (1 - t) * start.dy +
                                2 * (1 - t) * t * control.dy +
                                t * t * end.dy;

                            if (!_hasReachedWave && t >= 1) {
                              _hasReachedWave = true;
                              _isWaving = true;
                              _takeoffController.stop();
                              _waveController.repeat();
                              _waveAmplitudeController.forward(from: 0);
                            }
                          }

                          double waveOffset = 0.0;
                          // double planeAngle = -pi / 12;
                          if (_isWaving && !_flyAwayController.isAnimating) {
                            final currentAmplitude =
                                _waveAmplitudeAnimation.value;
                            waveOffset = sin(_waveProgress * _waveFrequency) *
                                currentAmplitude;
                            final waveTangent =
                                cos(_waveProgress * _waveFrequency) *
                                    currentAmplitude *
                                    _waveFrequency;
                            if (_waveAmplitudeController.isAnimating) {
                              // During transition, interpolate angle from takeoff to waving
                              final targetAngle = -atan(waveTangent / 5);
                              const startAngle = -pi / 12;
                              final t = currentAmplitude /
                                  _waveAmplitude; // Transition progress (0 to 1)
                              planeAngle =
                                  startAngle + (targetAngle - startAngle) * t;
                            } else {
                              // Normal waving after transition
                              planeAngle = -atan(waveTangent / 5);
                            }
                          }

                          final unclampedBottomPos = y + waveOffset;
                          final bottomPos = _flyAwayController.isAnimating
                              ? unclampedBottomPos
                                  .clamp(0, double.infinity)
                                  .toDouble()
                              : unclampedBottomPos
                                  .clamp(0, height - 60)
                                  .toDouble();
                          final clampedX = (_flyAwayController.isAnimating
                                  ? x
                                  : x.clamp(0, width - 70))
                              .toDouble();
                          final currentPoint = Offset(
                            clampedX,
                            height - bottomPos,
                          );
                          _currentPlanePosition = currentPoint;

                          // Always record the plane path while the animation is active,
                          // including takeoff, waving, and fly-away segments.
                          if (_isAnimating && !_isWaving) {
                            if (_pathPoints.isEmpty ||
                                (_pathPoints.last - currentPoint).distance >
                                    1) {
                              _pathPoints.add(currentPoint);
                            }
                          }

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              clipBehavior: Clip.hardEdge,
                              children: [
                                CustomPaint(
                                  size: Size(width, height),
                                  painter: PathPainter(
                                    round?.state == 'crashed'
                                        ? const <Offset>[]
                                        : _pathPoints,
                                    height,
                                    _currentPlanePosition,
                                    _isWaving,
                                    _waveProgress,
                                    _waveAmplitude,
                                    _waveFrequency,
                                  ),
                                ),
                                Positioned(
                                  left: _flyAwayController.isAnimating
                                      ? currentPoint.dx
                                      : currentPoint.dx - 9,
                                  bottom: bottomPos - 3,
                                  child: Transform.rotate(
                                    angle: planeAngle,
                                    child: SvgPicture.asset(
                                      AppImages.graphContainerplaneImage,
                                      width: 70,
                                    ),
                                  ),
                                ),
                                if ((round?.state == 'running') ||
                                    (round == null && hasTickData))
                                  Center(
                                    child: Container(
                                      width: 390,
                                      //  height: 62,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            currentValue >= 10
                                                ? AppImages.spreadclr3
                                                : currentValue >= 2
                                                    ? AppImages.spreadclr2
                                                    : AppImages.spreadclr1,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${currentValue.toStringAsFixed(2)}x",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.aviatorDisplayLarge,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (round?.state == 'crashed' &&
                                    _flyAwayController.isAnimating)
                                  Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "FLEW AWAY",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.aviatorHeadlineSmall,
                                        ),
                                        // const SizedBox(height: 4),
                                        Text(
                                          "${round?.crashAt?.toString() ?? ''}x",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.aviatorDisplayLargeSecond,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _startTakeoff() {
    _isAnimating = true;
    _hasReachedWave = false;
    _isWaving = false;
    _hasFlownAway = false;
    _waveProgress = 0.0;
    _waveAmplitudeController.reset();
    _pathPoints.clear();
    _currentPlanePosition = null;

    _takeoffController.forward(from: 0);
  }

  void _startFlyAway() {
    _hasFlownAway = true;
    _isWaving = false;
    _waveController.stop();

    // Play flew away sound if enabled
    final isStartSoundOn = ref.read(aviatorStartSoundProvider);
    if (isStartSoundOn) {
      SoundManager.aviatorFlewAwaySound();
    }

    // Capture the plane's current position so the fly-away starts
    // exactly from where the plane was when the round crashed.
    _flyAwayStartPosition = _currentPlanePosition;
    // Do NOT clear _pathPoints here; the path will be cleared in PREPARE via
    // _resetAnimation(), before the next takeoff starts.
    _flyAwayController.forward(from: 0);
  }

  void _resetAnimation() {
    _isAnimating = false;
    _isWaving = false;
    _hasReachedWave = false;
    _hasFlownAway = false;
    _hasPlayedStartSound = false; // Reset for next round
    _waveProgress = 0.0;
    _pathPoints.clear();
    _currentPlanePosition = null;
    _flyAwayStartPosition = null;

    _takeoffController.reset();
    _waveController.reset();
    _flyAwayController.reset();
  }
}

class PathPainter extends CustomPainter {
  final List<Offset> points;
  final double height;
  final Offset? currentPlanePosition;
  final bool isWaving;
  final double waveProgress;
  final double waveAmplitude;
  final double waveFrequency;

  PathPainter(
    this.points,
    this.height,
    this.currentPlanePosition,
    this.isWaving,
    this.waveProgress,
    this.waveAmplitude,
    this.waveFrequency,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Do NOT return early when points are empty; we still want axes & dots.
    List<Offset> displayPoints = [];

    // Build displayPoints only if we actually have path points
    if (points.isNotEmpty) {
      if (isWaving) {
        final waveY = sin(waveProgress * waveFrequency) * waveAmplitude;
        final startX = points.first.dx;
        final totalWidth = points.last.dx - startX;

        displayPoints = points.map((p) {
          // Calculate interpolation factor t (0.0 at start, 1.0 at end)
          final t = totalWidth > 0 ? (p.dx - startX) / totalWidth : 0.0;
          // Apply wave offset scaled by t, so start point is fixed
          return Offset(p.dx, p.dy - (waveY * t));
        }).toList();

        if (currentPlanePosition != null) {
          displayPoints.add(currentPlanePosition!);
        }
      } else {
        displayPoints = [...points];
        if (currentPlanePosition != null) {
          displayPoints.add(currentPlanePosition!);
        }
      }
    }

    // Only draw fill/path/area if there are points
    if (displayPoints.isNotEmpty) {
      // ----------------------------
      // Clip region: prevent fill/path/area from drawing above the X-axis line
      // (X-axis is located at y = height - 24)
      // ----------------------------
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, height - 24));

      // Fill gradient under curve
      final fillPaint = Paint()..style = PaintingStyle.fill;

      final fillPath = Path()
        ..moveTo(displayPoints.first.dx, displayPoints.first.dy);
      _drawSmoothCurve(fillPath, displayPoints);
      fillPath.lineTo(displayPoints.last.dx, height);
      fillPath.lineTo(displayPoints.first.dx, height);
      fillPath.close();
      final fillBounds = fillPath.getBounds();
      final fillGradient = const LinearGradient(
        colors: [
          AppColors.aviatorGraphBarAreaColor3,
          AppColors.aviatorGraphBarColor,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(fillBounds);
      fillPaint.shader = fillGradient;
      canvas.drawPath(fillPath, fillPaint);

      final pathPaint = Paint()
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..color = AppColors.aviatorGraphBarColor;

      final path = Path()
        ..moveTo(displayPoints.first.dx, displayPoints.first.dy);
      _drawSmoothCurve(path, displayPoints);
      canvas.drawPath(path, pathPaint);

      // Area rectangles under the curve (xAxisPaint)
      final xAxisPaint = Paint()
        ..color = AppColors.aviatorGraphBarAreaColor2
        ..style = PaintingStyle.fill;

      for (int i = 1; i < displayPoints.length; i++) {
        final prev = displayPoints[i - 1];
        final curr = displayPoints[i];
        final rect = Rect.fromLTRB(prev.dx, curr.dy, curr.dx, height);
        canvas.drawRect(rect, xAxisPaint);
      }

      // restore so axes & dots can be drawn on top
      canvas.restore();
    }

    // From here on, we ALWAYS draw dots and axes, even when there is no path.

    // ✅ Y-axis dots (exact same alignment, just 9 total)
    final yAxisDotPaint = Paint()
      ..color = AppColors.aviatorNineteenthColor
      ..style = PaintingStyle.fill;

    const yDotCount = 9;
    final ySpacing = (height - 24 - 10) / (yDotCount - 1);
    for (int i = 0; i < yDotCount; i++) {
      final y = 10 + (ySpacing * i);
      if (y >= height - 24) continue; // skip bottom overlap
      canvas.drawCircle(Offset(10, y), 2, yAxisDotPaint);
    }

    // ✅ X-axis dots (same alignment, 9 total)
    final xAxisDotPaint = Paint()
      ..color = AppColors.aviatorTertiaryColor
      ..style = PaintingStyle.fill;

    const xDotCount = 9;
    final xSpacing = (size.width - 10 - 24) / (xDotCount - 1);
    for (int i = 0; i < xDotCount; i++) {
      final x = 10 + (xSpacing * i);
      if (x <= 24) continue; // skip origin
      canvas.drawCircle(Offset(x, height - 10), 2, xAxisDotPaint);
    }

    // ✅ Axis lines (keep same position)
    final axisLinePaint = Paint()
      ..color = AppColors.aviatorFourtyFourColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // X-axis line
    canvas.drawLine(
      Offset(24, height - 24),
      Offset(size.width, height - 24),
      axisLinePaint,
    );

    // Y-axis line
    canvas.drawLine(
        Offset(24, height - 24), const Offset(24, 0), axisLinePaint);
  }

  void _drawSmoothCurve(Path path, List<Offset> points) {
    if (points.length < 2) return;

    for (int i = 1; i < points.length; i++) {
      final p1 = points[i];
      if (i == points.length - 1) {
        path.lineTo(p1.dx, p1.dy);
      } else {
        final p2 = points[i + 1];
        final controlPoint = Offset(p1.dx, p1.dy);
        final endPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        path.quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          endPoint.dx,
          endPoint.dy,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    // Always repaint because the `points` list is mutated in place.
    // Relying on `==` for lists only checks identity, not contents,
    // which prevents the painter from updating when the path changes
    // between rounds or frames.
    return true;
  }
}
