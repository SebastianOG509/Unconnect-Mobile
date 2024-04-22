import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_elevated_button.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CreatepostScreen extends StatefulWidget {
  @override
  _CreatepostScreenState createState() => _CreatepostScreenState();
}

class _CreatepostScreenState extends State<CreatepostScreen> {
  final TextEditingController _contentController = TextEditingController();

  List<String> _mediaIds = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'UNConnect',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF08163B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crear Post',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CustomElevatedButton(
                  width: 159.h,
                  text: "Añadir Imagenes",
                  buttonTextStyle: CustomTextStyles.titleSmallBlack900,
                  alignment: Alignment.center,
                  onPressed: () {
                    _selectImageAndUpload(context);
                  },
                ),
                SizedBox(width: 20),
                Expanded(
                  child: CustomElevatedButton(
                    width: 159.h,
                    text: "Crear",
                    buttonTextStyle: CustomTextStyles.titleSmallBlack900,
                    alignment: Alignment.center,
                    onPressed: () {
                      _createPost();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _createPost() async {
    final String content = _contentController.text;
    if (content.isNotEmpty) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      if (token != null) {
        final MutationOptions options = MutationOptions(
          document: gql('''
            mutation CreatePost(\$token: String!, \$Content: String!, \$Media: [String!]) {
              createPost(token: \$token, Content: \$Content, Media: \$Media) {
                Id
                Content
                Media
                GroupId
                UserId
              }
            }
          '''),
          variables: {
            'token': token,
            'Content': content,
            'Media': _mediaIds, // Aquí puedes agregar las URLs de las imágenes si las tienes
          },
        );

        final QueryResult result = await GraphQLProvider.of(context).value.mutate(options);

        if (result.hasException) {
          print('Error al crear el post: ${result.exception.toString()}');
        } else {
          print('Post creado exitosamente');
          Navigator.pushNamed(context, AppRoutes.mypostsScreen);
          // Puedes agregar aquí la navegación a la pantalla de posts o cualquier otra acción después de crear el post
        }
      }
    } else {
      // Mostrar un mensaje de error si el campo de contenido está vacío
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingresa el contenido del post'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }


  Future<void> _selectImageAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String token = await _getTokenFromSharedPreferences() ?? "";

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2.2:8000/upload-file/?token=$token'),
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            imageFile.path,
          ),
        );
        print('Multipart Request: ${request.toString()}');

        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        print('HTTP Status Code: ${response.statusCode}');
        print('Response Body: $responseData');

        if (response.statusCode == 200) {
          // Extraer los IDs del cuerpo de la respuesta
          var jsonResponse = jsonDecode(responseData);
          List<String> mediaIds = List<String>.from(jsonResponse['ids']);

          // Actualizar el campo Media del formulario
          setState(() {
            _mediaIds.addAll(mediaIds);
          });
        } else {
          // Manejar la respuesta del servidor en caso de error
          print('Error uploading file: $responseData');
        }
      } catch (error) {
        // Manejar errores de red u otros errores de la solicitud
        print('Error uploading file: $error');
      }
    }
  }

  Future<String?> _getTokenFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }
}
