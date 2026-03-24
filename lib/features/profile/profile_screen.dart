import 'package:sm_project/controller/riverpod/profile_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(editProfileNotifierProvider.notifier).setData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackgroundColor,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: appColor,
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 13, 0, 0),
            child: InkWell(
                onTap: () {
                  context.pop();
                },
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: whiteBackgroundColor, width: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Padding(
                          padding: EdgeInsets.fromLTRB(10.0, 5, 5, 5),
                          child: Icon(Icons.arrow_back_ios,
                              size: 15, color: whiteBackgroundColor)))
                ])),
          ),
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: whiteBackgroundColor, fontSize: 18),
          ),
          iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer(builder: (context, ref, child) {
          final refWatch = ref.watch(editProfileNotifierProvider);
          final refRead = ref.read(editProfileNotifierProvider.notifier);
          return Column(children: [
            Column(children: [
              Image.asset(profileIcon)
              // Container(
              //     height: 140,
              //     width: 140,
              //     decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         border: Border.all(color: textColor),
              //         image: const DecorationImage(
              //             image: AssetImage(profileIcon), fit: BoxFit.cover)))
            ]),
            const SizedBox(height: 20),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: whiteBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: refWatch.value?.nameController,
                      keyboardType: TextInputType.text,
                      labelText: 'User Name',
                      prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(loginLogo, height: 20, width: 20)),
                      // hintText: 'Enter User Name',
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter user name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextFormField(
                        controller: refWatch.value?.emailController,
                        keyboardType: TextInputType.text,
                        labelText: 'Email Id',
                        prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(otpLogo, height: 20, width: 20)),
                        // hintText: 'Enter Email Id',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter email id';
                          }
                          return null;
                        }),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () {
                        toast('Mobile number can not be changed');
                      },
                      child: CustomTextFormField(
                        controller: refWatch.value?.mobileController,
                        enabled: false,
                        keyboardType: TextInputType.number,
                        labelText: 'Mobile Number',
                        prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(loginMobileLogo,
                                height: 20, width: 20)),
                        // hintText: 'Enter Mobile Number',
                      ),
                    ),

                    const SizedBox(height: 35),
                    // Button
                    InkWell(
                        onTap: () {
                          if (refWatch.value?.nameController.text.isEmpty ??
                              false) {
                            toast('User name can not be empty');
                          } else {
                            refRead.getProfileData(context);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: BoxDecoration(
                              color: lightBlue,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            'Save',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )),
                    const SizedBox(height: 5),
                  ],
                )),
          ]);
        }),
      )),
    );
  }
}
