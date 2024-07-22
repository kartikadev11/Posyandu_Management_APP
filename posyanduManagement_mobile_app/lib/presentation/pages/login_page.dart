import 'package:posyandumanagement_mobile_app/common/app_color.dart';
import 'package:posyandumanagement_mobile_app/common/app_info.dart';
import 'package:posyandumanagement_mobile_app/common/app_route.dart';
import 'package:posyandumanagement_mobile_app/data/source/user_source.dart';
import 'package:posyandumanagement_mobile_app/presentation/widgets/app_button.dart';
import 'package:d_input/d_input.dart';
import 'package:d_session/d_session.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  login(String email, String password, BuildContext context) {
    print('Attempting to login with email: $email');
    UserSource.login(email, password).then((result) {
      if (result == null) {
        print('Login failed');
        AppInfo.failed(context, 'Login Failed');
      } else {
        print('Login successful');
        AppInfo.success(context, 'Login Success');
        DSession.setUser(result.toJson());
        Navigator.pushNamed(context, AppRoute.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final edtEmail = TextEditingController();
    final edtPassword = TextEditingController();
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(0),
        children: [
          Padding(
            padding: const EdgeInsets.all(40.0),
            child: buildHeader(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 30, vertical: 10), // Ubah padding di sini
            child: Column(
              children: [
                DInput(
                  controller: edtEmail,
                  fillColor: Colors.white,
                  radius: BorderRadius.circular(12),
                  hint: 'email',
                ),
                const SizedBox(height: 20),
                DInputPassword(
                  controller: edtPassword,
                  fillColor: Colors.white,
                  radius: BorderRadius.circular(12),
                  hint: 'password',
                ),
                const SizedBox(height: 20),
                AppButton.primary('LOGIN', () {
                  login(edtEmail.text, edtPassword.text, context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AspectRatio buildHeader() {
    return AspectRatio(
      aspectRatio: 0.8,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/logo_pos.png',
                height: 170, // Ubah ukuran logo di sini
                width: 170, // Ubah ukuran logo di sini
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'Schedule App for\n',
                style: TextStyle(
                  color: AppColor.defaultText,
                  fontSize: 24,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text: 'Posyandu Activity',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
