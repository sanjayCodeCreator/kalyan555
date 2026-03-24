import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sm_project/roulette/roulette_api_service.dart';
import 'package:sm_project/roulette/roulette_result_model.dart';

class RouletteResultHistoryScreen extends StatefulWidget {
  const RouletteResultHistoryScreen({
    super.key,
  });

  @override
  State<RouletteResultHistoryScreen> createState() =>
      _RouletteResultHistoryScreenState();
}

class _RouletteResultHistoryScreenState
    extends State<RouletteResultHistoryScreen> with TickerProviderStateMixin {
  final RouletteApiService _apiService = RouletteApiService();
  List<RouletteResultModel> _results = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  // Animation controllers
  late AnimationController _loadingController;
  late AnimationController _listController;
  late AnimationController _headerController;
  late Animation<double> _loadingAnimation;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadResults();
  }

  void _setupAnimations() {
    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.easeInOut,
    ));

    // List animation controller
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Header animation controller
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _headerSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutBack,
    ));
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeIn,
    ));

    // Start header animation
    _headerController.forward();

    // Start loading animation
    _loadingController.repeat();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _listController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Format selected date as yyyy-MM-dd for API query
      final queryDate =
          '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      final results = await _apiService.getResultsByDate(queryDate: queryDate);

      setState(() {
        _results = results;
        _isLoading = false;
      });

      // Animate list items
      if (_results.isNotEmpty) {
        _listController.forward();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading results: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A256E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _listController.reset();
      _loadResults();
    }
  }

  // No additional helpers needed in parent; per-item formatting handled in AnimatedResultCard

  Widget _buildAnimatedResultItem(RouletteResultModel result, int index) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        final animationValue = Curves.easeOutQuart.transform(
          (_listController.value - (index * 0.1)).clamp(0.0, 1.0),
        );

        return Transform.translate(
          offset: Offset(50 * (1 - animationValue), 0),
          child: Opacity(
            opacity: animationValue,
            child: child,
          ),
        );
      },
      child: AnimatedResultCard(result: result, index: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/roulettebg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Result History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF6A256E),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            AnimatedBuilder(
              animation: _headerController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * _headerFadeAnimation.value),
                  child: Opacity(
                    opacity: _headerFadeAnimation.value,
                    child: IconButton(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.date_range, color: Colors.white),
                      tooltip: 'Select Date',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Animated Date Display
            AnimatedBuilder(
              animation: _headerController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _headerSlideAnimation.value),
                  child: Opacity(
                    opacity: _headerFadeAnimation.value,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A256E).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFD9BC4C),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('MMM dd, yyyy')
                                    .format(_selectedDate),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9BC4C),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_results.length} Results',
                              style: const TextStyle(
                                color: Color(0xFF6A256E),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Results List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: AnimatedBuilder(
                        animation: _loadingAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _loadingAnimation.value * 2 * 3.14159,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD9BC4C),
                                  width: 3,
                                ),
                                gradient: SweepGradient(
                                  colors: [
                                    const Color(0xFFD9BC4C),
                                    const Color(0xFFD9BC4C).withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: Opacity(
                                      opacity: value,
                                      child: Icon(
                                        Icons.inbox,
                                        size: 48,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1000),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Text(
                                      'No results found',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 1200),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Text(
                                      'Try selecting a different date',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            _listController.reset();
                            await _loadResults();
                          },
                          color: const Color(0xFFD9BC4C),
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              return _buildAnimatedResultItem(
                                  _results[index], index);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedResultCard extends StatefulWidget {
  final RouletteResultModel result;
  final int index;

  const AnimatedResultCard({
    super.key,
    required this.result,
    required this.index,
  });

  @override
  State<AnimatedResultCard> createState() => _AnimatedResultCardState();
}

class _AnimatedResultCardState extends State<AnimatedResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _circleController;
  late Animation<double> _circleScaleAnimation;
  late Animation<double> _circleRotationAnimation;

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _circleScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _circleRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart),
    ));

    // Start circle animation with delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _circleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _circleController.dispose();
    super.dispose();
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy hh:mm a').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getResultColor(String? result) {
    if (result == null) return Colors.grey;

    try {
      final num = int.parse(result);
      if (num == 0) return Colors.green;
      if (num % 2 == 0) return Colors.red;
      return Colors.black;
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6A256E).withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD9BC4C),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Animated Result Number Circle
            AnimatedBuilder(
              animation: _circleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _circleScaleAnimation.value,
                  child: Transform.rotate(
                    angle: _circleRotationAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getResultColor(widget.result.result),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFD9BC4C),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: -_circleRotationAnimation.value,
                          child: Text(
                            widget.result.result ?? '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),

            // Result Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.result.marketName ?? 'Unknown Market',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFFD9BC4C),
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(widget.result.createdAt),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
