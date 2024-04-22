import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String GET_MY_POSTS = r'''
  query getMyPosts($token: String!, $page: Int!) {
    getMyPosts(token: $token, page: $page) {
      currentPage
      totalPages
      totalCount
      items {
        Id
        Content
        Media
      }
    }
  }
''';

const String DELETE_POST = r'''
  mutation deletePost($token: String!, $PostId: String!) {
    deletePost(token: $token, PostId: $PostId)
  }
''';

class MypostsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Mis Posts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF08163B),
        actions: [
          // Agregar un botón en la parte superior derecha de la AppBar
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.createpostScreen); // Redirigir a la pantalla de creación de posts
            },
            icon: Row(
              children: [
                Text(
                  'Crear Post',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 5), // Espacio entre el texto y el icono
                Icon(Icons.add, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _getTokenFromSharedPreferences(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final token = snapshot.data;
            if (token == null) {
              return Center(
                child: Text('Token de autenticación no encontrado.'),
              );
            } else {
              return Query(
                options: QueryOptions(
                  document: gql(GET_MY_POSTS),
                  variables: {
                    'token': token,
                    'page': 0,
                  },
                ),
                builder: (QueryResult result, {fetchMore, refetch}) {
                  if (result.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (result.hasException) {
                    final errorMessage = result.exception.toString();
                    if (errorMessage.contains("No posts were found for this user")) {
                      return Center(
                        child: Text('Parece que no tienes posts'),
                      );
                    } else {
                      return Center(
                        child: Text('Error: $errorMessage'),
                      );
                    }
                  }

                  final List<dynamic>? posts = result.data?['getMyPosts']['items'];

                  if (posts == null || posts.isEmpty) {
                    return Center(
                      child: Text('No tienes posts para mostrar'),
                    );
                  }

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final post = posts[index];
                      final List<dynamic>? media = post['Media'];
                      return Column(
                        children: [
                          if (index != 0) // Evitar que la primera entrada tenga una línea superior
                            Divider(color: Colors.grey, thickness: 1.0), // Línea divisoria
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 0), // Añadir un espacio horizontal para mejorar la apariencia
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (media != null && media.isNotEmpty)
                                  Image.network(
                                    'http://10.0.2.2:8000/get-file?file_id=${media[0]}',
                                    width: double.infinity, // Establecer el ancho de la imagen en el ancho completo de la pantalla
                                    fit: BoxFit.cover, // Ajustar la imagen para cubrir el ancho de la pantalla
                                  ),
                                SizedBox(height: 8.0), // Añadir un espacio entre la imagen y el texto
                                Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinear los elementos a los lados opuestos
                                    children: [
                                      Text(
                                        post['Content'],
                                        style: TextStyle(fontSize: 16.0),
                                        textAlign: TextAlign.left,
                                      ),
                                      Row(
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
                                              _deletePost(context, token, post['Id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
          }
        },
      ),
      bottomNavigationBar: CustomBottomAppBar(
        icons: [
          Icons.home,
          Icons.group,
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

  Future<String?> _getTokenFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }

  Future<void> _deletePost(BuildContext context, String token, String postId) async {
    final MutationOptions options = MutationOptions(
      document: gql(DELETE_POST),
      variables: {
        'token': token,
        'PostId': postId,
      },
    );

    final QueryResult result = await GraphQLProvider.of(context).value.mutate(options);

    if (result.hasException) {
      print('Error al eliminar el post: ${result.exception.toString()}');
      // Manejar el error
    } else {
      print('Post eliminado exitosamente');
      Navigator.pushNamed(context, AppRoutes.mypostsScreen);
      // Actualizar la lista de posts o realizar otras acciones necesarias después de eliminar el post
    }
  }
}
