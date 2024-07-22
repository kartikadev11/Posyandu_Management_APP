import 'package:posyandumanagement_mobile_app/common/app_color.dart';
import 'package:posyandumanagement_mobile_app/common/app_info.dart';
import 'package:posyandumanagement_mobile_app/data/models/user.dart';
import 'package:posyandumanagement_mobile_app/data/source/schedule_source.dart';
import 'package:posyandumanagement_mobile_app/presentation/widgets/app_button.dart';
import 'package:d_button/d_button.dart';
import 'package:d_input/d_input.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key, required this.member});
  final User member;

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final startDate = DateTime.now().obs;
  final endDate = DateTime.now().obs;
  final edtTitle = TextEditingController();
  final edtAddress = TextEditingController();
  final edtNote = TextEditingController();

  pickStartDate() {
    try {
      showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)),
      ).then((pickedDate) {
        if (pickedDate == null) return;
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((pickedTime) {
          if (pickedTime == null) return;
          startDate.value = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      });
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
    }
  }

  pickEndDate() {
    try {
      showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)),
      ).then((pickedDate) {
        if (pickedDate == null) return;
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((pickedTime) {
          if (pickedTime == null) return;
          endDate.value = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      });
    } catch (e) {
      DMethod.log(e.toString(), colorCode: 1);
    }
  }

  addNewTask() {
    if (edtTitle.text.isEmpty) return;
    if (edtAddress.text.isEmpty) return;
    TaskSource.add(
            edtTitle.text,
            edtAddress.text,
            startDate.value.toIso8601String(),
            endDate.value.toIso8601String(),
            edtNote.text,
            widget.member.id!,
            0)
        .then((success) {
      if (success) {
        AppInfo.success(context, "Berhasil menambahkan jadwal");
      } else {
        AppInfo.failed(context, "Gagal menambahkan jadwal");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Jadwal Baru'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DInput(
            controller: edtTitle,
            title: 'Judul',
            hint: 'isikan judul...',
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          DInput(
            controller: edtAddress,
            title: 'Alamat',
            hint: 'isikan alamat...',
            minLine: 5,
            maxLine: 5,
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          Title(
              color: AppColor.textTitle,
              child: Text(
                "Waktu",
                style: TextStyle(fontWeight: FontWeight.bold),
              )),
          Gap(8),
          Row(
            children: [
              Row(
                children: [
                  DButtonBorder(
                    onClick: () => pickStartDate(),
                    radius: 8,
                    borderColor: AppColor.primary,
                    child: Obx(() {
                      return Text(
                        DateFormat('d MMM yyyy, HH:mm').format(startDate.value),
                        style: TextStyle(fontSize: 11),
                      );
                    }),
                  ),
                  const Gap(13),
                ],
              ),
              Text("-"),
              Gap(13),
              Row(
                children: [
                  DButtonBorder(
                    onClick: () => pickEndDate(),
                    radius: 8,
                    borderColor: AppColor.primary,
                    child: Obx(() {
                      return Text(
                        DateFormat('d MMM yyyy, HH:mm')
                            .format(endDate.value), // Perbaiki di sini
                        style: TextStyle(fontSize: 11),
                      );
                    }),
                  ),
                  const Gap(16),
                ],
              ),
            ],
          ),
          const Gap(16),
          DInput(
            controller: edtNote,
            title: 'Catatan',
            hint: 'tuliskan catatan...',
            minLine: 5,
            maxLine: 5,
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(20),
          AppButton.primary(
            'Tambahkan Jadwal',
            () => addNewTask(),
          ),
        ],
      ),
    );
  }
}
