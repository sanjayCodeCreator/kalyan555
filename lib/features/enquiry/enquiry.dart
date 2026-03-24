import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/riverpod/homescreem_notifier.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class Enquiry extends ConsumerStatefulWidget {
  const Enquiry({super.key});

  @override
  ConsumerState<Enquiry> createState() => _EnquiryState();
}

class _EnquiryState extends ConsumerState<Enquiry> {
  @override
  void initState() {
    super.initState();
    ref.read(homeNotifierProvider.notifier).getParticularPlayerModel(context);
  }

  void _launchWhatsApp() async {
    final refRead = ref.read(homeNotifierProvider.notifier);
    final setting = ref.read(getSettingNotifierProvider).value;
    final whatsapp = setting?.getSettingModel?.data?.whatsapp ?? "";

    if (whatsapp.isNotEmpty) {
      refRead.launchWhatsapp(whatsapp);
    } else {
      toast("WhatsApp number not available", context: context);
    }
  }

  void _makePhoneCall() async {
    final refRead = ref.read(homeNotifierProvider.notifier);
    final setting = ref.watch(getSettingNotifierProvider).value;
    final mobile = setting?.getSettingModel?.data?.mobile ?? "";

    if (mobile.isNotEmpty) {
      refRead.launchCall(mobile);
    } else {
      toast("Phone number not available", context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final setting = ref.watch(getSettingNotifierProvider).value;
    final mobile = setting?.getSettingModel?.data?.mobile ?? "";
    final whatsapp = setting?.getSettingModel?.data?.whatsapp ??
        setting?.getSettingModel?.data?.mobile ??
        "";

    // Color scheme matching login screen design
    const primaryGreen = Color(0xFF4CAF50);
    const lightGreen = Color(0xFF81C784);
    const backgroundColor = Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          "Enquiry",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryGreen, lightGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    60,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Illustration
                    Container(
                      height: 250,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              'assets/images/enquiry.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Title
                    Text(
                      'Get in Touch',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact us for any queries or support',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Contact Buttons
                    Row(
                      children: [
                        // WhatsApp Button
                        Expanded(
                          child: _buildContactButton(
                            title: "Chat Now",
                            icon: 'assets/images/whatsapp.png',
                            backgroundColor: const Color(0xFF25D366),
                            number: whatsapp,
                            onTap: _launchWhatsApp,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Call Button
                        Expanded(
                          child: _buildContactButton(
                            title: "Call Now",
                            icon: 'assets/images/phone.png',
                            backgroundColor: primaryGreen,
                            number: mobile,
                            onTap: _makePhoneCall,
                            useIconData: true,
                            iconData: Icons.phone,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required String title,
    required String icon,
    IconData? iconData,
    bool useIconData = false,
    required Color backgroundColor,
    required String number,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: useIconData
                      ? Icon(
                          iconData ?? Icons.chat_bubble_outline_rounded,
                          size: 28,
                          color: Colors.white,
                        )
                      : Image.asset(
                          icon,
                          width: 28,
                          height: 28,
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                number,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
