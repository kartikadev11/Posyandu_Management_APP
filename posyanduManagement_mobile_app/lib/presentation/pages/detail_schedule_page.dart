import 'dart:io';

import 'package:posyandumanagement_mobile_app/common/app_color.dart';
import 'package:posyandumanagement_mobile_app/common/app_info.dart';
import 'package:posyandumanagement_mobile_app/common/enums.dart';
import 'package:posyandumanagement_mobile_app/common/urls.dart';
import 'package:posyandumanagement_mobile_app/common/utils.dart';
import 'package:posyandumanagement_mobile_app/data/models/schedule.dart';
import 'package:posyandumanagement_mobile_app/data/source/schedule_source.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/detail_schedule/detail_schedule_cubit.dart';
import 'package:posyandumanagement_mobile_app/presentation/bloc/user/user_cubit.dart';
import 'package:posyandumanagement_mobile_app/presentation/widgets/app_button.dart';
import 'package:posyandumanagement_mobile_app/presentation/widgets/failed_ui.dart';
import 'package:d_button/d_button.dart';
import 'package:d_input/d_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:extended_image/extended_image.dart';
import '../../data/models/user.dart';

class DetailTaskPage extends StatefulWidget {
  const DetailTaskPage({super.key, required this.id});
  final int id;

  @override
  State<DetailTaskPage> createState() => _DetailTaskPageState();
}

class _DetailTaskPageState extends State<DetailTaskPage> {
  final attachment = XFile('').obs;

  pickImage() async {
    XFile? result = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (result == null) return;
    attachment.value = result;
  }

  submitTask() {
    TaskSource.submit(widget.id, attachment.value).then((success) {
      if (success) {
        AppInfo.success(context, "Berhasil mengumpulkan Dokumentasi");
        refresh();
      } else {
        AppInfo.failed(context, "Gagal mengumpulkan Dokumentasi");
      }
    });
  }

  rejectTask(String reason) {
    TaskSource.reject(widget.id, reason).then((success) {
      if (success) {
        AppInfo.success(context, "Dokumentasi berhasil ditolak");
        refresh();
      } else {
        AppInfo.failed(context, "Dokumentasi gagal ditolak");
      }
    });
  }

  fixTaskToQueue() {
    int revision = context.read<DetailTaskCubit>().state.task!.revision! + 1;
    TaskSource.fixToQueue(widget.id, revision).then((success) {
      if (success) {
        AppInfo.success(context, "Berhasil re-submit Dokumentasi");
        refresh();
      } else {
        AppInfo.failed(context, "Gagal re-submit Dokumentasi");
      }
    });
  }

  approveTask() {
    TaskSource.approve(widget.id).then((success) {
      if (success) {
        AppInfo.success(context, "Dokumentasi berhasil disetujui");
        refresh();
      } else {
        AppInfo.failed(context, "Dokumentasi gagal disetujui");
      }
    });
  }

  deleteTask() {
    TaskSource.delete(widget.id).then((success) {
      if (success) {
        AppInfo.success(context, "Berhasil menghapus jadwal");
        Navigator.pop(context);
      } else {
        AppInfo.failed(context, "Gagal menghapus jadwal");
      }
    });
  }

  refresh() {
    context.read<DetailTaskCubit>().fetchDetailTask(widget.id);
  }

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DetailTaskCubit, DetailTaskState>(
        builder: (context, state) {
          if (state.requestStatus == RequestStatus.init) {
            return const SizedBox.shrink();
          }
          if (state.requestStatus == RequestStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.requestStatus == RequestStatus.failed) {
            return const FailedUI(message: "Jadwal tidak ditemukan");
          }
          Schedule task = state.task!;
          return Column(
            children: [
              AppBar(
                elevation: 0,
                centerTitle: true,
                title: const Text('Detail Jadwal'),
                actions: [
                  buildMenu(task),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(0),
                  children: [
                    buildStatus(task),
                    const Gap(20),
                    buildDescription(task),
                    const Gap(20),
                    buildDetails(task),
                    const Gap(20),
                    buildReason(task),
                    const Gap(20),
                    buildAtatchment(task),
                    const Gap(20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildAtatchment(Schedule task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atatchment',
            style: TextStyle(
              color: AppColor.textTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          if (task.attachment != null && task.attachment != '')
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Stack(
                          children: [
                            Positioned.fill(
                              child: InteractiveViewer(
                                maxScale: 3,
                                child: ExtendedImage.network(
                                  URLs.image(task.attachment!),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: UnconstrainedBox(
                                child: FloatingActionButton(
                                  heroTag: 'close-image-view',
                                  onPressed: () => Navigator.pop(context),
                                  backgroundColor: AppColor.primary,
                                  child: const Icon(Icons.clear),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: ExtendedImage.network(
                    URLs.image(task.attachment!),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildDetails(Schedule task) {
    DateFormat dateFormat = DateFormat('d MMM yyyy, HH:mm');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: TextStyle(
              color: AppColor.textTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          itemDetails('Published', dateFormat.format(task.createdAt!)),
          itemDetails('Start', dateFormat.format(task.startDate!)),
          itemDetails('End', dateFormat.format(task.endDate!)),
          itemDetails(
            'Submit',
            task.submitDate == null ? '-' : dateFormat.format(task.submitDate!),
          ),
          itemDetails('Revision', task.revision.toString()),
          itemDetails(
            'Rejected',
            task.rejectedDate == null
                ? '-'
                : dateFormat.format(task.rejectedDate!),
          ),
          itemDetails(
            'Approved',
            task.approvedDate == null
                ? '-'
                : dateFormat.format(task.approvedDate!),
          ),
        ],
      ),
    );
  }

  Widget itemDetails(String title, String data) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColor.textBody,
              fontSize: 16,
            ),
          ),
          Text(
            data,
            style: TextStyle(
              color: AppColor.textTitle,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescription(Schedule task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title ?? '',
            style: TextStyle(
              color: AppColor.textTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          Text(
            task.address ?? '',
            style: TextStyle(
              color: AppColor.textBody,
              fontSize: 16,
            ),
          ),
          Text(
            task.note ?? '',
            style: TextStyle(
              color: AppColor.textBody,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReason(Schedule task) {
    print("Reason: ${task.reason}");
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reason Rejection',
            style: TextStyle(
              color: AppColor.textTitle,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(4),
          Text(
            task.reason == null || task.reason == '' ? '-' : task.reason!,
            style: TextStyle(
              color: AppColor.textBody,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatus(Schedule task) {
    return Stack(
      children: [
        Container(
          color: AppColor.primary,
          height: 60,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        color: AppColor.textTitle,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      task.status ?? '',
                      style: TextStyle(
                        color: AppColor.textBody,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Image.asset(
                iconByStatus(task),
                height: 40,
                width: 40,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildMenu(Schedule task) {
    User user = context.read<UserCubit>().state;
    bool isAdmin = user.role == 'Admin';
    bool isMember = user.role == 'Member';
    bool isSubmit = task.status == 'Review';
    bool isQueue = task.status == 'Queue';
    bool isRejected = task.status == 'Rejected';
    List<Map> menu = [
      if (isMember && isQueue)
        {
          'icon': Icons.send,
          'label': 'Submit',
          'color': AppColor.primary,
          'onTap': () => buildSubmit(),
        },
      if (isAdmin && isSubmit)
        {
          'icon': Icons.check,
          'label': 'Approve',
          'color': AppColor.approved,
          'onTap': () => approveTask(),
        },
      if (isAdmin && isSubmit)
        {
          'icon': Icons.block,
          'label': 'Reject',
          'color': AppColor.rejected,
          'onTap': () => buildReject(),
        },
      if (isMember && isRejected)
        {
          'icon': Icons.auto_fix_high,
          'label': 'Fix to Queue',
          'color': AppColor.queue,
          'onTap': () => fixTaskToQueue(),
        },
      if (isAdmin)
        {
          'icon': Icons.delete_outline,
          'label': 'Delete',
          'color': Colors.red,
          'onTap': () => deleteTask(),
        },
    ];

    return PopupMenuButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      itemBuilder: (context) => menu.map((e) {
        return PopupMenuItem(
          onTap: e['onTap'],
          child: Row(
            children: [
              Icon(e['icon'], color: e['color']),
              const Gap(12),
              Text(e['label']),
            ],
          ),
        );
      }).toList(),
    );
  }

  buildSubmit() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UnconstrainedBox(
                child: DButtonBorder(
                  onClick: () => pickImage(),
                  radius: 8,
                  borderColor: AppColor.textBody,
                  child: const Text('Pilih File'),
                ),
              ),
              const Gap(12),
              Obx(() {
                String path = attachment.value.path;
                if (path == '') {
                  return const FailedUI(message: 'File tidak boleh kosong');
                }
                return AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.file(
                    File(path),
                    fit: BoxFit.cover,
                  ),
                );
              }),
              const Gap(20),
              Obx(() {
                return AppButton.primary(
                  'Submit File',
                  attachment.value.path == ''
                      ? null
                      : () {
                          Navigator.pop(context);
                          submitTask();
                        },
                );
              })
            ],
          ),
        );
      },
    );
  }

  buildReject() {
    final edtReason = TextEditingController();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DInput(
                controller: edtReason,
                fillColor: Colors.white,
                radius: BorderRadius.circular(12),
                minLine: 5,
                maxLine: 5,
                hint: 'tulis alasan...',
              ),
              const Gap(20),
              AppButton.primary(
                'Tolak Dokumentasi',
                () {
                  Navigator.pop(context);
                  rejectTask(edtReason.text);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
