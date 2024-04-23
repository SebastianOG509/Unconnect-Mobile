import 'package:flutter/material.dart';
import 'package:unconnect_mobile/core/app_export.dart';

import '../../core/utils/image_constant.dart';
import '../../widgets/custom_image_view.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key})
      : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgLogo1,
                height: 533.v,
                width: 360.h,
                radius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.h),
                  bottomRight: Radius.circular(15.h),
                ),
              ),
              SizedBox(height: 49.v),
              Padding(
                padding: EdgeInsets.only(left: 31.h),
                child: Text(
                  "¡Bienvenido!",
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              SizedBox(height: 5.v),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 282.h,
                  margin: EdgeInsets.only(
                    left: 31.h,
                    right: 46.h,
                  ),
                  child: Text(
                    "Unconnect, la red social de la Universidad \nNacional de Colombia",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
              ),
              SizedBox(height: 50.v),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {
                      // Redirige a otra pantalla al presionar "Siguiente >"
                      Navigator.pushNamed(context, AppRoutes.registerScreen);
                    },
                    child: Text("Siguiente >"),
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
}

