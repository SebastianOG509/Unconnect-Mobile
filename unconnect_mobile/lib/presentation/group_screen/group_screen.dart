import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_app_bar.dart';

class GroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final int groupId = _getGroupIdFromArgs(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grupo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF08163B),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildGroupQuery(context, groupId),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createpostScreen, arguments: groupId);
              },
              child: Text('Crear Post'),
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

  Widget _buildGroupQuery(BuildContext context, int groupId) {
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
          print('Error al cargar los datos del grupo: ${result.exception}');
          return Text('Error al cargar los datos del grupo');
        }

        if (result.isLoading) {
          return CircularProgressIndicator();
        }

        final groupData = result.data?['getGroup'];

        if (groupData == null) {
          return Text('No se encontraron datos del grupo');
        }

        return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF08163B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: groupData['photo'] != null && groupData['photo'] != ""
                            ? NetworkImage('http://10.0.2.2:8000/get-file?file_id=${groupData['photo']}')
                            : NetworkImage('https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ListTile(
                  title: Text(
                    '${groupData['name']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                ListTile(
                  title: Text(
                    '${groupData['description']}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                _buildGroupPosts(context, groupId), // Mostrar los posts del grupo
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final int groupId = _getGroupIdFromArgs(context);
                        Navigator.pushNamed(context, AppRoutes.dataGroupScreen, arguments: groupId);
                      },
                      child: Text('Editar Información', style: TextStyle(color: Colors.black)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                        minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _deleteGroup(context, groupId);
                      },
                      child: Text('Eliminar', style: TextStyle(color: Colors.black)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                        minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupPosts(BuildContext context, int groupId) {
    return Query(
      options: QueryOptions(
        document: gql('''
          query GetGroupPosts(\$groupId: Int!, \$page: Int!) {
            getGroupPosts(groupId: \$groupId, page: \$page) {
              id
              content
              media
              createdAt
              createdBy {
                id
                name
              }
            }
          }
        '''),
        variables: {'groupId': groupId, 'page': 0}, // Cambia el valor de 'page' según sea necesario
      ),
      builder: (QueryResult result, {fetchMore, refetch}) {
        if (result.hasException) {
          print('Error al cargar los posts del grupo: ${result.exception}');
          return Text('Error al cargar los posts del grupo');
        }

        if (result.isLoading) {
          return CircularProgressIndicator();
        }

        final List<dynamic>? posts = result.data?['getGroupPosts'];

        if (posts == null || posts.isEmpty) {
          return Text('No hay posts en este grupo');
        }

        return Column(
          children: posts.map((post) {
            return Card(
              child: ListTile(
                title: Text(post['content']),
                subtitle: Text(post['createdAt']),
                // Agregar más elementos de la tarjeta según sea necesario
              ),
            );
          }).toList(),
        );
      },
    );
  }


  int _getGroupIdFromArgs(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      return args;
    } else if (args is String) {
      return int.tryParse(args) ?? 0;
    } else {
      return 0;
    }
  }

  void _deleteGroup(BuildContext context, int groupId) async {
    try {
      final MutationOptions options = MutationOptions(
        document: gql('''
          mutation DeleteGroup(\$groupId: Int!) {
            deleteGroup(groupId: \$groupId)
          }
        '''),
        variables: {
          'groupId': groupId,
        },
      );

      final QueryResult result = await GraphQLProvider.of(context).value.mutate(options);

      if (result.hasException) {
        print('Error al eliminar el grupo: ${result.exception.toString()}');
        Navigator.pushNamed(context, AppRoutes.groupstartScreen);
      } else {
        print('Grupo eliminado exitosamente');
        Navigator.pushNamed(context, AppRoutes.groupstartScreen);
      }
    } catch (error) {
      print('Error al eliminar el grupo: $error');
    }
  }
}
