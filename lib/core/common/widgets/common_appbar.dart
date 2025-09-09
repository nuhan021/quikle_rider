import 'package:flutter/material.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import '../../../core/common/styles/global_text_style.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CommonAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: getTextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      centerTitle: false,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        side: BorderSide(
          color: AppColors.primary, // yellow line
          width: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}