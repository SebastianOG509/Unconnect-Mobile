import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_app_bar.dart';

class GroupsStartScreen extends StatefulWidget {
  @override
  _GroupsStartScreenState createState() => _GroupsStartScreenState();
}

class _GroupsStartScreenState extends State<GroupsStartScreen> {
  List<int> groupIds = [];

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
          return Query(
            options: QueryOptions(
              document: gql('''
                query getUserByAuthId(\$token: String!) {
                  getUserByAuthId(token: \$token) {
                    ID
                    myGroups
                  }
                }
              '''),
              variables: {'token': token},
            ),
            builder: (QueryResult result, {fetchMore, refetch}) {
              if (result.hasException) {
                print('Error al cargar los grupos del usuario: ${result.exception}');
                return Text('Error al cargar los grupos del usuario');
              }

              if (result.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              final Map<String, dynamic> userData = result.data!['getUserByAuthId'];
              final List<dynamic>? userGroups = userData['myGroups'] ?? [];
              print(userGroups);

              // Convertir los ID de grupo de cadenas a enteros
              groupIds = userGroups != null ? userGroups.map<int>((groupId) => int.tryParse(groupId.toString()) ?? 0).toList() : [];

              if (groupIds.isEmpty || groupIds==[]) {
                // Código para cuando no hay grupos asociados
                return Scaffold(
                  // ...
                );
              } else {
                return _buildGroupList(context);
              }
            },
          );
        }
      },
    );
  }

  Widget _buildGroupList(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
      body: Column(
        children: [
          SizedBox(height: 20), // Separación entre el AppBar y el botón
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createGroupScreen);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(350, 50), // Ancho y alto personalizados del botón
            ),
            child: Text(
              'Crear grupo',
              style: TextStyle(
                fontSize: 22.0, // Ajustar el tamaño de la letra
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 20), // Separación entre el AppBar y el botón
          Expanded(
            child: ListView.builder(
              itemCount: groupIds.length,
              itemBuilder: (context, index) {
                final groupId = groupIds[index];
                return Query(
                  options: QueryOptions(
                    document: gql('''
                      query GetGroup(\$groupId: Int!) {
                        getGroup(groupId: \$groupId) {
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
                    variables: {'groupId': groupId},
                  ),
                  builder: (QueryResult result, {fetchMore, refetch}) {
                    if (result.hasException) {
                      //print('Error al cargar los detalles del grupo: ${result.exception}');
                      return Text('');
                    }

                    if (result.isLoading) {
                      return CircularProgressIndicator();
                    }

                    final groupData = result.data!['getGroup'];
                    final groupId = groupData['id'];

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 40, // Ajusta el tamaño del círculo de la imagen
                        backgroundImage: groupData['photo'] != null && groupData['photo'] != ""
                            ? NetworkImage('http://10.0.2.2:8000/get-file?file_id=${groupData['photo']}')
                            : NetworkImage('https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
                      ),
                      title: Text(
                        groupData['name'],
                        style: TextStyle(
                          fontSize: 20, // Ajusta el tamaño de la letra
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // Redirigir al usuario a la página del grupo con el ID del grupo como argumento
                        Navigator.pushNamed(context, AppRoutes.groupScreen, arguments: groupId);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomAppBar(
        icons: [
          Icons.home,
          Icons.groups,
          Icons.post_add,
          Icons.person,
        ],
        routes: [
          AppRoutes.postsScreen,
          AppRoutes.groupstartScreen,
          AppRoutes.mypostsScreen,
          AppRoutes.profileScreen,
        ],
      ),
    );
  }

  Future<String?> _getTokenFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Token recuperado: $token');
    return token;
  }
}
