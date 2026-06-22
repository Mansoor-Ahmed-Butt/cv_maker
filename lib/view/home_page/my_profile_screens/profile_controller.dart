import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/home_page/my_profile_screens/profile_model.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find<ProfileController>();

  static const String _boxName = 'profileBox';
  static const String _profileKey = 'userProfile';

  // ── Reactive state ──────────────────────────────────────────────────────────
  final Rx<ProfileModel> profile = ProfileModel().obs;
  final RxBool isEditing = false.obs;
  final RxBool isSaving = false.obs;

  // ── Form controllers ────────────────────────────────────────────────────────
  late TextEditingController fullNameCtrl;
  late TextEditingController jobTitleCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController bioCtrl;
  late TextEditingController websiteCtrl;
  late TextEditingController linkedinCtrl;
  late TextEditingController githubCtrl;

  final formKey = GlobalKey<FormState>();

  // ── Hive box — grabbed synchronously, box is pre-opened in main.dart ─────────
  Box<ProfileModel> get _box => Hive.box<ProfileModel>(_boxName);

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _initTextControllers();
    _loadProfileSync(); // fully synchronous — no async, no await
  }

  @override
  void onClose() {
    fullNameCtrl.dispose();
    jobTitleCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    bioCtrl.dispose();
    websiteCtrl.dispose();
    linkedinCtrl.dispose();
    githubCtrl.dispose();
    super.onClose();
  }

  // ── Private helpers ───────────────────────────────────────────────────────────
  void _initTextControllers() {
    fullNameCtrl = TextEditingController();
    jobTitleCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    locationCtrl = TextEditingController();
    bioCtrl = TextEditingController();
    websiteCtrl = TextEditingController();
    linkedinCtrl = TextEditingController();
    githubCtrl = TextEditingController();
  }

  // Fully synchronous — the box is already open from main.dart so this
  // never blocks the main thread.
  void _loadProfileSync() {
    try {
      final saved = _box.get(_profileKey);
      if (saved != null) profile.value = saved;
      _syncControllersFromModel();
    } catch (e) {
      debugPrint('[ProfileController] _loadProfileSync error: $e');
    }
  }

  void _syncControllersFromModel() {
    final p = profile.value;
    fullNameCtrl.text = p.fullName;
    jobTitleCtrl.text = p.jobTitle;
    emailCtrl.text = p.email;
    phoneCtrl.text = p.phone;
    locationCtrl.text = p.location;
    bioCtrl.text = p.bio;
    websiteCtrl.text = p.website;
    linkedinCtrl.text = p.linkedin;
    githubCtrl.text = p.github;
  }

  // ── Edit / Save / Cancel ──────────────────────────────────────────────────────
  void startEditing() => isEditing.value = true;

  void cancelEditing() {
    isEditing.value = false;
    _syncControllersFromModel();
  }

  Future<void> saveProfile(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    try {
      final updated = ProfileModel(
        fullName: fullNameCtrl.text.trim(),
        jobTitle: jobTitleCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        location: locationCtrl.text.trim(),
        bio: bioCtrl.text.trim(),
        website: websiteCtrl.text.trim(),
        linkedin: linkedinCtrl.text.trim(),
        github: githubCtrl.text.trim(),
        avatarPath: profile.value.avatarPath,
      );
      await _box.put(_profileKey, updated);
      profile.value = updated;
      isEditing.value = false;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile saved successfully'),
            backgroundColor: AppColors.appGreenC,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20.r),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      isSaving.value = false;
    }
  }

  // ── Avatar picker ─────────────────────────────────────────────────────────────
  Future<void> pickAvatar(BuildContext context) async {
    final source = await _showImageSourceDialog(context);
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;

    final updated = ProfileModel(
      fullName: profile.value.fullName,
      jobTitle: profile.value.jobTitle,
      email: profile.value.email,
      phone: profile.value.phone,
      location: profile.value.location,
      bio: profile.value.bio,
      website: profile.value.website,
      linkedin: profile.value.linkedin,
      github: profile.value.github,
      avatarPath: picked.path,
    );
    await _box.put(_profileKey, updated);
    profile.value = updated;
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.homeBackgroundColor2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Photo',
                style: TextStyle(color: AppColors.whiteColor, fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.appBlue),
                title: Text('Camera', style: TextStyle(color: AppColors.whiteColor, fontSize: 14.sp)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.appPurple),
                title: Text('Gallery', style: TextStyle(color: AppColors.whiteColor, fontSize: 14.sp)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Validators ────────────────────────────────────────────────────────────────
  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  bool get hasAvatar {
    final path = profile.value.avatarPath;
    if (path.isEmpty) return false;
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }

  String get initials {
    final name = profile.value.fullName.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name[0].toUpperCase();
  }
}
