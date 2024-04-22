import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/app_export.dart';
import '../../widgets/custom_bottom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Consultas y Mutaciones
const String GET_COMMENTS_BY_POST = r'''
	query GetCommentsByPost($postId: String!, $page: Int!) {
		getcommentbyPost(PostId: $postId, page: $page) {
			currentPage
			totalPages
			totalCount
			items {
				Id
				Content
				UserId
				PostId
			}
		}
	}
''';

const String CREATE_COMMENT = r'''
	mutation CreateComment($token: String!, $postId: String!, $content: String!) {
		createcomment(token: $token, PostId: $postId, Content: $content) {
			Id
			Content
			UserId
			PostId
		}
	}
''';

const String UPDATE_COMMENT = r'''
	mutation UpdateComment($token: String!, $commentId: String!, $content: String!) {
		updateComment(token: $token, CommentId: $commentId, Content: $content) {
			Id
			Content
			UserId
			PostId
		}
	}
''';

const String DELETE_COMMENT = r'''
	mutation deletecomment(
		$token: String!
		$postId: String!
		$commentId: String!
	) {
		deleteComment(token: $token, PostId: $postId, CommentId: $commentId)
	}
''';

const String GET_FEED = r'''
	query GetFeed($token: String!, $page: Int!) {
		getFeed(token: $token, page: $page) {
			currentPage
			totalPages
			totalCount
			items {
				Id
				Content
				Media
				UserId
			}
		}
	}
''';

class PostsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'UNConnect',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF08163B),
      ),
      body: PostList(),
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
}

class PostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
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
                document: gql(GET_FEED),
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
                  return Center(
                    child: Text('Error: $errorMessage'),
                  );
                }

                final List<dynamic>? posts = result.data?['getFeed']['items'];

                if (posts == null || posts.isEmpty) {
                  return Center(
                    child: Text('No hay posts para mostrar'),
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
                                child: Text(
                                  post['Content'],
                                  style: TextStyle(fontSize: 16.0),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              // Mostrar los comentarios
                              _buildCommentList(context, token, post['Id']),
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
    );
  }

  Widget _buildCommentList(BuildContext context, String token, String postId) {
    return Query(
      options: QueryOptions(
        document: gql(GET_COMMENTS_BY_POST),
        variables: {
          'postId': postId,
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No hay comentarios'),
                FloatingActionButton(
                  onPressed: () => _addComment(context, token, postId),
                  child: Icon(Icons.add),
                ),
              ],
            ),
          );
        }

        final List<dynamic>? comments = result.data?['getcommentbyPost']['items'];

        if (comments == null || comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No hay comentarios para mostrar'),
                FloatingActionButton(
                  onPressed: () => _addComment(context, token, postId),
                  child: Icon(Icons.add),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...comments.map((comment) => _buildCommentWidget(context, token, comment)).toList(),
            FloatingActionButton(
              onPressed: () => _addComment(context, token, postId),
              child: Center(
                child: Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }




  Widget _buildCommentWidget(BuildContext context, String token, dynamic comment) {
    return ListTile(
      title: Text(comment['Content']),
      subtitle: Text('Usuario: ${comment['UserId']}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editComment(context, token, comment),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteComment(context, token, comment),
          ),
        ],
      ),
    );
  }


  void _editComment(BuildContext context, String token, dynamic comment) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _controller = TextEditingController(text: comment['Content']);
        return AlertDialog(
          title: Text('Editar Comentario'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Ingrese el nuevo comentario'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      // El usuario confirmó la edición del comentario
      final MutationOptions options = MutationOptions(
        document: gql(UPDATE_COMMENT),
        variables: {
          'token': token,
          'commentId': comment['Id'],
          'content': result,
        },
      );

      final QueryResult mutationResult = await GraphQLProvider.of(context).value.mutate(options);

      if (mutationResult.hasException) {
        final errorMessage = mutationResult.exception.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al editar el comentario: $errorMessage'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comentario editado exitosamente'),
          ),
        );
        // Actualizar la lista de comentarios
        // Puedes implementar esta lógica según cómo actualizas la lista en tu aplicación
      }
    }
  }

  void _deleteComment(BuildContext context, String token, dynamic comment) async {
    // Llamar al método de eliminación de comentario
    final MutationOptions options = MutationOptions(
      document: gql(DELETE_COMMENT),
      variables: {
        'token': token,
        'postId': comment['PostId'],
        'commentId': comment['Id'],
      },
    );

    final QueryResult mutationResult = await GraphQLProvider.of(context).value.mutate(options);

    if (mutationResult.hasException) {
      final errorMessage = mutationResult.exception.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el comentario: $errorMessage'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comentario eliminado exitosamente'),
        ),
      );
      // Actualizar la lista de comentarios
      // Puedes implementar esta lógica según cómo actualizas la lista en tu aplicación
    }
  }

  void _addComment(BuildContext context, String token, String postId) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _controller = TextEditingController();
        return AlertDialog(
          title: Text('Agregar Comentario'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Ingrese el comentario'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
              child: Text('Agregar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      // El usuario confirmó agregar el comentario
      final MutationOptions options = MutationOptions(
        document: gql(CREATE_COMMENT),
        variables: {
          'token': token,
          'postId': postId,
          'content': result,
        },
      );

      final QueryResult mutationResult = await GraphQLProvider.of(context).value.mutate(options);

      if (mutationResult.hasException) {
        final errorMessage = mutationResult.exception.toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar el comentario: $errorMessage'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comentario agregado exitosamente'),
          ),
        );
        // Actualizar la lista de comentarios
        // Puedes implementar esta lógica según cómo actualizas la lista en tu aplicación
      }
    }
  }


  Future<String?> _getTokenFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token;
  }
}
