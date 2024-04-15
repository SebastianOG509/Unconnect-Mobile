import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart'; // ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key})
      : super(
          key: key,
        );

  TextEditingController edittextController = TextEditingController();

  TextEditingController edittextoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgLogo21,
                height: 450.v,
                width: 360.h,
                radius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.h),
                  bottomRight: Radius.circular(15.h),
                ),
              ),
              SizedBox(height: 15.v),
              _buildColumncorreo(context),
              SizedBox(height: 10.v),
              _buildColumncontrasea(context),
              SizedBox(height: 32.v),
              CustomElevatedButton(
                width: 159.h,
                text: "Ingresar",
                buttonTextStyle: CustomTextStyles.titleSmallBlack900,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿No tienes una cuenta?",
                    style: CustomTextStyles.bodySmallBlack900,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.registerScreen);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.h),
                      child: Text(
                        "Registrate aquí",
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.v)
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildColumncorreo(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Correo institucional:",
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: 4.v),
          CustomTextFormField(
            controller: edittextController,
          )
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildColumncontrasea(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contraseña:",
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: 4.v),
          CustomTextFormField(
            controller: edittextoneController,
            textInputAction: TextInputAction.done,
            obscureText: true,
            borderDecoration: TextFormFieldStyleHelper.fillBlueGray,
            fillColor: appTheme.blueGray100,
          )
        ],
      ),
    );
  }
}
