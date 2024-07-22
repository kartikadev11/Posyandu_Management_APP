import 'package:posyandumanagement_mobile_app/common/app_color.dart';
import 'package:posyandumanagement_mobile_app/common/app_route.dart';
import 'package:posyandumanagement_mobile_app/data/models/schedule.dart';
import 'package:posyandumanagement_mobile_app/data/models/user.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/list_schedule/list_schedule_bloc.dart';
import 'package:posyandumanagement_mobile_app/presentation/widgets/failed_ui.dart';
import 'package:d_button/d_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ListTaskPage extends StatefulWidget {
  const ListTaskPage({
    super.key,
    required this.status,
    required this.member,
  });
  final String status;
  final User member;

  @override
  State<ListTaskPage> createState() => _ListTaskPageState();
}

class _ListTaskPageState extends State<ListTaskPage> {
  refresh() {
    context.read<ListTaskBloc>().add(
          OnFetchListTask(widget.status, widget.member.id!),
        );
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          header(),
          Expanded(
            child: buildListTask(),
          ),
        ],
      ),
    );
  }

  Widget buildListTask() {
    return BlocBuilder<ListTaskBloc, ListTaskState>(
      builder: (context, state) {
        if (state is ListTaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ListTaskFailed) {
          return FailedUI(message: state.message);
        }
        if (state is ListTaskLoaded) {
          List<Schedule> tasks = state.tasks;
          if (tasks.isEmpty) {
            return const FailedUI(
              message: "Tidak ada jadwal",
              icon: Icons.list,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Schedule task = tasks[index];
              return buildItemTask(task);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildItemTask(Schedule task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event,
                color: Colors.grey,
                size: 18,
              ),
              const Gap(8),
              Text(
                DateFormat('d MMM yyyy, HH:mm').format(task.startDate!),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const Gap(8),
              Text("-"),
              const Gap(8),
              Text(
                DateFormat('d MMM yyyy, HH:mm').format(task.endDate!),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Gap(12),
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
            task.address ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColor.textBody,
              fontSize: 14,
            ),
          ),
          const Gap(20),
          DButtonBorder(
            onClick: () {
              Navigator.pushNamed(
                context,
                AppRoute.detailTask,
                arguments: task.id,
              ).then((value) => refresh());
            },
            mainColor: Colors.white,
            radius: 10,
            borderColor: AppColor.scaffold,
            child: const Text('Buka'),
          ),
        ],
      ),
    );
  }

  Widget header() {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(20, 50, 20, 4),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              widget.status,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 0,
            top: 0,
            child: UnconstrainedBox(
              child: DButtonFlat(
                width: 36,
                height: 36,
                radius: 10,
                mainColor: Colors.white,
                onClick: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 0,
            top: 0,
            child: Chip(
              side: BorderSide.none,
              label: Text(
                widget.member.name ?? '',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
