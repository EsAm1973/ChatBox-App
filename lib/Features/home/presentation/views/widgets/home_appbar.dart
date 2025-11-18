import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/build_avatat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchPressed;

  const HomeAppBar({super.key, required this.onSearchPressed});

  @override
  Size get preferredSize => Size.fromHeight(100.h);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 17.h, left: 20.w, right: 20.w),
      child: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text('Home', style: AppTextStyles.semiBold20),
        leading: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF363F3B), width: 1.0.w),
          ),
          child: IconButton(
            iconSize: 22.r,
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(_getSearchIconPath(context)),
            onPressed: onSearchPressed,
          ),
        ),
        actions: [
          BlocBuilder<UserCubit, UserState>(
            builder: (context, state) {
              if (state is UserLoaded) {
                return buildAvatar(
                  context,
                  state.user.profilePic,
                  50.w,
                  50.h,
                  30.r,
                  30.r,
                  BoxFit.cover,
                );
              } else if (state is UserError) {
                return Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 26.r,
                    backgroundImage: const AssetImage(
                      'assets/user_pic_test.png',
                    ),
                  ),
                );
              } else if (state is UserLoading) {
                return Container(
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: const CircularProgressIndicator(),
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }

  String _getSearchIconPath(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/search_icon.svg'
        : 'assets/search_icon_dark.svg';
  }
}
