import 'package:posyandumanagement_mobile_app/common/app_info.dart';
import 'package:posyandumanagement_mobile_app/data/source/user_source.dart';
import 'package:posyandumanagement_mobile_app/presentation/widgets/app_button.dart';
import 'package:d_input/d_input.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final edtName = TextEditingController();
  final edtEmail = TextEditingController();

  addNewMember() {
    UserSource.addMember(edtName.text, edtEmail.text).then((value) {
      var (success, message) = value;
      if (success) {
        AppInfo.success(context, message);
      } else {
        AppInfo.failed(context, message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Tambah Anggota Baru'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DInput(
            controller: edtName,
            title: 'Nama',
            hint: 'isi nama anggota...',
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          DInput(
            controller: edtEmail,
            title: 'Email',
            hint: 'isi email anggota...',
            fillColor: Colors.white,
            radius: BorderRadius.circular(12),
          ),
          const Gap(16),
          AppButton.primary('Tambahkan', () => addNewMember()),
        ],
      ),
    );
  }
}
