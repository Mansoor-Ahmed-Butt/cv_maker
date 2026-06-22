import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_with_hive/core/themes.dart';
import 'package:flutter_with_hive/view/home_page/my_profile_screens/profile_controller.dart';
import 'package:flutter_with_hive/widgets/text/app_style.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    // Get.put safely handles already-registered controllers.
    // Using permanent:false so it's cleaned up when the tab is left.
    _controller = Get.put(ProfileController(), permanent: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.homeBackgroundColor1,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.homeBackgroundColor1,
              AppColors.homeBackgroundColor2,
              AppColors.homeBackgroundColor3,
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() => _controller.isEditing.value
              ? _EditProfileView(controller: _controller)
              : _ViewProfileView(controller: _controller)),
        ),
      ),
    );
  }
}

// ── View Mode ────────────────────────────────────────────────────────────────

class _ViewProfileView extends StatelessWidget {
  const _ViewProfileView({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Header ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _ProfileHeader(controller: controller),
        ),

        // ── Stats row ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                _StatCard(label: 'CVs Created', value: '12', icon: Icons.description_rounded, color: AppColors.appBlue),
                SizedBox(width: 12.w),
                _StatCard(label: 'Templates Used', value: '5', icon: Icons.grid_view_rounded, color: AppColors.appPurple),
                SizedBox(width: 12.w),
                _StatCard(label: 'Downloads', value: '8', icon: Icons.download_rounded, color: AppColors.appGreenC),
              ],
            ),
          ),
        ),

        // ── Info sections ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                _SectionCard(
                  title: 'About',
                  icon: Icons.person_outline_rounded,
                  child: Obx(() => Text(
                        controller.profile.value.bio.isEmpty
                            ? 'No bio added yet.'
                            : controller.profile.value.bio,
                        style: AppStyle.style14w400(color: AppColors.whiteColor.withValues(alpha: 0.75)).copyWith(height: 1.6),
                      )),
                ),
                SizedBox(height: 16.h),
                _SectionCard(
                  title: 'Contact',
                  icon: Icons.contact_mail_outlined,
                  child: Obx(() => Column(
                        children: [
                          _InfoRow(icon: Icons.email_outlined, value: controller.profile.value.email, placeholder: 'No email added'),
                          _InfoRow(icon: Icons.phone_outlined, value: controller.profile.value.phone, placeholder: 'No phone added'),
                          _InfoRow(icon: Icons.location_on_outlined, value: controller.profile.value.location, placeholder: 'No location added'),
                        ],
                      )),
                ),
                SizedBox(height: 16.h),
                _SectionCard(
                  title: 'Online Presence',
                  icon: Icons.public_rounded,
                  child: Obx(() => Column(
                        children: [
                          _InfoRow(icon: Icons.link_rounded, value: controller.profile.value.website, placeholder: 'No website added'),
                          _InfoRow(icon: Icons.work_outline_rounded, value: controller.profile.value.linkedin, placeholder: 'No LinkedIn added'),
                          _InfoRow(icon: Icons.code_rounded, value: controller.profile.value.github, placeholder: 'No GitHub added'),
                        ],
                      )),
                ),
                SizedBox(height: 100.h), // bottom nav clearance
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Edit Mode ────────────────────────────────────────────────────────────────

class _EditProfileView extends StatelessWidget {
  const _EditProfileView({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: CustomScrollView(
        slivers: [
          // ── Top bar ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: controller.cancelEditing,
                    icon: const Icon(Icons.close_rounded, color: AppColors.whiteColor),
                  ),
                  Expanded(
                    child: Text('Edit Profile', style: AppStyle.style18w700(color: AppColors.whiteColor), textAlign: TextAlign.center),
                  ),
                  Obx(() => controller.isSaving.value
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.appBlue, strokeWidth: 2)),
                        )
                      : TextButton(
                          onPressed: () => controller.saveProfile(context),
                          child: Text('Save', style: AppStyle.style16w600(color: AppColors.appBlue)),
                        )),
                ],
              ),
            ),
          ),

          // ── Avatar picker ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: Stack(
                children: [
                  _AvatarWidget(controller: controller, radius: 55.r),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => controller.pickAvatar(context),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.appBlue, AppColors.appPurple]),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Fields ──────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  _EditSection(title: 'Basic Info', children: [
                    _Field(label: 'Full Name', controller: controller.fullNameCtrl, icon: Icons.person_outline_rounded, validator: controller.validateRequired),
                    _Field(label: 'Job Title', controller: controller.jobTitleCtrl, icon: Icons.work_outline_rounded, hint: 'e.g. Senior Flutter Developer'),
                    _Field(label: 'Bio', controller: controller.bioCtrl, icon: Icons.notes_rounded, maxLines: 4, hint: 'Tell recruiters about yourself...'),
                  ]),
                  SizedBox(height: 20.h),
                  _EditSection(title: 'Contact', children: [
                    _Field(label: 'Email', controller: controller.emailCtrl, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: controller.validateEmail),
                    _Field(label: 'Phone', controller: controller.phoneCtrl, icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                    _Field(label: 'Location', controller: controller.locationCtrl, icon: Icons.location_on_outlined, hint: 'City, Country'),
                  ]),
                  SizedBox(height: 20.h),
                  _EditSection(title: 'Online Presence', children: [
                    _Field(label: 'Website', controller: controller.websiteCtrl, icon: Icons.link_rounded, keyboardType: TextInputType.url, hint: 'https://yoursite.com'),
                    _Field(label: 'LinkedIn', controller: controller.linkedinCtrl, icon: Icons.work_outline_rounded, hint: 'linkedin.com/in/username'),
                    _Field(label: 'GitHub', controller: controller.githubCtrl, icon: Icons.code_rounded, hint: 'github.com/username'),
                  ]),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.controller});
  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient banner
        Container(
          height: 160.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.appBlue, AppColors.appPurple, AppColors.appPink],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32.r),
              bottomRight: Radius.circular(32.r),
            ),
          ),
        ),

        // Edit button top-right
        Positioned(
          top: 12.h,
          right: 16.w,
          child: GestureDetector(
            onTap: controller.startEditing,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.whiteColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, color: AppColors.whiteColor, size: 14.r),
                  SizedBox(width: 6.w),
                  Text('Edit', style: AppStyle.style13w600(color: AppColors.whiteColor)),
                ],
              ),
            ),
          ),
        ),

        // Avatar + name block
        Padding(
          padding: EdgeInsets.only(top: 90.h),
          child: Column(
            children: [
              _AvatarWidget(controller: controller, radius: 50.r),
              SizedBox(height: 12.h),
              Obx(() => Text(
                    controller.profile.value.fullName.isEmpty ? 'Your Name' : controller.profile.value.fullName,
                    style: AppStyle.style22w700(color: AppColors.whiteColor),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: 4.h),
              Obx(() => Text(
                    controller.profile.value.jobTitle.isEmpty ? 'Add your job title' : controller.profile.value.jobTitle,
                    style: AppStyle.style14w400(color: AppColors.whiteColor.withValues(alpha: 0.7)),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: 6.h),
              Obx(() {
                final loc = controller.profile.value.location;
                if (loc.isEmpty) return const SizedBox.shrink();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_rounded, color: AppColors.appPink, size: 14.r),
                    SizedBox(width: 4.w),
                    Text(loc, style: AppStyle.style13w400(color: AppColors.whiteColor.withValues(alpha: 0.6))),
                  ],
                );
              }),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Avatar Widget ─────────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({required this.controller, required this.radius});
  final ProfileController controller;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.whiteColor, width: 3),
        boxShadow: [BoxShadow(color: AppColors.appBlue.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2)],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appBlue, AppColors.appPurple],
        ),
      ),
      child: ClipOval(
        child: Obx(() => controller.hasAvatar
            ? Image.file(File(controller.profile.value.avatarPath), fit: BoxFit.cover)
            : Center(
                child: Text(
                  controller.initials,
                  style: TextStyle(color: AppColors.whiteColor, fontSize: radius * 0.55, fontWeight: FontWeight.w700),
                ),
              )),
      ),
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.homeBackgroundColor2,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 12)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22.r),
            SizedBox(height: 6.h),
            Text(value, style: AppStyle.style20w700(color: AppColors.whiteColor)),
            SizedBox(height: 2.h),
            Text(label, style: AppStyle.style10w400(color: AppColors.whiteColor.withValues(alpha: 0.6)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.homeBackgroundColor2,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.appBlue, size: 18.r),
              SizedBox(width: 8.w),
              Text(title, style: AppStyle.style16w600(color: AppColors.whiteColor)),
            ],
          ),
          Divider(color: AppColors.whiteColor.withValues(alpha: 0.1), height: 20.h),
          child,
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value, required this.placeholder});
  final IconData icon;
  final String value;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, color: isEmpty ? AppColors.appGreyC : AppColors.appBlue, size: 18.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              isEmpty ? placeholder : value,
              style: AppStyle.style14w400(
                color: isEmpty ? AppColors.whiteColor.withValues(alpha: 0.3) : AppColors.whiteColor.withValues(alpha: 0.85),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit Section ──────────────────────────────────────────────────────────────

class _EditSection extends StatelessWidget {
  const _EditSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyle.style14w600(color: AppColors.appBlue)),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.homeBackgroundColor2,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.whiteColor.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: children
                .expand((w) => [w, SizedBox(height: 14.h)])
                .toList()
              ..removeLast(),
          ),
        ),
      ],
    );
  }
}

// ── Text Field ────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: AppStyle.style14w400(color: AppColors.whiteColor),
      cursorColor: AppColors.appBlue,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.appBlue, size: 18.r),
        labelStyle: AppStyle.style13w400(color: AppColors.whiteColor.withValues(alpha: 0.5)),
        hintStyle: AppStyle.style13w400(color: AppColors.whiteColor.withValues(alpha: 0.3)),
        filled: true,
        fillColor: AppColors.homeBackgroundColor1.withValues(alpha: 0.6),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.whiteColor.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.appBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.appPink),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.appPink, width: 1.5),
        ),
        errorStyle: AppStyle.style12w400(color: AppColors.appPink),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      ),
    );
  }
}
