import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:message_me_app/features/presentation/components/custom_network_image.dart';
import '/core/extensions/extensions.dart';
import '../../../../domain/entities/user.dart';

class SenderUserProfilePageAppBar extends SliverPersistentHeaderDelegate {
  BuildContext context;
  final UserEntity user;
  Tween<double>? profilePicTranslateTween;

  SenderUserProfilePageAppBar({required this.context, required this.user}) {
    profilePicTranslateTween = Tween<double>(
      begin: context.width(1) / 2 - 45 - 40 + 15,
      end: 40.0,
    );
  }

  static final appBarColorTween = ColorTween(
    begin: Colors.white,
    end: const Color(0XFF008069),
  );

  static final statusBarBrightnessTween = Tween<Brightness>(
    begin: Brightness.dark,
    end: Brightness.light,
  );

  static final appbarIconColorTween = ColorTween(
    begin: Colors.grey[800],
    end: Colors.white,
  );

  static final nameTranslateTween = Tween<double>(begin: 20.0, end: 0.0);

  static final nameFontSizeTween = Tween<double>(begin: 20.0, end: 16.0);

  static final profileImageRadiusTween = Tween<double>(begin: 3.5, end: 1.0);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final relativeScroll70px = min(shrinkOffset, 70) / 70;
    SystemChrome.setSystemUIOverlayStyle(
     const SystemUiOverlayStyle(
        statusBarColor:  Color.fromRGBO(29,39,51, 1),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Container(
      color: const Color.fromRGBO(29,39,51, 1),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            children: [
              Positioned(
                top: 15,
                left: 90,
                child: displayName(relativeScroll70px),
              ),
              Positioned(
                top: 5,
                left: profilePicTranslateTween!.transform(relativeScroll70px),
                child: displayProfilePicture(relativeScroll70px, user),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget displayProfilePicture(
      double relativeFullScrollOffset, UserEntity user) {
    return Transform(
      transform: Matrix4.identity()
        ..scale(
          profileImageRadiusTween.transform(relativeFullScrollOffset),
        ),
      child: Hero(
        tag: user.uId,
        child: CustomNetworkImage(imageUrl: user.profilePic),
      ),
    );
  }

  Widget displayName(double relativeFullScrollOffset) {
    if (relativeFullScrollOffset >= 0.8) {
      return Transform(
        transform: Matrix4.identity()
          ..translate(
            0.0,
            nameTranslateTween.transform((relativeFullScrollOffset - 0.8) * 5),
          ),
        child: Text(
          user.name,
          style: TextStyle(
            fontSize: nameFontSizeTween
                .transform((relativeFullScrollOffset - 0.8) * 5),
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  double get maxExtent => 120;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SenderUserProfilePageAppBar oldDelegate) {
    return true;
  }
}
