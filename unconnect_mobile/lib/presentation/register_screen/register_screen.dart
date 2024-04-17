import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({Key? key}) : super(key: key);

  TextEditingController user = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            final client = GraphQLProvider.of(context);

            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgLogo2,
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
                    onPressed: () {
                      _registerUser(context);
                    },
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
                              Navigator.pushNamed(context, AppRoutes.loginScreen);
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
                  SizedBox(height: 5.v),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

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

  void _registerUser(BuildContext context) async {
    final GraphQLClient client = GraphQLProvider.of(context).value;

    final MutationOptions options = MutationOptions(
      document: gql('''
        mutation {
          createAuthUser(
            email: "${user.text}"
            password: "${password.text}"
            role: USUARIO_REGULAR
          ) {
            id
            email
            verified
            role
          }
        }
      '''),
    );

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      print('Error: ${result.exception.toString()}');
    } else {
      print('Usuario registrado exitosamente: ${result.data}');
      Navigator.pushNamed(context, AppRoutes.loginScreen);
      // Aquí puedes manejar la navegación a otra pantalla u otra acción luego del registro exitoso
    }
  }
}
