import 'dart:async';
import 'dart:math';

import 'package:sm_project/roulette/roulette_api_service.dart';
import 'package:sm_project/roulette/roulette_game_mode.dart';
import 'package:sm_project/roulette/roulette_history_menu_screen.dart';
import 'package:sm_project/roulette/roulette_market_model.dart';
import 'package:sm_project/roulette/roulette_rates_screen.dart';
import 'package:sm_project/roulette/roulette_result_model.dart';
import 'package:sm_project/roulette/roulette_rules_screen.dart';
import 'package:sm_project/utils/filecollection.dart';

// String extension for title case conversion
extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;

    // Split the string by space and convert each word
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}

class RouletteScreen extends StatefulWidget {
  const RouletteScreen({super.key});

  @override
  State<RouletteScreen> createState() => _RouletteScreenState();
}

class _RouletteScreenState extends State<RouletteScreen>
    with TickerProviderStateMixin {
  // Timer variables
  int _seconds = 56;
  Timer? _timer;
  Timer? _refreshTimer;
  Timer? _resultRefreshTimer; // New timer for result data refresh

  // API service
  final RouletteApiService _apiService = RouletteApiService();
  RouletteModel? _marketData;
  RouletteResultModel? _resultData;
  String? _lastResultReceived; // Track last result to detect changes
  bool _isLoading = true;
  bool _isWaitingForResult = false;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation controller for wheel rotation
  late AnimationController _animationController;
  bool _isSpinning = false;

  // Animation controller for arrow bounce
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowBounceAnimation;

  // Result numbers
  int _number1 = 0;
  int _number2 = 0;
  int _number3 = 0;
  String _combinedNumber = ''; // Default combined number
  bool _showNumbers = false;

  // Random generator
  final _random = Random();

  // Rotation values for each ring
  double _outerRingRotation = 0;
  double _middleRingRotation = 0;
  double _innerRingRotation = 0;

  // Final rotation positions (to maintain wheel position after animation)
  double _outerRingFinalRotation = 0;
  double _middleRingFinalRotation = 0;
  double _innerRingFinalRotation = 0;

  // Number configurations for each ring
  final List<int> _outerRingNumbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  final List<int> _middleRingNumbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  final List<int> _innerRingNumbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  // Test mode variables
  bool _isTestMode = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _fetchMarketData();
    _startRefreshTimer();
    _startResultRefreshTimer(); // Start the result refresh timer

    // Initialize animation controller with a curve
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Initialize arrow animation controller
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Create bounce animation for arrow
    _arrowBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _arrowAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start the arrow bounce animation and repeat it
    _arrowAnimationController.repeat(reverse: true);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        debugPrint('=== ANIMATION COMPLETED ===');
        debugPrint('Test mode: $_isTestMode, Test result: $_testResult');
        debugPrint('Result data available: ${_resultData?.result}');

        // Store the final rotation positions (including the curve transformation)
        final finalAnimationValue =
            Curves.easeOut.transform(1.0); // Value at completion
        _outerRingFinalRotation = finalAnimationValue * _outerRingRotation;
        _middleRingFinalRotation = finalAnimationValue * _middleRingRotation;
        _innerRingFinalRotation = finalAnimationValue * _innerRingRotation;

        debugPrint(
            'Final rotations stored: [$_outerRingFinalRotation, $_middleRingFinalRotation, $_innerRingFinalRotation]');

        setState(() {
          _isSpinning = false;

          if (_isTestMode && _testResult != null) {
            // Show test result - this takes precedence over everything else
            debugPrint('Showing test result: $_testResult');
            _showTestResult(_testResult!);
          } else if (_resultData?.result != null &&
              _resultData!.result!.length >= 3) {
            // Show result from API if available
            debugPrint('Showing API result: ${_resultData!.result}');
            _showResultFromAPI();
          } else {
            // Fallback: calculate the numbers based on wheel positions
            debugPrint('Calculating result from wheel positions...');
            final outerRingIndex =
                _getNumberIndexFromAngle(_outerRingFinalRotation);
            final middleRingIndex =
                _getNumberIndexFromAngle(_middleRingFinalRotation);
            final innerRingIndex =
                _getNumberIndexFromAngle(_innerRingFinalRotation);

            debugPrint(
                'Calculated indices: [$outerRingIndex, $middleRingIndex, $innerRingIndex]');

            _number1 = _outerRingNumbers[outerRingIndex];
            _number2 = _middleRingNumbers[middleRingIndex];
            _number3 = _innerRingNumbers[innerRingIndex];
            _combinedNumber = '$_number1$_number2$_number3';
            _showNumbers = true;

            debugPrint('Calculated result from angles: $_combinedNumber');
          }

          debugPrint(
              'Final display: $_combinedNumber ($_number1, $_number2, $_number3), Show: $_showNumbers');
        });

        // DO NOT reset the animation controller - keep the wheels at their final position
        // _animationController.reset(); // REMOVED THIS LINE

        // Stop the audio when animation completes
        _audioPlayer.stop();

        // Reset test mode after completion
        if (_isTestMode) {
          debugPrint('Resetting test mode');
          _isTestMode = false;
          _testResult = null;
        }
      }
    });
  }

  void _startTimer() {
    // Initialize timer with the calculated value
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;

          // Start spinning when 10 seconds are left
          if (_seconds == 10 && !_isSpinning) {
            _spin();
          }

          // Show result when 5 seconds are left (if API result is available)
          if (_seconds == 5 && _resultData?.result != null && !_showNumbers) {
            _showResultFromAPI();
          }
        } else {
          // Timer reached 0 - fetch new market details
          _timer?.cancel();
          _fetchNewMarketCycle();
        }
      });
    });
  }

  void _spin() {
    if (!_isSpinning) {
      setState(() {
        _isSpinning = true;
        _showNumbers = false;

        // Reset the animation controller before starting a new spin
        _animationController.reset();

        // Set random end rotation values for each ring with different spin counts
        // for more realistic motion
        _outerRingRotation =
            (5 + _random.nextInt(5)) * 2 * pi; // 5-9 full spins
        _middleRingRotation =
            (6 + _random.nextInt(5)) * 2 * pi; // 6-10 full spins
        _innerRingRotation =
            (7 + _random.nextInt(5)) * 2 * pi; // 7-11 full spins
      });

      // Play the roulette clock sound
      _playRouletteSound();

      // Use a curved animation for more realistic spinning (start fast, end slow)
      _animationController.forward();
    }
  }

  void _playRouletteSound() async {
    try {
      // Stop any existing audio first
      await _audioPlayer.stop();
      // Play the roulette clock sound
      await _audioPlayer.play(AssetSource('sound/rouletteclock.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  // Calculate which number is selected based on final angle
  int _getNumberIndexFromAngle(double angle) {
    // Normalize angle to 0-2π range
    double normalizedAngle = angle % (2 * pi);
    while (normalizedAngle < 0) {
      normalizedAngle += 2 * pi;
    }

    // Calculate the angle per segment (each number takes 1/10 of the circle)
    const anglePerSegment = 2 * pi / 10;

    // The wheel starts with 0 at the top position
    // When wheel rotates counter-clockwise (negative rotation), we see higher numbers
    // When wheel rotates clockwise (positive rotation), we see lower numbers
    // Calculate which segment is currently at the arrow position
    final rotationInSegments = normalizedAngle / anglePerSegment;
    final segmentIndex = (10 - rotationInSegments.round()) % 10;

    debugPrint(
        'Final angle: ${angle * 180 / pi}°, Normalized: ${normalizedAngle * 180 / pi}°, Rotation in segments: $rotationInSegments, Number at top: $segmentIndex');

    return segmentIndex;
  }

  // Fetch market data from API
  Future<void> _fetchMarketData() async {
    try {
      final marketData = await _apiService.getMarket();
      if (marketData != null) {
        setState(() {
          _marketData = marketData;
          _isLoading = false;

          // Update timer based on market data and fetch results
          _updateTimerBasedOnMarketData();
        });

        // Fetch results for this market
        _fetchResultData();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching market data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch result data from API
  Future<void> _fetchResultData() async {
    if (_marketData?.sId == null) return;

    try {
      final resultData =
          await _apiService.getResults(market: _marketData!.sId!);
      if (resultData != null) {
        // Check if we have a new result
        final newResult = resultData.result;
        final hasNewResult = newResult != null &&
            newResult.isNotEmpty &&
            newResult != _lastResultReceived;

        setState(() {
          _resultData = resultData;
          _updateTimerForDeclareTime();

          // If we have a new result, trigger automatic spin
          if (hasNewResult && newResult.length >= 3) {
            debugPrint('New result received: $newResult');
            _lastResultReceived = newResult;

            // Only auto-spin if not already spinning and not currently showing numbers
            if (!_isSpinning && !_showNumbers) {
              debugPrint('Auto-spinning with new result: $newResult');
              _autoSpinWithResult(newResult);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching result data: $e');
    }
  }

  // Auto-spin the wheel with a specific result from API
  void _autoSpinWithResult(String result) {
    if (result.length < 3) {
      debugPrint('Auto-spin result must be at least 3 digits');
      return;
    }

    // Validate that all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(result)) {
      debugPrint('Auto-spin result must contain only digits (0-9)');
      return;
    }

    debugPrint('=== STARTING AUTO SPIN ===');
    debugPrint('Auto-spinning with result: $result');

    // Set test mode for consistent behavior
    _isTestMode = true;
    _testResult = result;

    // Parse the result digits (take first 3 digits)
    final digit1 = int.parse(result[0]);
    final digit2 = int.parse(result[1]);
    final digit3 = int.parse(result[2]);

    debugPrint('Target digits: [$digit1, $digit2, $digit3]');

    // Calculate target rotations to land on specific numbers
    _calculateRotationsForResult(digit1, digit2, digit3);

    // Start the spin animation
    setState(() {
      _isSpinning = true;
      _showNumbers = false;
      _combinedNumber = '***'; // Reset to default during spin
    });

    // Reset the animation controller before starting a new spin
    _animationController.reset();

    // Play the roulette clock sound
    _playRouletteSound();

    // Start the animation
    _animationController.forward();
  }

  // Update timer based on declare time from result data
  void _updateTimerForDeclareTime() {
    if (_resultData?.declareTime != null) {
      try {
        // Parse declare time (format expected: "HH:MM" or ISO string)
        final declareTime = _resultData!.declareTime!;
        DateTime declareDateTime;

        if (declareTime.contains(':') && declareTime.length <= 5) {
          // Format: "HH:MM"
          final timeParts = declareTime.split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);

            final now = DateTime.now();
            declareDateTime =
                DateTime(now.year, now.month, now.day, hour, minute).toLocal();

            // If declare time is earlier than current time, assume it's for tomorrow
            if (declareDateTime.isBefore(now)) {
              declareDateTime = declareDateTime.add(const Duration(days: 1));
            }
          } else {
            return;
          }
        } else {
          // Assume ISO format
          declareDateTime = DateTime.parse(declareTime).toLocal();
        }

        final now = DateTime.now();
        final difference = declareDateTime.difference(now);

        if (difference.inSeconds > 0) {
          setState(() {
            _seconds = difference.inSeconds;
            _isWaitingForResult = true;

            // Restart the timer with the new duration
            _timer?.cancel();
            _startTimer();
          });
        }
        // Remove the immediate result display - let timer logic handle it
      } catch (e) {
        debugPrint('Error parsing declare time: $e');
      }
    }
  }

  // Show result from API immediately
  void _showResultFromAPI() {
    if (_resultData?.result != null && _resultData!.result!.length >= 3) {
      setState(() {
        final resultString = _resultData!.result!;
        _number1 = int.tryParse(resultString[0]) ?? 0;
        _number2 = int.tryParse(resultString[1]) ?? 0;
        _number3 = int.tryParse(resultString[2]) ?? 0;
        _combinedNumber = resultString;
        _showNumbers = true;
        _isWaitingForResult = false;

        // Stop spinning if it's currently spinning
        if (_isSpinning) {
          _isSpinning = false;
          _animationController.stop();
          _audioPlayer.stop();
        }
      });
    }
  }

  // Calculate timer duration based on market open and close times
  void _updateTimerBasedOnMarketData() {
    if (_marketData != null &&
        _marketData!.closeTime != null &&
        _marketData!.currentTime != null) {
      try {
        // Parse close time and current time (format expected: "HH:MM")
        final closeTimeParts = _marketData!.closeTime!.split(':');
        final currentTimeParts = _marketData!.currentTime!.split(':');

        if (closeTimeParts.length >= 2 && currentTimeParts.length >= 2) {
          final closeHour = int.parse(closeTimeParts[0]);
          final closeMinute = int.parse(closeTimeParts[1]);
          final currentHour = int.parse(currentTimeParts[0]);
          final currentMinute = int.parse(currentTimeParts[1]);

          // Calculate total seconds between current time and close time
          final closeTotalMinutes = closeHour * 60 + closeMinute;
          final currentTotalMinutes = currentHour * 60 + currentMinute;

          // Handle case where close time might be on the next day
          int diffMinutes = closeTotalMinutes - currentTotalMinutes;
          if (diffMinutes <= 0) {
            diffMinutes += 24 *
                60; // Add a full day if close time is earlier than current time
          }

          final diffSeconds = diffMinutes * 60;

          // Update the timer with the calculated duration
          setState(() {
            _seconds = diffSeconds;

            // Restart the timer with the new duration
            _timer?.cancel();
            _startTimer();
          });
        }
      } catch (e) {
        debugPrint('Error parsing market times: $e');
      }
    }
  }

  // Start periodic refresh of market data
  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _fetchMarketData(); // Refresh market data every 2 minutes
      _fetchResultData(); // Also refresh result data
    });
  }

  // Start result refresh timer
  void _startResultRefreshTimer() {
    _resultRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchResultData(); // Refresh result data every 30 seconds
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _refreshTimer?.cancel();
    _resultRefreshTimer?.cancel();
    _animationController.dispose();
    _arrowAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenHeight < 700;

    // Calculate responsive sizes
    final titleSize = screenWidth * 0.08;
    final headerSpacing =
        isSmallScreen ? screenHeight * 0.03 : screenHeight * 0.05;
    final buttonTextSize = screenWidth * 0.04;
    final timerSize = screenWidth * 0.07;
    final wheelSize = screenWidth * 0.8;
    final numberSize = screenWidth * 0.08;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/roulettebg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD9BC4C),
                ),
              )
            : _marketData == null
                ? _buildNoMarketAvailableUI(
                    context, screenHeight, screenWidth, titleSize)
                : SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.01),
                          // header
                          Text(
                            (_marketData!.name ?? 'Market').toTitleCase(),
                            style: TextStyle(
                              fontSize: titleSize,
                              fontFamily: 'Serif',
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD9BC4C), // Gold color
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.1),
                          // Custom roulette wheel with three rings
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Outer ring (gold color)
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  final double rotation;
                                  if (_isSpinning) {
                                    // During animation, use animated value
                                    final curvedValue = Curves.easeOut
                                        .transform(_animationController.value);
                                    rotation = curvedValue * _outerRingRotation;
                                  } else {
                                    // When not spinning, use the final rotation position
                                    rotation = _outerRingFinalRotation;
                                  }

                                  return Transform.rotate(
                                    angle: rotation,
                                    child: Container(
                                      width: wheelSize - 20,
                                      height: wheelSize - 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: CustomPaint(
                                        size: Size(wheelSize, wheelSize),
                                        painter: WheelPainter(
                                          numbers: _outerRingNumbers,
                                          color:
                                              const Color(0xFFD9BC4C), // Gold
                                          dividerColor:
                                              const Color(0xFF6A256E), // Purple
                                          textColor: Colors.black,
                                          numberTextSize: wheelSize * 0.08,
                                          textRadiusFactor:
                                              0.82, // Slightly adjusted for better positioning
                                          currentRotation:
                                              rotation, // Pass current rotation
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Middle ring (blue color)
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  final double rotation;
                                  if (_isSpinning) {
                                    // During animation, use animated value
                                    final curvedValue = Curves.easeOut
                                        .transform(_animationController.value);
                                    rotation =
                                        curvedValue * _middleRingRotation;
                                  } else {
                                    // When not spinning, use the final rotation position
                                    rotation = _middleRingFinalRotation;
                                  }

                                  return Transform.rotate(
                                    angle: rotation,
                                    child: Container(
                                      width: wheelSize * 0.65,
                                      height: wheelSize * 0.65,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: CustomPaint(
                                        size: Size(
                                            wheelSize * 0.65, wheelSize * 0.65),
                                        painter: WheelPainter(
                                          numbers: _middleRingNumbers,
                                          color: const Color(
                                              0xFF2851A3), // Darker blue like image
                                          dividerColor:
                                              const Color(0xFF6A256E), // Purple
                                          textColor: Colors.white,
                                          numberTextSize: wheelSize * 0.08,
                                          textRadiusFactor:
                                              0.73, // Standard position
                                          currentRotation:
                                              rotation, // Pass current rotation
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Inner ring (green color)
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  final double rotation;
                                  if (_isSpinning) {
                                    // During animation, use animated value
                                    final curvedValue = Curves.easeOut
                                        .transform(_animationController.value);
                                    rotation = curvedValue * _innerRingRotation;
                                  } else {
                                    // When not spinning, use the final rotation position
                                    rotation = _innerRingFinalRotation;
                                  }

                                  return Transform.rotate(
                                    angle: rotation,
                                    child: Container(
                                      width: wheelSize * 0.35,
                                      height: wheelSize * 0.35,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            blurRadius: 5,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: CustomPaint(
                                        size: Size(
                                            wheelSize * 0.35, wheelSize * 0.35),
                                        painter: WheelPainter(
                                          numbers: _innerRingNumbers,
                                          color: const Color(
                                              0xFF63995C), // More muted green like image
                                          dividerColor:
                                              const Color(0xFF6A256E), // Purple
                                          textColor: Colors.black,
                                          numberTextSize: wheelSize * 0.04,
                                          textRadiusFactor:
                                              0.73, // Slightly adjusted for better positioning
                                          currentRotation:
                                              rotation, // Pass current rotation
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Selection point indicator at the top with bounce animation
                              Positioned(
                                top: -40,
                                child: AnimatedBuilder(
                                  animation: _arrowBounceAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                          0, _arrowBounceAnimation.value),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.red,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.red.withOpacity(0.3),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Center result display
                              Container(
                                width: wheelSize * 0.18,
                                height: wheelSize * 0.18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF6A256E), // Purple
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _combinedNumber,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: wheelSize * 0.07,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.7),
                                        blurRadius: 5,
                                        offset: const Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Result numbers display below the wheel
                          AnimatedOpacity(
                            opacity: _showNumbers ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.015,
                                horizontal: screenWidth * 0.08,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A256E), // Solid purple
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: const Color(0xFFD9BC4C), // Gold border
                                  width: 3, // Thicker border
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildNumberCircle(_number1, numberSize,
                                      const Color(0xffd9bc4c)),
                                  SizedBox(width: screenWidth * 0.04),
                                  _buildNumberCircle(_number2, numberSize,
                                      const Color(0xff0735b9)),
                                  SizedBox(width: screenWidth * 0.04),
                                  _buildNumberCircle(_number3, numberSize,
                                      const Color(0xff63995c)),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Timer display
                          if (_resultData?.result == null)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/roulettetimer.png',
                                  height: screenHeight * 0.085,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTime(_seconds),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: timerSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_isWaitingForResult)
                                      Text(
                                        'Result at ${_resultData?.declareTime ?? ""}',
                                        style: TextStyle(
                                          color: const Color(0xFFD9BC4C),
                                          fontSize: timerSize * 0.4,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),

                          SizedBox(height: screenHeight * 0.02),

                          // Rules, Rates, and History buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RouletteRulesScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01,
                                      horizontal: screenWidth * 0.05),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF6A256E), // Purple color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Rules',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: buttonTextSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RouletteRatesScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01,
                                      horizontal: screenWidth * 0.05),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF6A256E), // Purple color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Rates',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: buttonTextSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RouletteHistoryMenuScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.01,
                                      horizontal: screenWidth * 0.05),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFF6A256E), // Purple color
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'History',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: buttonTextSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.01),

                          // // Test buttons row (for development/testing)
                          // if (_isTestMode) // Only show in debug mode
                          //   Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //     children: [
                          //       _buildTestButton("123", buttonTextSize,
                          //           screenHeight, screenWidth),
                          //       _buildTestButton("456", buttonTextSize,
                          //           screenHeight, screenWidth),
                          //       _buildTestButton("789", buttonTextSize,
                          //           screenHeight, screenWidth),
                          //       _buildTestButton("000", buttonTextSize,
                          //           screenHeight, screenWidth),
                          //     ],
                          //   ),

                          SizedBox(height: screenHeight * 0.02),

                          // Play Now button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RouletteGameMode(
                                    marketId: _marketData!.sId ?? "",
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(
                              "assets/images/rouletteplaynow.png",
                              height: screenHeight * 0.07,
                              width: screenWidth * 0.5,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  // Widget to show when no market is available
  Widget _buildNoMarketAvailableUI(BuildContext context, double screenHeight,
      double screenWidth, double titleSize) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: screenWidth * 0.25,
              color: const Color(0xFFD9BC4C),
            ),
            SizedBox(height: screenHeight * 0.03),
            Text(
              "No Market Available",
              style: TextStyle(
                fontSize: titleSize,
                fontFamily: 'Serif',
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD9BC4C), // Gold color
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              width: screenWidth * 0.8,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFF6A256E).withOpacity(0.7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(0xFFD9BC4C),
                  width: 2,
                ),
              ),
              child: Text(
                "Please check back later when markets are open.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            InkWell(
              onTap: () {
                _fetchMarketData(); // Retry fetching market data
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.08,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9BC4C),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  "Refresh",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRing(int count, double size, double radiusFactor) {
    return Stack(
      children: List.generate(count, (index) {
        final angle = 2 * pi * index / count;
        return Transform(
          transform: Matrix4.identity()
            ..translate(
              size / 2,
              size / 2,
            )
            ..rotateZ(angle)
            ..translate(
              0.0,
              -size * radiusFactor / 2,
            ),
          child: Container(
            width: size * 0.15,
            height: size * 0.15,
            alignment: Alignment.center,
            child: Transform(
              transform: Matrix4.identity()
                ..rotateZ(-angle), // Keep text upright
              child: Text(
                index.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumberCircle(int number, double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.65,
          fontWeight: FontWeight.w900,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.8),
              blurRadius: 3,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketInfoItem(String text, Color color, double size) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: size,
          color: color,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.8,
          ),
        ),
      ],
    );
  }

  // Fetch new market cycle when timer reaches 0
  Future<void> _fetchNewMarketCycle() async {
    setState(() {
      _isLoading = true;
      _showNumbers = false;
      _isWaitingForResult = false;
      _combinedNumber = '***'; // Reset to default
    });

    // Fetch new market data
    await _fetchMarketData();
  }

  /// Test function to spin the wheel with a specific result
  ///
  /// Usage: Call this function with a 3-digit string result to test the spin
  /// Example: _testSpin("123") will spin and show result 123
  void testSpin(String result) {
    if (result.length != 3) {
      debugPrint('Test result must be exactly 3 digits');
      return;
    }

    // Validate that all characters are digits
    if (!RegExp(r'^\d{3}$').hasMatch(result)) {
      debugPrint('Test result must contain only digits (0-9)');
      return;
    }

    debugPrint('=== STARTING TEST SPIN ===');
    debugPrint('Testing spin with result: $result');

    // Set test mode
    _isTestMode = true;
    _testResult = result;

    // Parse the result digits
    final digit1 = int.parse(result[0]);
    final digit2 = int.parse(result[1]);
    final digit3 = int.parse(result[2]);

    debugPrint('Target digits: [$digit1, $digit2, $digit3]');

    // Calculate target rotations to land on specific numbers
    _calculateRotationsForResult(digit1, digit2, digit3);

    // Start the spin animation
    setState(() {
      _isSpinning = true;
      _showNumbers = false;
      _combinedNumber = '***'; // Reset to default during spin
    });

    // Reset the animation controller before starting a new spin
    _animationController.reset();

    // Play the roulette clock sound
    _playRouletteSound();

    // Start the animation
    _animationController.forward();

    // For debugging: Also show the result immediately after a delay
    Timer(const Duration(milliseconds: 5500), () {
      debugPrint('=== TIMER FORCE SHOW TEST RESULT ===');
      if (_isTestMode && _testResult != null) {
        _showTestResult(_testResult!);
      }
    });
  }

  /// Calculate wheel rotations to land on specific numbers
  void _calculateRotationsForResult(int target1, int target2, int target3) {
    // Find the index of each target number in their respective rings
    final outerIndex = _outerRingNumbers.indexOf(target1);
    final middleIndex = _middleRingNumbers.indexOf(target2);
    final innerIndex = _innerRingNumbers.indexOf(target3);

    if (outerIndex == -1 || middleIndex == -1 || innerIndex == -1) {
      debugPrint('Invalid target numbers for rings');
      return;
    }

    // Each number occupies 1/10th of the wheel (36 degrees or π/5 radians)
    const anglePerSegment = 2 * pi / 10;

    // To position target number at the arrow (top), we need to rotate
    // the wheel so that the target number ends up at the arrow position
    // Since the wheel draws segments starting from top (-pi/2) and going clockwise,
    // to get number N at the top, we need to rotate counter-clockwise by N segments
    // Add a small fine-tuning adjustment for perfect arrow alignment
    const fineAdjustment =
        pi / 10; // Small adjustment for better alignment (~5 degrees)

    final rotationNeeded1 = -outerIndex * anglePerSegment - fineAdjustment;
    final rotationNeeded2 = -middleIndex * anglePerSegment - fineAdjustment;
    final rotationNeeded3 = -innerIndex * anglePerSegment - fineAdjustment;

    // Add multiple full rotations for the spinning effect (5-9 full spins)
    final baseRotations1 = (5 + _random.nextInt(5)) * 2 * pi;
    final baseRotations2 = (6 + _random.nextInt(5)) * 2 * pi;
    final baseRotations3 = (7 + _random.nextInt(5)) * 2 * pi;

    // Final rotation = base rotations + rotation needed to get target at top
    _outerRingRotation = baseRotations1 + rotationNeeded1;
    _middleRingRotation = baseRotations2 + rotationNeeded2;
    _innerRingRotation = baseRotations3 + rotationNeeded3;

    debugPrint('=== ROTATION CALCULATION ===');
    debugPrint('Target result: $target1$target2$target3');
    debugPrint('Target indices: [$outerIndex, $middleIndex, $innerIndex]');
    debugPrint(
        'Angle per segment: $anglePerSegment (${anglePerSegment * 180 / pi} degrees)');
    debugPrint(
        'Rotations needed: [$rotationNeeded1, $rotationNeeded2, $rotationNeeded3]');
    debugPrint(
        'Rotations in degrees: [${rotationNeeded1 * 180 / pi}, ${rotationNeeded2 * 180 / pi}, ${rotationNeeded3 * 180 / pi}]');
    debugPrint(
        'Base rotations: [$baseRotations1, $baseRotations2, $baseRotations3]');
    debugPrint(
        'Final rotations: [$_outerRingRotation, $_middleRingRotation, $_innerRingRotation]');
    debugPrint(
        'Final rotations in degrees: [${_outerRingRotation * 180 / pi}, ${_middleRingRotation * 180 / pi}, ${_innerRingRotation * 180 / pi}]');

    // Verify what should be at the top after rotation
    final verifyOuter = _getNumberIndexFromAngle(_outerRingRotation);
    final verifyMiddle = _getNumberIndexFromAngle(_middleRingRotation);
    final verifyInner = _getNumberIndexFromAngle(_innerRingRotation);
    debugPrint(
        'Verification - Numbers that should be at top: [$verifyOuter, $verifyMiddle, $verifyInner]');
  }

  /// Show the test result
  void _showTestResult(String result) {
    debugPrint('=== SHOW TEST RESULT ===');
    debugPrint('Input result: $result');

    if (result.length >= 3) {
      final newNumber1 = int.parse(result[0]);
      final newNumber2 = int.parse(result[1]);
      final newNumber3 = int.parse(result[2]);

      debugPrint('Parsed numbers: [$newNumber1, $newNumber2, $newNumber3]');

      setState(() {
        _number1 = newNumber1;
        _number2 = newNumber2;
        _number3 = newNumber3;
        _combinedNumber = result;
        _showNumbers = true;
      });

      debugPrint(
          'Test result set: $_combinedNumber ($_number1, $_number2, $_number3), Show: $_showNumbers');
    } else {
      debugPrint('ERROR: Test result length insufficient: ${result.length}');
    }
  }

  Widget _buildTestButton(String result, double buttonTextSize,
      double screenHeight, double screenWidth) {
    return InkWell(
      onTap: () {
        testSpin(result);
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.01,
          horizontal: screenWidth * 0.05,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF6A256E), // Purple color
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          result,
          style: TextStyle(
            color: Colors.white,
            fontSize: buttonTextSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Custom painter for drawing wheel sections
class WheelPainter extends CustomPainter {
  final List<int> numbers;
  final Color color;
  final Color dividerColor;
  final Color textColor;
  final double numberTextSize;
  final double textRadiusFactor;
  final double currentRotation; // Add current rotation parameter

  WheelPainter({
    required this.numbers,
    required this.color,
    required this.dividerColor,
    required this.textColor,
    this.numberTextSize = 24.0,
    this.textRadiusFactor = 0.75, // Default text radius factor
    this.currentRotation = 0.0, // Default rotation
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final count = numbers.length;
    final anglePerSection = 2 * pi / count;

    // Offset to start drawing from the top instead of from the right
    const startOffset = -pi / 2;

    // Draw segments
    for (int i = 0; i < count; i++) {
      final startAngle = startOffset + (i * anglePerSection);
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      // Use slightly different shades for alternating sections
      if (i % 2 == 0) {
        paint.color = color.withOpacity(0.9);
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        anglePerSection,
        true,
        paint,
      );

      // Draw divider lines
      final dividerPaint = Paint()
        ..color = dividerColor
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final outerX = center.dx + radius * cos(startAngle);
      final outerY = center.dy + radius * sin(startAngle);

      canvas.drawLine(
        center,
        Offset(outerX, outerY),
        dividerPaint,
      );

      // Draw number text
      final textPainter = TextPainter(
        text: TextSpan(
          text: numbers[i].toString(),
          style: TextStyle(
            color: textColor,
            fontSize: numberTextSize,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Calculate the position for the text in the middle of each segment
      final midAngle = startAngle + anglePerSection / 2;
      final textRadius =
          radius * textRadiusFactor; // Use the text radius factor

      // Calculate exact position for centered text
      final textX = center.dx + textRadius * cos(midAngle);
      final textY = center.dy + textRadius * sin(midAngle);

      // Save canvas state before applying counter-rotation
      canvas.save();

      // Move to text position and apply counter-rotation to keep text upright
      canvas.translate(textX, textY);
      canvas.rotate(
          -currentRotation); // Counter-rotate by negative current rotation

      // Draw text centered at origin (0,0) since we translated to the text position
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      // Restore canvas state
      canvas.restore();

      // Draw a small circle marker at the exact center point of each segment (debug)
      /*final debugPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(center.dx + textRadius * cos(midAngle), 
               center.dy + textRadius * sin(midAngle)), 
        2, 
        debugPaint);*/
    }

    // Draw outer circle border
    final borderPaint = Paint()
      ..color = dividerColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
