import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  String _groupName = '';
  String _groupDescription = '';
  String _groupPrivacy = 'Publico'; // Por defecto, el grupo es público
  String? _groupPhotoUrl; // Nueva variable para la URL de la imagen del grupo
  File? _groupImage;
  int ownerId = 0; // Cambiar a int
  List members = [];
  List admins = [];
  List inRequests = [];
  final _formKey = GlobalKey<FormState>();

  Future<String?> _getTokenFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token recuperado: $token');
    return token;
  }

  Future<void> _getOwnerId() async {
    try {
      final String? token = await _getTokenFromSharedPreferences();
      if (token != null) {
        final QueryOptions options = QueryOptions(
          document: gql('''
            query{
              PersonByAuthId(token: \$token) {
                id
                userId
              }
            }
          '''),
          variables: {'token': token},
        );

        final QueryResult result = await GraphQLProvider.of(context).value.query(options);
        if (result.hasException) {
          print('Error getting owner ID: ${result.exception.toString()}');
        } else {
          final Map<String, dynamic> userData = result.data!['PersonByAuthId'];
          setState(() {
            print('El Id es: ${userData["id"]}');
            ownerId = int.parse(userData['id']); // Convertir a int
            print(ownerId);
          });
        }
      }
    } catch (error) {
      print('Error getting owner ID: $error');
    }
    members = [[ownerId]];
    admins = [[ownerId]];
    print(ownerId);
  }

  @override
  void initState() {
    super.initState();
    _getOwnerId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis grupos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF08163B),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _getImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        child: _groupImage == null
                            ? (_groupPhotoUrl != null && _groupPhotoUrl!.isNotEmpty
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(_groupPhotoUrl!),
                          radius: 50,
                        )
                            : Icon(Icons.add_a_photo, size: 50, color: Colors.white))
                            : Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: FileImage(_groupImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nombre del grupo *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa el nombre del grupo';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _groupName = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Descripción del grupo *'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa la descripción del grupo';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _groupDescription = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _groupPrivacy,
                  onChanged: (value) {
                    setState(() {
                      _groupPrivacy = value.toString();
                    });
                  },
                  items: ['Publico', 'Privado'].map((privacy) {
                    return DropdownMenuItem(
                      value: privacy,
                      child: Text(privacy),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Privacidad *'),
                  validator: (value) {
                    if (value == null) {
                      return 'Por favor, selecciona la privacidad del grupo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _uploadAndCreateGroup(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16.0), // Ajustar el tamaño del botón
                ),
                child: Text(
                  'Crear Grupo',
                  style: TextStyle(
                    fontSize: 20.0, // Ajustar el tamaño de la letra
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedImage != null) {
        _groupImage = File(pickedImage.path);
      }
    });
  }

  Future<String?> _uploadImageAndGetId(BuildContext context) async {
    try {
      if (_groupImage != null) {
        final String token = await _getTokenFromSharedPreferences() ?? "";
        final String apiUrl = 'http://10.0.2.2:8000/upload-file/?token=$token';

        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.files.add(
          await http.MultipartFile.fromPath(
            'files',
            _groupImage!.path,
          ),
        );

        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        print('HTTP Status Code: ${response.statusCode}');
        print('Response Body: $responseData');

        if (response.statusCode == 200) {
          var jsonResponse = jsonDecode(responseData);
          return jsonResponse['ids'][0];
        } else {
          print('Error uploading file: $responseData');
          return null;
        }
      } else {
        print('No image selected');
        return null;
      }
    } catch (error) {
      print('Error uploading file: $error');
      return null;
    }
  }

  Future<void> _uploadAndCreateGroup(BuildContext context) async {
    try {
      final String? profilePhotoId = await _uploadImageAndGetId(context);

      if (profilePhotoId != null) {
        await _createGroup(context, profilePhotoId);
      } else {
        // Manejar caso en el que no se obtenga el ID de la imagen
      }
    } catch (error) {
      print('Error uploading image and creating group: $error');
    }
  }

  Future<void> _createGroup(BuildContext context, String profilePhotoId) async {
    try {
      final String? token = await _getTokenFromSharedPreferences();
      if (token != null) {
        final QueryOptions options = QueryOptions(
          document: gql('''
          query PersonByAuthID(\$token: String!) {
            PersonByAuthID(token: \$token) {
              id
            }
          }
        '''),
          variables: {'token': token},
        );

        final QueryResult result = await GraphQLProvider.of(context).value.query(options);
        if (result.hasException) {
          print('Error getting owner ID: ${result.exception.toString()}');
        } else {
          final Map<String, dynamic> userData = result.data!['PersonByAuthID'];
          final String ownerIdString = userData['id'];
          final int ownerId = int.parse(ownerIdString); // Convertir a int
          print('El Id es: $ownerId');

          // Utiliza ownerId para crear el grupo
          final GraphQLClient client = GraphQLProvider.of(context).value;
          final MutationOptions groupOptions = MutationOptions(
            document: gql('''
              mutation CreateGroup(
                \$name: String!,
                \$photo: String!,
                \$description: String!,
                \$isPrivate: Boolean!,
                \$ownerId: Int!
              ) {
                createGroup(
                  name: \$name,
                  photo: \$photo,
                  description: \$description,
                  isPrivate: \$isPrivate,
                  ownerId: \$ownerId,
                  inRequests: [],
                  members: [],
                  admins: []
                ) {
                  id
                  name
                  photo
                  description
                  isPrivate
                  ownerId
                  inRequests
                  members
                  admins
                }
              }
            '''),
            variables: {
              'name': _groupName,
              'description': _groupDescription,
              'isPrivate': _groupPrivacy == 'Privado',
              'photo': profilePhotoId,
              'ownerId': ownerId,
            },
          );

          final QueryResult groupResult = await client.mutate(groupOptions);

          if (groupResult.hasException) {
            print('Error creating group: ${groupResult.exception.toString()}');
          } else {
            print('Grupo creado exitosamente: ${groupResult.data}');

            final String groupId = groupResult.data!['createGroup']['id'].toString(); // Convertir a String
            // Agregar el nuevo grupo a myGroups en el usuario
            await _updateUserProfile(context, groupId);

              Navigator.pushReplacementNamed(context, AppRoutes.groupScreen, arguments: groupId);
          }
        }
      }
    } catch (error) {
      print('Error creating group: $error');
    }
  }

  Future<void> _updateUserProfile(BuildContext context, String groupId) async {
    try {
      final String? token = await _getTokenFromSharedPreferences();
      if (token != null) {
        final MutationOptions updateOptions = MutationOptions(
          document: gql('''
            mutation UpdateProfile(\$token: String!, \$myGroups: [String]) {
              editUser(token: \$token, myGroups: \$myGroups) {
                myGroups
              }
            }
          '''),
          variables: {'token': token, 'myGroups': [groupId]},
        );

        final QueryResult updateResult = await GraphQLProvider.of(context).value.mutate(updateOptions);

        if (updateResult.hasException) {
          print('Error updating user profile: ${updateResult.exception.toString()}');
        } else {
          print('User profile updated successfully');
        }
      }
    } catch (error) {
      print('Error updating user profile: $error');
    }
  }
}
