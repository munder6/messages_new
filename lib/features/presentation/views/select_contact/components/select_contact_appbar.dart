import 'package:flutter/material.dart';
import '../../../../../core/utils/thems/my_colors.dart';
import '/core/extensions/extensions.dart';
import '../../../../../core/utils/constants/strings_manager.dart';
import '../../../controllers/select_contact_cubit/select_contact_cubit.dart';

class SelectContactAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final int numOfContacts;
  final SelectContactState state;

  const SelectContactAppBar({
    super.key,
    required this.numOfContacts,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading : false,
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColorss.secondaryColor,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            AppStringss.selectContact,
            style: TextStyle(color: AppColorss.textColor1),
          ),
          const SizedBox(height: 3),
          Text(
            '$numOfContacts ${AppStringss.contact}',
            style: context.bodySmall,
          ),
        ],
      ),
      actions: [
        if (state is GetAllContactsLoadingState ||
            state is GetContactsOnAppLoadingState)
           FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: AppColorss.iconsColors,
                strokeWidth: 2,
              ),
            ),
          ),
       IconButton(onPressed: (){
         SelectContactCubit.get(context).getAllContacts().then((value) {
           SelectContactCubit.get(context).getContactsOnMessageMe();
           SelectContactCubit.get(context).getContactsNotOnMessageMe();
         });
       }, icon:  Icon(Icons.refresh_outlined, color: AppColorss.iconsColors,))
      ],
    );
  }



  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
