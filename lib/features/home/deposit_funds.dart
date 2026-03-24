import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sm_project/controller/local/user_particular_player.dart';
import 'package:sm_project/controller/model/create_transaction_model.dart';
import 'package:sm_project/controller/model/get_particular_player_model.dart';
import 'package:sm_project/controller/model/get_setting_model.dart' as setting;
import 'package:sm_project/controller/riverpod/auth_notifier/get_a_particular_notifier.dart';
import 'package:sm_project/controller/riverpod/withdrawal_notifier.dart';
import 'package:sm_project/features/home/get_setting_notifier.dart';
import 'package:sm_project/features/home/transaction_notifier.dart';
import 'package:sm_project/features/withdrawal_deposit_leaderboard/vertical_leaderboard_text.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'package:uuid/uuid.dart';

import '../../utils/customization.dart';

class Deposit extends ConsumerStatefulWidget {
  const Deposit({super.key});

  @override
  ConsumerState<Deposit> createState() => _DepositState();
}

class _DepositState extends ConsumerState<Deposit> {
  final Data? userDgetParticularUserData =
      UserParticularPlayer.getParticularUserData();

  List<ApplicationMeta>? apps;
  Future<UpiTransactionResponse>? _transaction;
  double amount = 0.0;

  String? txnId, txnRef, status;
  final uuid = const Uuid();

  setting.GetSettingModel? getSettingModel = setting.GetSettingModel();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController? depositController = TextEditingController();

  @override
  void initState() {
    super.initState();
    EasyLoading.show(status: 'loading...');
    _fetchInstalledApps();
    getSetting();
    EasyLoading.dismiss();
  }

  Future<void> _fetchInstalledApps() async {
    try {
      final value = await UpiPay.getInstalledUpiApplications();
      if(mounted) {
        setState(() {
          apps = value;
        });
      }
    } catch (e) {
      log("Error fetching UPI apps: $e");
      if(mounted) setState(() => apps = []);
    }
  }
  Future<void> getSetting() async {
    EasyLoading.show(status: 'loading...');
    getSettingModel = await ApiService().getSettingModel();
    EasyLoading.dismiss();
  }

  Future<String> getTransactionReferenceId() async {
    var id = userDgetParticularUserData?.sId;
    if (id != null && id.isNotEmpty) {
      var transRefId = uuid.v1().substring(0, 21).trim();
      return transRefId;
    } else {
      return "UserNotLoggedIn";
    }
  }

  Future<UpiTransactionResponse> initiateTransaction(ApplicationMeta appMeta) async {
    amount = double.parse(depositController?.text ?? '0');

    return await UpiPay.initiateTransaction(
      app: appMeta.upiApplication,
      receiverUpiAddress: getSettingModel?.data?.merchantUpi ?? '',
      receiverName: getSettingModel?.data?.merchantName ?? '',
      transactionRef: await getTransactionReferenceId(),
      transactionNote: 'deposit funds',
      amount: amount.toStringAsFixed(2),
    );
  }
  Widget displayUpiApps() {
    if (apps == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.grey),
              SizedBox(height: 10),
              Text("Loading payment options...", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    } else if (apps!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 40, color: Colors.grey),
              SizedBox(height: 10),
              Text("No apps found to handle transaction.", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      );
    } else {
      return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15.0,
            mainAxisSpacing: 15.0,
          ),
          itemCount: apps!.length,
          itemBuilder: (context, index) {
            ApplicationMeta appMeta = apps![index];
            return GestureDetector(
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _transaction = initiateTransaction(appMeta);
                  });
                  context.pop(); // Close bottom sheet after picking app
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xffE6E6E6)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    appMeta.iconImage(45),
                    const SizedBox(height: 10),
                    Text(
                      appMeta.upiApplication.getAppName(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: textColor),
                    )
                  ],
                ),
              ),
            );
          }
      );
    }
  }

  // Api response Send to server

  Future<void> submitDepositApi(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading...');
      await ref
          .read(getParticularPlayerNotifierProvider.notifier)
          .getParticularPlayerModel();
      Map<String, dynamic> body = {
        "user_id": ref
                .watch(getParticularPlayerNotifierProvider)
                .value
                ?.getParticularPlayerModel
                ?.data
                ?.sId ??
            "",
        'amount': depositController?.text,
        'transfer_type': 'upi',
        'note': 'deposit request',
        "type": "mobile",
        'ref_id': txnRef,
        'tax_id': txnId,
        'status': status?.toLowerCase(),
      };

      log(body.toString());
      CreateTransactionModel? response =
          await ApiService().postCreateTransaction(body);
      if (response?.status == 'success') {
        EasyLoading.dismiss();
        toast(response?.message ?? '');
        if (context.mounted) {
          context.pushReplacementNamed(RouteNames.homeScreen);
        }
      } else {
        EasyLoading.dismiss();
        toast(response?.message ?? '');
      }
    } catch (e) {
      EasyLoading.dismiss();
      log(e.toString(), name: 'editProfileApi');
    }
  }

  void _checkTxnStatus(UpiTransactionResponse response) async {
    switch (response.status) {
      case UpiTransactionStatus.success:
        txnId = response.txnId;
        txnRef = response.txnRef;
        status = 'success';
        await submitDepositApi(context);
        debugPrint('Transaction Successful');
        break;

      case UpiTransactionStatus.failure:
        log('Transaction Failed with code: ${response.responseCode}');
        toast('Transaction Failed. Please try again.');
        break;

      case UpiTransactionStatus.submitted:
        toast('Transaction Submitted/Pending');
        break;

      default:
        toast('Transaction was not completed');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingModel = ref.watch(getSettingNotifierProvider).value;

    final safeArea = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (user + balance)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userDgetParticularUserData?.userName ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userDgetParticularUserData?.mobile ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Available Balance',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Consumer(builder: (context, ref, _) {
                        final refWatch =
                            ref.watch(getWithdrawalNotifierProvider);
                        return Text(
                          '₹ ${refWatch.value?.leftPoints ?? 0}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount Input (underline with large ₹)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '₹',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: depositController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: '',
                        contentPadding: const EdgeInsets.only(bottom: 8),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: darkBlue, width: 1.6),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: darkBlue, width: 2),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                        focusedErrorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter points';
                        } else if (int.tryParse(value) == null) {
                          return 'Invalid amount';
                        } else if (int.parse(value) <
                            (getSettingModel?.data?.deposit?.min ?? 0)) {
                          return 'Minimum deposit value ${getSettingModel?.data?.deposit?.min ?? 0}';
                        } else if (int.parse(value) >
                            (getSettingModel?.data?.deposit?.max ?? 0)) {
                          return 'Maximum deposit value ${getSettingModel?.data?.deposit?.max ?? 0}';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Quick Amount Selection
              Text(
                'Quick Amount',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: depositAmountlist().length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisExtent: 50,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final data = depositAmountlist()[index];
                  return InkWell(
                    onTap: () {
                      depositController?.text = data['amount'];
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: darkBlue.withOpacity(0.35)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          "₹${data['amount']}",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: darkBlue,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // UPI Apps Section
              Text(
                'Select Payment Method',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              displayUpiApps(),

              const SizedBox(height: 24),

              // Deposit Notice
              Consumer(builder: (context, ref, _) {
                final getSettingModel =
                    ref.watch(getSettingNotifierProvider).value;
                final depositText =
                    getSettingModel?.getSettingModel?.data?.depositText;

                if (depositText != null &&
                    depositText.isNotEmpty &&
                    depositText != '-') {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      depositText,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              }),

              FutureBuilder<UpiTransactionResponse>(
                future: _transaction,
                builder: (BuildContext context, AsyncSnapshot<UpiTransactionResponse> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      log("UPI Error: ${snapshot.error}");
                      return const SizedBox();
                    }

                    if (snapshot.hasData) {
                      final response = snapshot.data!;
                      if (mounted) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _checkTxnStatus(response);
                        });
                      }
                    }
                    return const SizedBox();
                  }
                  return const SizedBox();
                },
              ),
            ],
          )),
    );

    if ((settingModel?.getSettingModel?.data?.upiPay ?? true) == false &&
        (settingModel?.getSettingModel?.data?.qrPay ?? true) == false) {
      return Scaffold(
        appBar: AppBar(
          leading: context.canPop()
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 13, 0, 0),
                  child: InkWell(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: whiteBackgroundColor, width: 0.6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                                padding: EdgeInsets.fromLTRB(12.0, 10, 7, 10),
                                child: Icon(Icons.arrow_back_ios,
                                    size: 15, color: whiteBackgroundColor)))
                      ])),
                )
              : null,
          backgroundColor: Colors.black,
          title: const Text(
            "ADD FUND",
            style: TextStyle(color: whiteBackgroundColor, fontSize: 18),
          ),
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [Center(child: Text("Please Contact to Admin"))],
            ),
          ),
        ),
      );
    }

    return Consumer(builder: (context, ref, _) {
      return DefaultTabController(
        length: (settingModel?.getSettingModel?.data?.upiPay ?? true) == true &&
                (settingModel?.getSettingModel?.data?.qrPay ?? true) == true
            ? 2
            : 1,
        child: Scaffold(
            backgroundColor: whiteBackgroundColor,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: darkBlue,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: context.canPop()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          size: 18, color: Colors.white),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    )
                  : null,
              title: Text(
                "ADD FUND",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              bottom: TabBar(
                indicatorColor: Colors.white,
                indicatorWeight: 2,
                labelStyle: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.6),
                tabs: (settingModel?.getSettingModel?.data?.upiPay ?? true) ==
                            true &&
                        (settingModel?.getSettingModel?.data?.qrPay ?? true) ==
                            true
                    ? [
                        const Tab(text: "Pay by UPI ID"),
                        const Tab(text: "Pay by QR Code"),
                      ]
                    : (settingModel?.getSettingModel?.data?.upiPay ?? true) ==
                            true
                        ? [
                            const Tab(text: "Pay by UPI ID"),
                          ]
                        : [
                            const Tab(text: "Pay by QR Code"),
                          ],
              ),
            ),
            body: Column(
              children: [
                const SizedBox(height: 12),
                // Red Days Banner
                const TextCycleWidget(filter: TextCycleFilter.deposit),
                Expanded(
                  child: Container(
                    color: whiteBackgroundColor,
                    child: TabBarView(
                      children: (settingModel?.getSettingModel?.data?.upiPay ??
                                      true) ==
                                  true &&
                              (settingModel?.getSettingModel?.data?.qrPay ??
                                      true) ==
                                  true
                          ? [
                              safeArea,
                              qrCode(),
                            ]
                          : (settingModel?.getSettingModel?.data?.upiPay ??
                                      true) ==
                                  true
                              ? [safeArea]
                              : [qrCode()],
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }

  Widget qrCode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Deposit points to your Wallet.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // QR Code Section
          Text(
            'Scan QR Code',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Consumer(builder: (context, ref, _) {
                final getSettingModel =
                    ref.watch(getSettingNotifierProvider).value;
                final merchantQRUPI =
                    getSettingModel?.getSettingModel?.data?.merchantQrUpi ?? "";
                return Column(
                  children: [
                    // Generated QR Code
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: UPIPaymentQRCode(
                        upiDetails: UPIDetails(
                          upiID: merchantQRUPI,
                          payeeName: "${Customization.appname}",
                          amount: 500,
                          transactionNote: "deposit funds",
                        ),
                        size: 140,
                        upiQRErrorCorrectLevel: UPIQRErrorCorrectLevel.high,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Scan this QR code with any UPI app",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // UPI ID Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "UPI ID",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Consumer(builder: (context, ref, _) {
                                  final getSettingModel = ref
                                      .watch(getSettingNotifierProvider)
                                      .value;
                                  return Text(
                                    getSettingModel?.getSettingModel?.data
                                            ?.merchantUpi ??
                                        "",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Consumer(builder: (context, ref, _) {
                            final getSettingModel =
                                ref.watch(getSettingNotifierProvider).value;
                            return IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                  text: getSettingModel?.getSettingModel?.data
                                          ?.merchantUpi ??
                                      "",
                                ));
                                toast("UPI ID copied to clipboard");
                              },
                              icon: Icon(
                                Icons.copy,
                                color: darkBlue,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 24),

          // Upload Screenshot Section
          Text(
            "Upload Payment Screenshot",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Consumer(builder: (context, ref, _) {
            final refRead = ref.read(transactionNotifierProvider.notifier);
            final data = ref.watch(transactionNotifierProvider).value;
            return InkWell(
              onTap: () {
                refRead.pickImage();
              },
              child: Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  image: data?.file == null
                      ? null
                      : DecorationImage(
                          image: FileImage(
                            File(data?.file?.path ?? ""),
                          ),
                          fit: BoxFit.cover,
                        ),
                ),
                child: data?.file == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_rounded,
                            size: 32,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Tap to upload screenshot",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          onPressed: () {
                            refRead.pickImage();
                          },
                        ),
                      ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Amount Input
          Text(
            "Enter Amount",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Consumer(builder: (context, ref, _) {
            final refRead = ref.read(transactionNotifierProvider.notifier);
            final refWatch = ref.watch(transactionNotifierProvider).value;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextFormField(
                controller: refWatch?.amountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                decoration: InputDecoration(
                  hintText: 'Deposit Points',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: darkBlue,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(),
                  prefixIcon: Container(
                    margin: const EdgeInsets.only(left: 16, right: 8),
                    child: const Icon(Icons.account_balance_wallet,
                        color: Color(0xFF4CAF50)),
                  ),
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Text(
                      'Points',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  suffixIconConstraints:
                      const BoxConstraints(minWidth: 0, minHeight: 0),
                ),
                onChanged: (value) {
                  refRead.updateAmount(value);
                },
              ),
            );
          }),
          const SizedBox(height: 24),

          // Submit Button
          Consumer(builder: (context, ref, _) {
            final refRead = ref.read(transactionNotifierProvider.notifier);
            return InkWell(
              onTap: () async {
                refRead.sumbmitData();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Deposit Notice
          Consumer(builder: (context, ref, _) {
            final getSettingModel = ref.watch(getSettingNotifierProvider).value;
            final depositText =
                getSettingModel?.getSettingModel?.data?.depositText;

            if (depositText != null &&
                depositText.isNotEmpty &&
                depositText != '-') {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  depositText,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          }),
        ],
      ),
    );
  }

  List depositAmountlist() {
    return [
      {
        'amount': '300',
        'click': () {
          depositController?.text = '300';
        },
      },
      {
        'amount': '500',
        'click': () {
          depositController?.text = '500';
        },
      },
      {
        'amount': '1000',
        'click': () {
          depositController?.text = '1000';
        },
      },
      {
        'amount': '2000',
        'click': () {
          depositController?.text = '2000';
        },
      },
      {
        'amount': '5000',
        'click': () {
          depositController?.text = '5000';
        },
      },
      {
        'amount': '10000',
        'click': () {
          depositController?.text = '10000';
        },
      },
    ];
  }
}
