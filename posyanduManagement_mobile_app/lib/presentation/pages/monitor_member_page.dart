import 'package:posyandumanagement_mobile_app/common/app_color.dart';
import 'package:posyandumanagement_mobile_app/common/app_route.dart';
import 'package:posyandumanagement_mobile_app/common/utils.dart';
import 'package:posyandumanagement_mobile_app/data/models/schedule.dart';
import 'package:posyandumanagement_mobile_app/data/models/user.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/progress_task/progress_task_bloc.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/stat_member/stat_member_cubit.dart';
import 'package:posyandumanagement_mobile_app/presentation/widgets/failed_ui.dart';
import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class MonitorMemberPage extends StatefulWidget {
  const MonitorMemberPage({super.key, required this.member});
  final User member;

  @override
  State<MonitorMemberPage> createState() => _MonitorMemberPageState();
}

class _MonitorMemberPageState extends State<MonitorMemberPage> {
  refresh() {
    context.read<StatMemberCubit>().fetcStatistic(widget.member.id!);
    context
        .read<ProgressTaskBloc>()
        .add(OnFetchProgressTasks(widget.member.id!));
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColor.primary,
            height: 150,
          ),
          RefreshIndicator(
            onRefresh: () async => refresh(),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                const Gap(30),
                buildHeader(),
                const Gap(24),
                buildAddTaskButton(),
                const Gap(40),
                buildTaskMenu(),
                const Gap(40),
                buildProgressTask(),
                const Gap(20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressTask() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jadwal Posyandu',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            color: AppColor.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(20),
        BlocBuilder<ProgressTaskBloc, ProgressTaskState>(
          builder: (context, state) {
            if (state is ProgressTaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProgressTaskFailed) {
              return FailedUI(message: state.message);
            }
            if (state is ProgressTaskLoaded) {
              List<Schedule> tasks = state.tasks;
              if (tasks.isEmpty) {
                return const FailedUI(
                  icon: Icons.list,
                  message: "Tidak Ada Jadwal",
                );
              }

              return ListView.builder(
                itemCount: tasks.length,
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  Schedule task = tasks[index];
                  return buildItemProgressTasks(task);
                },
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  Widget buildItemProgressTasks(Schedule task) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoute.detailTask,
          arguments: task.id,
        ).then((value) => refresh());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        height: 80,
        child: Row(
          children: [
            Container(
              height: 50,
              width: 6,
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            const Gap(24),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColor.textTitle,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(6),
                  Text(
                    dateByStatus(task),
                    style: TextStyle(
                      color: AppColor.textBody,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              iconByStatus(task),
              height: 40,
              width: 40,
              fit: BoxFit.cover,
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget buildTaskMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posyandu KasihIbu',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            color: AppColor.textTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(20),
        BlocBuilder<StatMemberCubit, Map>(
          builder: (context, state) {
            return GridView.count(
              padding: const EdgeInsets.all(0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                builItemTaskMenu('assets/1.png', 'Queue', state['Queue']),
                builItemTaskMenu('assets/2.png', 'Review', state['Review']),
                builItemTaskMenu('assets/3.png', 'Approved', state['Approved']),
                builItemTaskMenu('assets/4.png', 'Rejected', state['Rejected']),
              ],
            );
          },
        )
      ],
    );
  }

  Widget builItemTaskMenu(String asset, String status, int? total) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoute.listTask, arguments: {
          'status': status,
          'member': widget.member,
        }).then((value) => refresh());
      },
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Gap(6),
            Text(
              '${total ?? 0} jadwal',
              style: GoogleFonts.montserrat(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAddTaskButton() {
    return DButtonElevation(
      onClick: () {
        Navigator.pushNamed(
          context,
          AppRoute.addTask,
          arguments: widget.member,
        ).then((value) => refresh());
      },
      height: 50,
      mainColor: Colors.white,
      radius: 16,
      elevation: 4,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add),
          Gap(4),
          Text('Tambahkan Jadwal'),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-12, 0),
          child: const BackButton(color: Colors.white),
        ),
        Expanded(
          child: Text(
            widget.member.name ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
