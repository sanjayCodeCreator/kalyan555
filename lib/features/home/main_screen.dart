import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/apiservices/api_service.dart';
import 'package:sm_project/controller/local/pref.dart';
import 'package:sm_project/controller/local/pref_names.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/chat/chat_screen.dart';
import 'package:sm_project/features/drawer/fund_screen.dart';
import 'package:sm_project/features/drawer/x_drawer.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/features/home/home_screen.dart';
import 'package:sm_project/features/home/my_bids_screen.dart';
import 'package:sm_project/features/home/transaction_history_screen.dart';
import 'package:sm_project/router/routes_names.dart';
import 'package:sm_project/utils/all_images.dart';
import 'package:sm_project/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Quiz/screens/start_quiz.dart';
import '../../utils/customization.dart';
import '../chat/chat_service.dart';

final bottomNavIndexProvider =
    StateProvider<int>((ref) => 2); // Default to Home (center)

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends ConsumerState<MainScreen> {
  // List of screens to display
  late final List<Widget> _screens;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _popupChecked = false; // ensure single fetch

  @override
  void initState() {
    super.initState();

    _screens = [
      const TransactionHistory(), // History screen
      const MyBidsScreen(),       // All Bids screen
      const HomeScreen(),         // Home screen
      const FundScreen(),         // Wallet screen
      const ChatScreen(),         // Replace with your Chat screen
    ];

    // Delay popup fetch till first frame to have context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndShowPopup();

      // --- 🚀 INITIALIZE SOCKET HERE ---
      // This connects the socket when the user logs in / enters MainScreen
      ChatService.instance.initialize();
      ChatService.instance.connect(role: 'user');
    });
  }
  @override
  void dispose() {
    // --- 🛑 CLEAN UP SOCKET HERE ---
    // This disconnects the socket when the user logs out or the app terminates the Main flow
    ChatService.instance.dispose();
    super.dispose();
  }
  Future<void> _fetchAndShowPopup() async {
    ref.read(homeNotifierProvider.notifier).getParticularPlayerModel(context);
    if (_popupChecked) return; // guard
    _popupChecked = true;
    final data = await ApiService().getPopupNotice();
    if (!mounted) return;
    try {
      if (data != null && data['status'] == 'success') {
        final dynamic dataValue = data['data'];
        final List list = (dataValue is List) ? dataValue : [];
        if (list.isNotEmpty) {
          final item = list.first as Map<String, dynamic>;
          final bool status = item['status'] == true;
          final String id = item['_id']?.toString() ?? '';
          final seen = Prefs.getStringList(PrefNames.seenPopupIds) ?? [];
          if (id.isNotEmpty && seen.contains(id)) return; // already seen
          // Only show if status true
          if (status) {
            _showPopupNotice(
              title: item['title']?.toString() ?? 'Notice',
              body:
                  item['body']?.toString() ?? item['message']?.toString() ?? '',
              button: item['button']?.toString() ?? 'OK',
              url: (item['url'] ?? item['link'])?.toString(),
              id: id,
            );
          }
        }
      }
    } catch (_) {
      // silently ignore parsing errors
    }
  }

  void _showPopupNotice({
    required String title,
    required String body,
    required String button,
    String? url,
    String? id,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (ctx) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          backgroundColor: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      darkBlue.withOpacity(0.95),
                      const Color(0xFF3A2754).withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rubik(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.4)),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _markPopupSeen(id);
                              Navigator.of(ctx).pop();
                            },
                            icon: const Icon(Icons.close_rounded),
                            label: const Text('Close'),
                          ),
                        ),
                        if (url != null && url.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBlue,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                final uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                }
                                if (ctx.mounted) {
                                  _markPopupSeen(id);
                                  Navigator.of(ctx).pop();
                                }
                              },
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: Text(button),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -32,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFC33F), Color(0xFFFF8C3F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.campaign_rounded,
                        size: 38, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () {
                    _markPopupSeen(id);
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _markPopupSeen(String? id) {
    if (id == null || id.isEmpty) return;
    final seen = Prefs.getStringList(PrefNames.seenPopupIds) ?? [];
    if (!seen.contains(id)) {
      seen.add(id);
      Prefs.setStringList(PrefNames.seenPopupIds, seen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final refWatch = ref.watch(homeNotifierProvider);

    if (refWatch.value?.getParticularPlayerModel?.data?.betting == null ||
        refWatch.value?.getParticularPlayerModel?.data?.betting == false) {
      return Scaffold(
          key: _scaffoldKey,
          drawer: const XDrawer(),
          appBar:  AppBar(
              backgroundColor: darkBlue,
              elevation: 0,
              centerTitle: false,
              shape: const Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 3,
                ),
              ),
              leading: InkWell(
                  onTap: () {
                    ref.read(homeNotifierProvider.notifier).onRefresh(context);
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(leadingLogo,
                        height: 30, width: 30, color: Colors.white),
                  )),
              title: Text(Customization.appname,
                  style: GoogleFonts.rubik(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              actions: [
                const SizedBox(width: 16),
                // notification icon

                if (refWatch.value?.getParticularPlayerModel?.data?.betting ==
                    null) ...{const SizedBox()}
              ]) ,
          body: const SafeArea(child: StartQuizScreen()));
    }

    // if (!(refWatch.value?.getParticularPlayerModel?.data?.betting ?? false)) {
    //   return const HomeScreen();
    // }
    bool _isExiting = false;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (_isExiting) return; // ✅ yaha block ho jayega

        if (!didPop) {
          _showExitDialog(context,_isExiting);
        }
      },
      child: Scaffold(
        body: _screens[selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Consumer(builder: (context, ref, _) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: selectedIndex,
                onTap: (index) {
                  if (index == 4) {
                    HapticFeedback.selectionClick();
                    // ref.read(homeNotifierProvider.notifier).launchWhatsapp(
                    //       ref
                    //               .watch(getSettingNotifierProvider)
                    //               .value
                    //               ?.getSettingModel
                    //               ?.data
                    //               ?.whatsapp ??
                    //           "",
                    //     );
                    context.pushNamed(RouteNames.chatScreen);
                    return;
                  }
                  ref.read(bottomNavIndexProvider.notifier).state = index;
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: darkBlue,
                unselectedItemColor: Colors.grey,
                selectedLabelStyle: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: GoogleFonts.rubik(
                  fontSize: 12,
                ),
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/transaction_history.png',
                      height: 24,
                      width: 24,
                      color: selectedIndex == 0 ? darkBlue : Colors.black87,
                    ),
                    label: 'History',
                    backgroundColor: Colors.white,
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/bid_history.png',
                      height: 24,
                      width: 24,
                      color: selectedIndex == 1 ? darkBlue : Colors.black87,
                    ),
                    label: 'All Bids',
                    backgroundColor: Colors.white,
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          CupertinoIcons.home,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    label: '',
                    backgroundColor: Colors.white,
                  ),
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/wallet.png',
                      height: 24,
                      width: 24,
                      color: selectedIndex == 3 ? darkBlue : Colors.black87,
                    ),
                    label: 'Wallet',
                    backgroundColor: Colors.white,
                  ),
                  const BottomNavigationBarItem(
                    // icon: Image.asset(
                    //   'assets/images/whatsapp.png',
                    //   height: 24,
                    //   width: 24,
                    // ),
                    icon: Icon(Icons.support_agent, size: 24,color: Colors.black,),
                    label: 'Support',
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context,bool _isExiting ) {
    const primaryGreen = Color(0xFF4CAF50);
    const lightGreen = Color(0xFF81C784);
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gradient
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryGreen, lightGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.exit_to_app_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Exit App',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_rounded,
                          size: 48,
                          color: primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Are you sure you want to quit?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You will be logged out from the app',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _isExiting = true; // ✅ VERY IMPORTANT
                                Navigator.of(context).pop();
                                Future.delayed(const Duration(milliseconds: 100), () {
                                  exit(0);
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                foregroundColor: Colors.grey[700],
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // dialog close
                                exit(0); // ✅ FULL KILL
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Exit',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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
      },
    );
  }
}
