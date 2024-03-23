import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:message_me_app/core/extensions/time_extension.dart';
import 'package:message_me_app/core/utils/constants/strings_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swipe_to/swipe_to.dart';
import '../../../../../../core/enums/messge_type.dart';
import '../../../../../../core/utils/thems/my_colors.dart';
import '../../../../../../focused_menu.dart';
import '../../../../../../modals.dart';
import '../../../../../../test.dart';
import '/core/extensions/extensions.dart';
import '../../../../../domain/entities/message.dart';
import '../../../../controllers/chat_cubit/chat_cubit.dart';
import '../message_content/message_content.dart';
import 'message_replay_card.dart';

class MyMessageCard extends StatefulWidget {
  final Message message;
  final bool isFirst;
  final bool isLast;
  final bool isLastForSeen;

  const MyMessageCard({
    Key? key,
    required this.message,
    required this.isFirst,
    required this.isLast,
    required this.isLastForSeen,
  }) : super(key: key);

  @override
  State<MyMessageCard> createState() => _MyMessageCardState();
}

class _MyMessageCardState extends State<MyMessageCard> {
  @override
  Widget build(BuildContext context) {
    final isReplying = widget.message.repliedMessage.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isReplying)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: widget.message.messageType == MessageType.video  ? context.width(0.25) : context.width(0.6),
                    ),
                    child: ReplayMessageCard(
                      text: widget.message.repliedMessage,
                      repliedMessageType: widget.message.repliedMessageType,
                      isMe: widget.message.repliedTo == widget.message.senderName,
                      repliedTo: widget.message.repliedTo,
                    ),
                  ),
                ),
              Container(
                height: 35,
                width: 3,
                decoration: BoxDecoration(
                  color: AppColorss.replyContainerColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(""),
              ),
              const SizedBox(width: 16),
            ],
          ),
        SwipeTo(
          iconOnLeftSwipe: FluentIcons.arrow_hook_up_left_24_filled,
          animationDuration: Duration(milliseconds: 200),
          onLeftSwipe: (D) {
            ChatCubit.get(context).onMessageSwipe(
              message: widget.message.text,
              isMe: true,
              messageType: widget.message.messageType,
              repliedTo: widget.message.senderName,
            );
          },
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(top: 2, right: widget.isFirst ? 5 : 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FocusedMenuHolder(
                    blurSize: 9,
                    animateMenuItems: true,
                    menuOffset: 8,
                    duration : const Duration(milliseconds: 300),
                    menuBoxDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0), // Adjust the radius as needed
                      color:AppColorss.thirdColor, // Change the background color as needed
                    ),
                    menuWidth: MediaQuery.of(context).size.width * 0.48,
                    menuItems: [
                      FocusedMenuItem(
                        backgroundColor : AppColorss.thirdColor2,
                        title: Text(widget.message.timeSent.foucesdMenueCard, style: TextStyle(color: AppColorss.textColor2),),
                        onPressed: () {},
                      ),
                      if(widget.message.messageType == MessageType.image)
                        FocusedMenuItem(
                            backgroundColor : AppColorss.thirdColor2,
                            title: Text(AppStringss.save),
                            trailingIcon: const Icon(FluentIcons.arrow_circle_down_24_regular),
                            onPressed: (){
                              _SaveImage(context);
                            }
                        ),
                      if(widget.message.messageType == MessageType.video)
                        FocusedMenuItem(
                            backgroundColor : AppColorss.thirdColor2,
                            title: Text(AppStringss.save),
                            trailingIcon: const Icon(FluentIcons.arrow_circle_down_24_regular),
                            onPressed: (){
                              _saveVideo();
                            }
                        ),
                      if(widget.message.isLiked)
                        FocusedMenuItem(
                          backgroundColor : AppColorss.thirdColor2,
                          trailingIcon: Icon(FluentIcons.heart_broken_24_regular, color: AppColorss.iconsColors),
                          title: Text(AppStringss.unlike),
                          onPressed: () async {
                            final firestore = FirebaseFirestore.instance;
                            final userId = widget.message.senderId;
                            final chatId = widget.message.receiverId;
                            await firestore
                                .collection('users')
                                .doc(userId)
                                .collection('chats')
                                .doc(chatId)
                                .collection('messages')
                                .doc(widget.message.messageId)
                                .update({
                              'isLiked': false,
                            });
                            final userId2 = widget.message.receiverId;
                            final chatId2 = widget.message.senderId;
                            await firestore
                                .collection('users')
                                .doc(userId2)
                                .collection('chats')
                                .doc(chatId2)
                                .collection('messages')
                                .doc(widget.message.messageId)
                                .update({
                              'isLiked': false,
                            });
                          },
                        ),
                      FocusedMenuItem(
                        backgroundColor : AppColorss.thirdColor2,
                        trailingIcon: Icon(FluentIcons.arrow_hook_up_left_24_filled, color: AppColorss.iconsColors),
                        title: Text(AppStringss.reply),
                        onPressed: () async {
                          ChatCubit.get(context).onMessageSwipe(
                            message: widget.message.text,
                            isMe: true,
                            messageType: widget.message.messageType,
                            repliedTo: widget.message.senderName,
                          );
                        },
                      ),
                      if(widget.message.messageType == MessageType.text)
                        FocusedMenuItem(
                          backgroundColor : AppColorss.thirdColor2,
                          trailingIcon: Icon(FluentIcons.copy_24_regular, color: AppColorss.iconsColors),
                          title: Text(AppStringss.copyMessage),
                          onPressed: () {
                            _copyMessageText(context, widget.message.text);
                          },
                        ),
                      if(widget.message.messageType == MessageType.text)
                        FocusedMenuItem(
                          backgroundColor : AppColorss.thirdColor2,
                          trailingIcon: Icon(FluentIcons.edit_24_regular, color: AppColorss.iconsColors),
                          title: Text(AppStringss.editMessage),
                          onPressed: () {
                            _editMessage(context);
                          },
                        ),
                      FocusedMenuItem(
                        backgroundColor : AppColorss.thirdColor2,
                        trailingIcon: const Icon(FluentIcons.delete_24_regular, color: Colors.red),
                        title: Text(AppStringss.deleteMessage, style: TextStyle(color: Colors.red),),
                        onPressed: () {
                          _deleteMessage(context);
                        },
                      ),
                      // Add more items as needed
                    ],
                    onPressed: (){},
                    leftSide: MediaQuery.of(context).size.width / 2.07,
                    rightSide: 0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          focusColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onDoubleTap: ()async{
                            final firestore = FirebaseFirestore.instance;
                            final userId = widget.message.senderId;
                            final chatId = widget.message.receiverId;
                            await firestore
                                .collection('users')
                                .doc(userId)
                                .collection('chats')
                                .doc(chatId)
                                .collection('messages')
                                .doc(widget.message.messageId)
                                .update({
                              'isLiked': true,
                            });
                            final userId2 = widget.message.receiverId;
                            final chatId2 = widget.message.senderId;
                            await firestore
                                .collection('users')
                                .doc(userId2)
                                .collection('chats')
                                .doc(chatId2)
                                .collection('messages')
                                .doc(widget.message.messageId)
                                .update({
                              'isLiked': true,
                            });
                          },
                          child: Stack(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: context.width(0.6),
                                  maxHeight: 5000
                                ),
                                child:
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: widget.message.messageType == MessageType.image || widget.message.messageType == MessageType.video ? 0 : 5),
                                  decoration: BoxDecoration(
                                    gradient: (widget.message.messageType == MessageType.image || widget.message.messageType == MessageType.video)
                                        ? const LinearGradient(
                                      colors: [Colors.transparent, Colors.transparent], // Define your gradient colors
                                      begin: Alignment.topLeft, // Adjust the gradient's start position
                                      end: Alignment.bottomRight, // Adjust the gradient's end position
                                    )
                                        : const LinearGradient(
                                      stops: [
                                        0,
                                        1,
                                        2
                                      ],
                                      colors: [AppColorss.myMessageColor2,AppColorss.myMessageColor1, AppColorss.myMessageColor], // Define your gradient colors
                                      begin: Alignment.topLeft, // Adjust the gradient's start position
                                      end: Alignment.bottomRight, // Adjust the gradient's end position
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      bottomLeft: const Radius.circular(20),
                                      bottomRight: widget.isLast ? const Radius.circular(20) : const Radius.circular(5),
                                      topRight: widget.isFirst ? const Radius.circular(20) : const Radius.circular(5),
                                    ),
                                  ),
                                  child: MessageContent(
                                    message: widget.message,
                                    isMe: true,
                                    isLast : widget.isLast
                                  ),
                                ),
                              ),
                              widget.message.isLiked ?
                              Positioned(
                                bottom: 0,
                                left: 0, // Align to the left edge
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: AppColorss.primaryColor
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                      width: 20,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50),
                                          color: AppColorss.senderMessageColor
                                      ),
                                      child: const Icon(FluentIcons.heart_28_filled, size: 12,color: Colors.red,)),
                                ),
                              ) : const SizedBox(),
                              if (widget.message.isLiked)
                                const SizedBox(height: 55,)
                            ],
                          ),
                        ),
                        if (widget.isFirst) const Padding(padding: EdgeInsets.symmetric(horizontal: 5)),
                      ],
                    ),
                  ),
                  widget.isLastForSeen  && widget.message.isSeen ?   Padding(
                    padding:  const EdgeInsets.only(right: 5, top: 4),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text("Seen", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w300),),
                        SizedBox(width: widget.isFirst ? 10 : 0,),
                      ],
                    ),
                  ) : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  void _copyMessageText(BuildContext context, String messageText) {
    Clipboard.setData(ClipboardData(text: messageText));
    Fluttertoast.showToast(
      msg: AppStringss.messageCopied,
      textColor: AppColorss.textColor1,
      backgroundColor: AppColorss.thirdColor,
      gravity: ToastGravity.CENTER,
    );
  }

  void _editMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedMessage = widget.message.text;
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                constraints: const BoxConstraints.expand(),
              ),
            ),
            AlertDialog(
              backgroundColor:  Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(AppStringss.editMessage, style: TextStyle(color: AppColorss.textColor1),),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: context.width(0.6),
                    maxHeight: 600
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      stops: [0, 1, 2],
                      colors: [AppColorss.myMessageColor2, AppColorss.myMessageColor1, AppColorss.myMessageColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: widget.isLast ? Radius.circular(20) : Radius.circular(20),
                      topRight: widget.isFirst ? Radius.circular(20) : Radius.circular(20),
                    ),
                  ),
                  child: TextField(
                    maxLines: null,
                    keyboardAppearance: Brightness.dark,
                    textAlignVertical: TextAlignVertical.center,
                    style: TextStyle(color: AppColorss.textColor1, fontFamily: 'Arabic'),
                    onChanged: (value) {
                      editedMessage = value;
                    },
                    controller: TextEditingController(text: editedMessage),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      // prefixIcon: Icon(
                      //   Icons.edit,
                      //   color: AppColorss.iconsColors.withOpacity(0.54),
                      // ),
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(AppStringss.no, style: TextStyle(color: AppColorss.textColor2),),
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                ),
                TextButton(
                  child:  Text(AppStringss.save,style: const TextStyle(color: Color.fromRGBO(
                      18, 114, 210, 1.0),),),
                  onPressed: () {
                    // Update the message in Firebase Firestore
                    _updateMessageInFirestore(context, editedMessage);
                    Navigator.pop(context); // Close the dialog
                  },
                ),
              ],
            ),

          ],
        );
      },
    );
  }

  void _deleteMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.5),
                constraints: BoxConstraints.expand(),
              ),
        ),
            AlertDialog(
              backgroundColor:  Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title:  Text(AppStringss.deleteMessage, style: const TextStyle(color: Colors.red),),
              content: Text(AppStringss.confirmDelete, style: TextStyle(color: AppColorss.textColor1),),
              actions: [
                TextButton(
                  child: Text(AppStringss.no, style: TextStyle(color: AppColorss.textColor2),),
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                ),
                TextButton(
                  child:  Text(AppStringss.deleteForMe , style : const TextStyle(color:  Color.fromRGBO(
                      18, 114, 210, 1.0),),),
                  onPressed: () {
                    _deleteMessageFromFirestoreForMe(context);
                    Navigator.pop(context); // Close the dialog
                  },
                ),
                TextButton(
                  child:  Text(AppStringss.deleteForAll , style : const TextStyle(color: Colors.red)),
                  onPressed: () {
                    _deleteMessageFromFirestoreForAll(context);
                    Navigator.pop(context); // Close the dialog
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteMessageFromFirestoreForMe(BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userId = widget.message.senderId;
      final chatId = widget.message.receiverId;
      await firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(widget.message.messageId)
          .delete();
      Fluttertoast.showToast(
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.thirdColor,
        gravity: ToastGravity.CENTER,
        msg: AppStringss.doneDeleteForMe,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      print('Error deleting message: $e');
      Fluttertoast.showToast(
        msg: 'Error Deleting Message',
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.thirdColor,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void _deleteMessageFromFirestoreForAll(BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userId = widget.message.senderId;
      final chatId = widget.message.receiverId;
      await firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(widget.message.messageId)
          .delete();
      await firestore
          .collection('users')
          .doc(chatId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .doc(widget.message.messageId)
          .delete();
      Fluttertoast.showToast(
        msg: AppStringss.doneDeleteForAll,
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.thirdColor,
        gravity: ToastGravity.CENTER,
      );

    } catch (e) {
      print('Error deleting message: $e');
      Fluttertoast.showToast(
        msg: 'Error deleting message',
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.thirdColor,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  void _updateMessageInFirestore(BuildContext context, String editedMessage) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final userId = widget.message.senderId;
      final chatId = widget.message.receiverId;
      await firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(widget.message.messageId)
          .update({
        'text': editedMessage,
      });
      await firestore
          .collection('users')
          .doc(chatId)
          .collection('chats')
          .doc(userId)
          .collection('messages')
          .doc(widget.message.messageId)
          .update({
        'text': editedMessage,
      });
      Fluttertoast.showToast(
        msg: AppStringss.doneUpdate,
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.thirdColor,
        gravity: ToastGravity.CENTER,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error update message',
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.thirdColor,
        gravity: ToastGravity.CENTER,
      );
      print('Error updating message: $e');
    }
  }

  void _SaveImage(BuildContext context) async {
    var cacheManager = DefaultCacheManager();
    var file = await cacheManager.getSingleFile(widget.message.text);

    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final savedFile = await file.copy(imagePath);

    final result = await ImageGallerySaver.saveFile(savedFile.path);
    if (result['isSuccess']) {
      Fluttertoast.showToast(
        msg: 'Saved',
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.secondaryColor,
        gravity: ToastGravity.CENTER,
      );
    }else {
      Fluttertoast.showToast(
        msg: 'Fail to save Image',
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.secondaryColor,
        gravity: ToastGravity.CENTER,
      );
    }

  }
  void _saveVideo() async {
    var cacheManager = DefaultCacheManager();
    var file = await cacheManager.getSingleFile(widget.message.text);

    final directory = await getTemporaryDirectory();
    final videoPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savedFile = await file.copy(videoPath);

    final result = await ImageGallerySaver.saveFile(savedFile.path, isReturnPathOfIOS: false);
    if (result['isSuccess']) {
      Fluttertoast.showToast(
        msg: 'Video Saved',
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.secondaryColor,
        gravity: ToastGravity.CENTER,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Fail to save video',
        toastLength: Toast.LENGTH_LONG,
        textColor: AppColorss.textColor1,
        backgroundColor: AppColorss.secondaryColor,
        gravity: ToastGravity.CENTER,
      );
    }
  }
}