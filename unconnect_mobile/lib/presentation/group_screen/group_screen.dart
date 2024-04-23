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
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _buildGroupQuery(context, groupId),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final int groupId = _getGroupIdFromArgs(context);
          Navigator.pushNamed(context, AppRoutes.createpostScreen, arguments: groupId);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
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
          return Center(child: CircularProgressIndicator());
        }

        final groupData = result.data?['getGroup'];

        if (groupData == null) {
          return Text('No se encontraron datos del grupo');
        }

        return Column(
          children: [
            Container(
              color: Color(0xFF08163B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: groupData['photo'] != null && groupData['photo'] != ""
                        ? NetworkImage('http://10.0.2.2:8000/get-file?file_id=${groupData['photo']}')
                        : NetworkImage('https://www.shutterstock.com/image-vector/blank-avatar-photo-place-holder-600nw-1095249842.jpg'),
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
                  SizedBox(height: 20), // Agrega espacio adicional arriba de los botones
                ],
              ),
            ),
            Expanded(
              child: _buildGroupPosts(context, groupId), // Convertir groupId a String
            ),
          ],
        );
      },
    );
  }

  Widget _buildGroupPosts(BuildContext context, int groupId) {
    return Query(
      options: QueryOptions(
        document: gql('''
        query GetGroupPosts(\$groupId: String!, \$page: Int!) {
          getGroupPosts(GroupId: \$groupId, page: \$page) {
            items {
            }
          }
        }
      '''),
        variables: {
          'groupId': groupId.toString(), // Convertir groupId a String
          'page': 1,
        },
      ),
      builder: (QueryResult result, {fetchMore, refetch}) {
        print("groupId: $groupId");
        print(groupId.runtimeType);
        print("result: $result");

        final List<dynamic>? posts = result.data?['getGroupPosts']['items'];
        if (result.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (posts == null || posts.isEmpty) {
          return Center(child: Text('No hay posts en este grupo'));
        }

        if (result.hasException) {
          return Center(child: Text('Error al cargar los posts del grupo'));
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (BuildContext context, int index) {
            final post = posts[index];
            final List<dynamic>? media = post['media'];
            return Column(
              children: [
                if (index != 0) Divider(color: Colors.grey, thickness: 1.0), // Línea divisoria entre los posts
                ListTile(
                  title: Text(post['content']),
                  subtitle: media != null && media.isNotEmpty
                      ? Image.network(
                    'http://10.0.2.2:8000/get-file?file_id=${media[0]}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Lógica para editar el post
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          // Lógica para eliminar el post
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
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
      print(result);
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
