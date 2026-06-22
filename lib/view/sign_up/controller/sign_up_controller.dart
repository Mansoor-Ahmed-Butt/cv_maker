import 'package:flutter/widgets.dart';
import 'package:flutter_with_hive/view/sign_up/model/sign_up_model.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  static SignUpController get to => Get.find<SignUpController>();

  RxBool isPasswordVisible = false.obs;

  TextEditingController userName = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late SignUpModel signUpModel;

  @override
  void onInit() {
    super.onInit();
    signUpModel = SignUpModel(
      email: emailController.text,
      password: passwordController.text,
      userName: userName.text,
    );
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  @override
  void onClose() {
    userName.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
