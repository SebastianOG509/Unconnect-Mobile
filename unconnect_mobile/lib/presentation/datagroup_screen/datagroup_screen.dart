import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DataGroupScreen extends StatefulWidget {
  @override
  _DataGroupScreenState createState() => _DataGroupScreenState();
}

class _DataGroupScreenState extends State<DataGroupScreen> {
  String _groupName = '';
  String _groupDescription = '';
  String _groupPrivacy = 'Público'; // Valor predeterminado

  @override
  Widget build(BuildContext context) {
    final int groupId = _getGroupIdFromArgs(context);
    print(groupId);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Información del Grupo',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                children: [
                  Text('Privacidad del Grupo:', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _groupPrivacy,
                    onChanged: (value) {
                      setState(() {
                        _groupPrivacy = value!;
                      });
                    },
                    items: ['Público', 'Privado'].map((privacy) {
                      return DropdownMenuItem(
                        value: privacy,
                        child: Text(privacy),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
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
                  _editGroup(groupId);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(16.0), // Ajustar el tamaño del botón
                ),
                child: Text(
                  'Guardar Cambios',
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

  int _getGroupIdFromArgs(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int) {
      return args;
    } else {
      return 0; // Valor predeterminado o manejo de error según sea necesario
    }
  }

  void _editGroup(int groupId) async {
    try {
      final QueryOptions queryOptions = QueryOptions(
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
      );

      final QueryResult groupResult = await GraphQLProvider.of(context).value.query(queryOptions);

      if (groupResult.hasException) {
        print('Error al obtener los datos del grupo: ${groupResult.exception.toString()}');
        return;
      }

      final Map<String, dynamic>? groupData = groupResult.data?['getGroup'];

      if (groupData == null) {
        print('No se encontraron datos del grupo');
        return;
      }

      final MutationOptions options = MutationOptions(
        document: gql('''
          mutation EditGroup(\$groupId: Int!, \$name: String!, \$description: String!, \$isPrivate: Boolean!, \$photo: String!, \$ownerId: Int!) {
            editGroup(groupId: \$groupId, name: \$name, description: \$description, isPrivate: \$isPrivate, photo: \$photo, ownerId: \$ownerId) {
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
          'groupId': groupId,
          'name': _groupName.isNotEmpty ? _groupName : groupData['name'],
          'description': _groupDescription.isNotEmpty ? _groupDescription : groupData['description'],
          'isPrivate': _groupPrivacy == 'Privado',
          'photo': groupData['photo'],
          'ownerId': groupData['ownerId']
        },
      );

      final QueryResult result = await GraphQLProvider.of(context).value.mutate(options);

      if (result.hasException) {
        print('Error al editar el grupo: ${result.exception.toString()}');
      } else {
        print('Grupo editado exitosamente');
      }
    } catch (error) {
      print('Error al editar el grupo: $error');
    }
  }
}
