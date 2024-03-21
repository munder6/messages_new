import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

import '../../../../../core/functions/navigator.dart';
import '../../../../../core/shared/commen.dart';
import '../../../../../core/utils/routes/routes_manager.dart';

class SelectImageFromGalleryButton extends StatelessWidget {
  final String receiverId;

  const SelectImageFromGalleryButton({
    super.key,
    required this.receiverId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        selectImageFromGallery(context);
      },
      child: const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.black38,
        child: Icon(
          FluentIcons.image_24_regular,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }

  void selectImageFromGallery(BuildContext context) async {
    File? image = await pickImageFromGallery(context);
    //if (!mounted) return;
    if (image != null) {
      // ignore: use_build_context_synchronously
      navigateTo(
        context,
        Routes.sendingImageViewRoute,
        arguments: {
          'path': image.path,
          'uId': receiverId,
        },
      );
    }
  }
}
