import 'package:posyandumanagement_mobile_app/common/app_color.dart';
import 'package:posyandumanagement_mobile_app/common/app_route.dart';
import 'package:posyandumanagement_mobile_app/data/models/user.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/detail_schedule/detail_schedule_cubit.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/member/member_bloc.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/list_schedule/list_schedule_bloc.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/need_review/need_review_bloc.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/stat_member/stat_member_cubit.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/user/user_cubit.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/add_member_page.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/add_schedule_page.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/detail_schedule_page.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/home_admin_page.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/home_member_page.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/list_schedule_page.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/login_page.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/monitor_member_page.dart';
import 'package:posyandumanagement_mobile_app/presentation/pages/profile_page.dart';

import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'presentation/bloc/login/login_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => NeedReviewBloc()),
        BlocProvider(create: (context) => MemberBloc()),
        BlocProvider(create: (context) => StatMemberCubit()),
        BlocProvider(create: (context) => ProgressTaskBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light(useMaterial3: true).copyWith(
          primaryColor: AppColor.primary,
          colorScheme: ColorScheme.light(
            primary: AppColor.primary,
            secondary: AppColor.secondary,
          ),
          scaffoldBackgroundColor: AppColor.scaffold,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            surfaceTintColor: AppColor.primary,
            backgroundColor: AppColor.primary,
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          popupMenuTheme: const PopupMenuThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          dialogTheme: const DialogTheme(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
          ),
        ),
        initialRoute: AppRoute.home,
        routes: {
          AppRoute.home: (context) {
            return FutureBuilder(
              future: DSession.getUser(),
              builder: (context, snapshot) {
                if (snapshot.data == null) return const LoginPage();
                User user = User.fromJson(Map.from(snapshot.data!));
                context.read<UserCubit>().update(user);
                if (user.role == "Admin") return const HomeAdminPage();
                return const HomeMemberPage();
              },
            );
          },
          AppRoute.addMember: (context) => const AddMemberPage(),
          AppRoute.addTask: (context) {
            User member = ModalRoute.of(context)!.settings.arguments as User;
            return AddTaskPage(member: member);
          },
          AppRoute.detailTask: (context) {
            int id = ModalRoute.of(context)!.settings.arguments as int;
            return BlocProvider(
              create: (context) => DetailTaskCubit(),
              child: DetailTaskPage(id: id),
            );
          },
          AppRoute.listTask: (context) {
            Map data = ModalRoute.of(context)!.settings.arguments as Map;
            return BlocProvider(
              create: (context) => ListTaskBloc(),
              child: ListTaskPage(
                status: data['status'],
                member: data['member'],
              ),
            );
          },
          AppRoute.login: (context) => const LoginPage(),
          AppRoute.monitorMember: (context) {
            User member = ModalRoute.of(context)!.settings.arguments as User;
            return MonitorMemberPage(member: member);
          },
          AppRoute.profile: (context) => const ProfilePage(),
        },
      ),
    );
  }
}
