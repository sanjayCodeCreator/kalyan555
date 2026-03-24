import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sm_project/screen/auth/forgot_password/forgot_notifier/forgot_notifier.dart';
import 'package:sm_project/utils/filecollection.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends HookConsumerWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ForgotPassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Back Button and Title
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        context.pop();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.arrow_back_ios,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'FORGOT PASSWORD',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        // Mobile phone illustration with lock
                        Container(
                          width: 80,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B7FA1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              // Phone screen
                              Positioned(
                                top: 10,
                                left: 10,
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock,
                                        color: Color(0xFFFF5722),
                                        size: 32,
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                              radius: 2,
                                              backgroundColor:
                                                  Color(0xFF6B7FA1)),
                                          SizedBox(width: 4),
                                          CircleAvatar(
                                              radius: 2,
                                              backgroundColor:
                                                  Color(0xFF6B7FA1)),
                                          SizedBox(width: 4),
                                          CircleAvatar(
                                              radius: 2,
                                              backgroundColor:
                                                  Color(0xFF6B7FA1)),
                                          SizedBox(width: 4),
                                          CircleAvatar(
                                              radius: 2,
                                              backgroundColor:
                                                  Color(0xFF6B7FA1)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Mobile Number Input
                        Consumer(
                          builder: (context, ref, child) {
                            final refWatch = ref.watch(forgotNotifierProvider);
                            return Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: TextFormField(
                                      controller:
                                          refWatch.value?.mobileNumbController,
                                      keyboardType: TextInputType.number,
                                      validator: (value) {
                                        if (value!.isEmpty)
                                          return "Please enter mobile number";
                                        if (value.length != 10)
                                          return "Must be 10 digits";
                                        return null;
                                      },
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Mobile Number',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 16,
                                        ),
                                        suffixIcon: Icon(
                                          Icons.phone_android,
                                          color: Colors.grey.shade500,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 32),

                                  // Submit Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          ref
                                              .read(forgotNotifierProvider
                                                  .notifier)
                                              .postForgot(context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: darkBlue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'SUBMIT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
