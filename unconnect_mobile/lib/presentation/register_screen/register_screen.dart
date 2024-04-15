import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart'; // ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key})
      : super(
          key: key,
        );

  TextEditingController user = TextEditingController();

  TextEditingController password = TextEditingController();

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
                imagePath: ImageConstant.imgLogo1,
                height: 409.v,
                width: 360.h,
                radius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.h),
                  bottomRight: Radius.circular(15.h),
                ),
              ),
              SizedBox(height: 44.v),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 37.h),
                  child: Text(
                    "Comencemos...",
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
              SizedBox(height: 9.v),
              _buildColumncorreo(context),
              SizedBox(height: 10.v),
              _buildColumncontrasea(context),
              SizedBox(height: 32.v),
              CustomElevatedButton(
                width: 159.h,
                text: "Registrarse",
                buttonTextStyle: CustomTextStyles.titleSmallBlack900,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 66.h),
                  child: Row(
                    children: [
                      Text(
                        "¿Ya tienes una cuenta?",
                        style: CustomTextStyles.bodySmallBlack900,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.loginScreen);;
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.h),
                          child: Text(
                            "Ingresa aquí",
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            controller: user,
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
            controller: password,
            textInputAction: TextInputAction.done,
            borderDecoration: TextFormFieldStyleHelper.fillBlueGray,
            fillColor: appTheme.blueGray100,
          )
        ],
      ),
    );
  }
}
