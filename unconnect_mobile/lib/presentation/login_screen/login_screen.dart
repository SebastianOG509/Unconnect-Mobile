import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:unconnect_mobile/core/app_export.dart';
import '../../core/utils/image_constant.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext context) {
            return SizedBox(
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
                    onPressed: () => _login(context),
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
            controller: emailController,
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
            controller: passwordController,
            textInputAction: TextInputAction.done,
            obscureText: true,
            borderDecoration: TextFormFieldStyleHelper.fillBlueGray,
            fillColor: appTheme.blueGray100,
          )
        ],
      ),
    );
  }

  void _login(BuildContext context) async {
    final MutationOptions options = MutationOptions(
      document: gql('''
    mutation LoginAuthUser(\$email: String!, \$password: String!) {
      loginAuthUser(email: \$email, password: \$password) {
        token
      }
    }
  '''),
      variables: {
        'email': emailController.text,
        'password': passwordController.text,
      },
    );

    final QueryResult result = await GraphQLProvider.of(context).value.mutate(options);

    if (result.hasException) {
      print('Error: ${result.exception.toString()}');
      // Manejar error de inicio de sesión
    } else {
      final String? token = result.data?['loginAuthUser']['token'];
      if (token != null) {
        // Guardar el token en SharedPreferences
        await _saveToken(token);

        // Imprimir el token en la consola
        print('Token: $token');

        // Consulta para verificar si el campo "Name" está vacío
        final QueryResult userResult = await GraphQLProvider.of(context).value.query(QueryOptions(
          document: gql('''
            query getUserByAuthId(\$token: String!) {
              getUserByAuthId(token: \$token) {
                Name
              }
            }
          '''),
          variables: {'token': token},
        ));

        if (userResult.hasException) {
          print('Error al obtener el usuario: ${userResult.exception}');
          // Redirigir a la pantalla DataScreen si hay un error al obtener el usuario
          Navigator.pushReplacementNamed(context, AppRoutes.dataScreen);
        } else {
          final String? name = userResult.data?['getUserByAuthId']['Name'];
          if (name == null || name.isEmpty) {
            // Redirigir a la pantalla DataScreen si el campo "Name" está vacío
            Navigator.pushReplacementNamed(context, AppRoutes.dataScreen);
          } else {
            // Redirigir a la pantalla PostsScreen si el token es válido y el campo "Name" no está vacío
            Navigator.pushReplacementNamed(context, AppRoutes.postsScreen);
          }
        }
      } else {
        // Redirigir a la pantalla DataScreen si el token es null
        Navigator.pushReplacementNamed(context, AppRoutes.dataScreen);
      }
    }
  }

  Future<void> _saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
}
