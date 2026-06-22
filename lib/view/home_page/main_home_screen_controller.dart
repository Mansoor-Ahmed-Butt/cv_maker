import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_with_hive/view/home_page/my_home_screens/my_home_screen.dart';
import 'package:flutter_with_hive/view/home_page/my_profile_screens/my_profile_screen.dart';
import 'package:flutter_with_hive/view/home_page/my_resume_screens/my_resume_screen.dart';
import 'package:flutter_with_hive/view/home_page/template_screens/template_screen.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MainHomeScreenController extends GetxController {
  static MainHomeScreenController get to => Get.find();
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  // Index mapping (must match nav bar order):
  //  0 → Home
  //  1 → Templates
  //  2 → My CVs
  //  3 → Profile
  // The center "+" FAB is NOT a tab — it has no index.
  final List<Widget Function()> screenBuilders = [
    () => const AnimatedHomeScreen(),   // 0 - Home
    () => const TemplatesScreen(),       // 1 - Templates
    () => const MyResumesScreen(),       // 2 - My CVs
    () => const ProfileScreen(),         // 3 - Profile
  ];

  // ---------- Resume Dialog Data ----------
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final jobTitleController = TextEditingController();
  final locationController = TextEditingController();
  final summaryController = TextEditingController();

  final Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker picker = ImagePicker();

  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  // ---------- Pick Image ----------
  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  // ---------- Initialize Animation ----------
  void initAnimation(TickerProvider vsync) {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: vsync);
    scaleAnimation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack);
    animationController.forward();
  }

  // ---------- Clean Up ----------
  @override
  void onClose() {
    animationController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    jobTitleController.dispose();
    locationController.dispose();
    summaryController.dispose();
    super.onClose();
  }
}
