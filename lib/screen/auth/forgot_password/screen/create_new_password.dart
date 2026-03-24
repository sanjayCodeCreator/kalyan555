import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/utils/filecollection.dart';

import '../forgot_notifier/create_new_password_notifier.dart';

class CreateNewPassword extends HookConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  CreateNewPassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refRead = ref.read(createPasswordNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A11CB), // Vibrant Purple
                Color(0xFF2575FC), // Bright Blue
                Color(0xFF43C6AC), // Soft Green
                Color(0xFF191654), // Deep Blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // Top Illustration or Logo
                  Center(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Create New Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your new password must be unique from those previously used.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),
                  // Form Container
                  Consumer(builder: (context, ref, child) {
                    final refWatch = ref.watch(createPasswordNotifierProvider);
                    return Card(
                      elevation: 8,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Password",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              CustomTextFormField(
                                controller:
                                    refWatch.value?.passwordCreateController,
                                keyboardType: TextInputType.text,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(lockLogo,
                                      height: 20, width: 20),
                                ),
                                hintText: 'Enter Password',
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter Password';
                                  } else if (value.length != 6) {
                                    return 'Password must be 6 digits';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Confirm Password",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 10),
                              CustomTextFormField(
                                controller: refWatch
                                    .value?.confirmPasswordCreateController,
                                keyboardType: TextInputType.text,
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(lockLogo,
                                      height: 20, width: 20),
                                ),
                                hintText: 'Confirm Password',
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter Confirm Password';
                                  } else if (refWatch.value
                                          ?.passwordCreateController.text !=
                                      value) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 35),
                              ElevatedButton(
                                onPressed: () {
                                  if (!_formKey.currentState!.validate()) {
                                    log('Form is not valid');
                                  } else {
                                    refRead.createPassword(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 40),
                                  backgroundColor: Colors.blueAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Create Password',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Remember Password? ',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                context.pushNamed(RouteNames.logInScreen);
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
