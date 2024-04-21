import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import '../../core/app_export.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getTokenFromSharedPreferences(), // Obtener el token de SharedPreferences
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error al obtener el token: ${snapshot.error}'),
            ),
          );
        } else {
          final String? token = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Mi Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Color(0xFF08163B),
            ),
            body: token != null ? _buildProfileQuery(token, context) : _buildNoTokenMessage(),
            bottomNavigationBar: CustomBottomAppBar(
              icons: [
                Icons.home,
                Icons.search,
                Icons.post_add,
                Icons.person,
              ],
              routes: [
                AppRoutes.postsScreen,
                AppRoutes.postsScreen,
                AppRoutes.mypostsScreen,
                AppRoutes.profileScreen,
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildProfileQuery(String token, BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql('''
          query getUserByAuthId(\$token: String!) {
            getUserByAuthId(token: \$token) {
              Name
              LastName
              Birthday
              Campus
              Faculty
              Career
              MemberUNSince
              PhoneNumber
              Gender
              ProfilePhoto
              myGroups
            }
          }
        '''),
        variables: {'token': token}, // Pasar el token como variable en la consulta
      ),
      builder: (QueryResult result, {fetchMore, refetch}) {
        if (result.hasException) {
          print('Error al cargar los datos del usuario: ${result.exception}');
          return Text('Error al cargar los datos del usuario');
        }

        if (result.isLoading) {
          return CircularProgressIndicator();
        }

        final userData = result.data?['getUserByAuthId'];

        if (userData == null) {
          return Text('No se encontraron datos de usuario');
        }

        // Obtener la URL de la foto de perfil o establecer la imagen predeterminada
        final String profilePhoto = userData['ProfilePhoto'] ?? 'https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF08163B),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                width: double.infinity,
                padding: EdgeInsets.all(20),
                child: Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: userData['ProfilePhoto'] != null && userData['ProfilePhoto'] != ""
                            ? NetworkImage('http://10.0.2.2:8000/get-file?file_id=${userData['ProfilePhoto']}')
                            : NetworkImage('https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () async {
                            print(userData['ProfilePhoto']); // Imprimir ProfilePhoto en la consola
                            await _selectImageAndUpload(context);
                          }
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Nombre'),
                subtitle: Text('${userData['Name']} ${userData['LastName']}'),
              ),
              ListTile(
                title: Text('Cumpleaños'),
                subtitle: Text('${userData['Birthday']}'),
              ),
              ListTile(
                title: Text('Campus'),
                subtitle: Text('${userData['Campus']}'),
              ),
              ListTile(
                title: Text('Facultad'),
                subtitle: Text('${userData['Faculty']}'),
              ),
              ListTile(
                title: Text('Carrera'),
                subtitle: Text('${userData['Career']}'),
              ),
              ListTile(
                title: Text('Miembro desde'),
                subtitle: Text('${userData['MemberUNSince']}'),
              ),
              ListTile(
                title: Text('Número de teléfono'),
                subtitle: Text('${userData['PhoneNumber']}'),
              ),
              ListTile(
                title: Text('Género'),
                subtitle: Text('${userData['Gender']}'),
              ),
              // Agregar más ListTile según sea necesario
              SizedBox(height: 20),
              // Botones al final del scroll
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppRoutes.dataScreen);// Acción al presionar el botón de editar información
                    },
                    child: Text('Editar Información',style: TextStyle(color: Colors.black)),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green), // Color verde para el botón
                        minimumSize: MaterialStateProperty.all<Size>(Size(200, 50))
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () {
                      _logout(context);// Acción al presionar el botón de editar información
                    },
                    child: Text('Cerrar Sesión',style: TextStyle(color: Colors.black)),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        minimumSize: MaterialStateProperty.all<Size>(Size(200, 50))// Color verde para el botón
                    ),
                  ),

                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoTokenMessage() {
    return Center(
      child: Text('No se encontró un token de autenticación'),
    );
  }

  Future<String?> _getTokenFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token recuperado: $token');
    return token;
  }

  Future<void> _logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borrar todos los datos de SharedPreferences
    print("Tokens Borrados");
    Navigator.pushReplacementNamed(context, AppRoutes.loginScreen); // Redirigir al inicio de sesión
  }

  Future<void> _selectImageAndUpload(context) async {
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
          // Extraer el ID del cuerpo de la respuesta
          var jsonResponse = jsonDecode(responseData);
          var profilePhotoId = jsonResponse['ids'][0];

          // Realizar la mutación para actualizar el campo ProfilePhoto del perfil
          await _updateProfilePhoto(context, profilePhotoId);
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

  Future<void> _updateProfilePhoto(BuildContext context, String profilePhoto) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      print(prefs.getString('token'));

      if (token != null) {
        final MutationOptions options = MutationOptions(
          document: gql('''
          mutation UpdateProfilePhoto(\$token: String!, \$profilePhoto: String!) {
            editUser(token: \$token, ProfilePhoto: \$profilePhoto) {
              ProfilePhoto
            }
          }
        '''),
          variables: {
            'token': token,
            'profilePhoto': profilePhoto,
          },
        );

        final QueryResult result = await GraphQLProvider.of(context).value.mutate(options);

        if (result.hasException) {
          print('Error: ${result.exception.toString()}');
        } else {
          print('Profile photo updated successfully');
          Navigator.pushNamed(context, AppRoutes.profileScreen);
        }
      } else {
        // Manejar caso en el que no se encuentre el token en SharedPreferences
      }
    } catch (error) {
      print('Error updating profile photo: $error');
    }
  }
}
