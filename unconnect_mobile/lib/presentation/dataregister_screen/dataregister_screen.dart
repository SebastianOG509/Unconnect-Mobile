import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../widgets/custom_elevated_button.dart';
import '../../widgets/custom_text_form_field.dart';
import '../../core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController careerController = TextEditingController();
  final TextEditingController memberSinceController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String selectedCampus = 'Amazonía';
  String selectedFaculty = 'AGRONOMÍA';
  String selectedGender = 'Otro';
  DateTime? _selectedDate;

  final List<String> campuses = [
    'Amazonía',
    'Bogotá',
    'Caribe',
    'La Paz',
    'Manizalez',
    'Medellín',
    'Orinoquia',
    'Palmira',
    'Tumaco'
  ];

  final List<String> faculties = [
    'AGRONOMÍA',
    'ARTES',
    'CIENCIAS',
    'CIENCIAS AGRARIAS',
    'CIENCIAS ECONÓMICAS',
    'CIENCIAS HUMANAS',
    'DERECHO, CIENCIAS POLÍTICAS Y SOCIALES',
    'ENFERMERÍA',
    'INGENIERÍA',
    'MEDICINA',
    'MEDICINA VETERINARIA Y DE ZOOTECNIA',
    'ODONTOLOGÍA'
  ];

  final List<String> Genders = [
    'Masculino',
    'Femenino',
    'Otro'
  ];


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getTokenFromSharedPreferences(), // Obtener el token de SharedPreferences
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final String? token = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false, // No mostrar flecha de retorno
              title: Text('Complete Your Profile'),
            ),
            body: Query(
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
                    }
                  }
                '''),
                variables: {'token': token},
              ),
              builder: (QueryResult result, {fetchMore, refetch}) {
                if (result.isLoading) {
                  return CircularProgressIndicator();
                }

                if (result.hasException) {
                  print('Error: ${result.exception}');
                  return Text('Error fetching data');
                }

                final userData = result.data?['getUserByAuthId'];
                if (userData != null && userData['Name'] != null && userData['Name'] != "") {
                  // Precargar los datos en los controladores de los campos del formulario
                  nameController.text = userData['Name'];
                  lastNameController.text = userData['LastName'];
                  birthdayController.text = userData['Birthday'];
                  selectedCampus = userData['Campus'];
                  selectedFaculty = userData['Faculty'];
                  careerController.text = userData['Career'];
                  memberSinceController.text = userData['MemberUNSince'].toString();
                  phoneNumberController.text = userData['PhoneNumber'];
                  selectedGender = userData['Gender'];
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextFormField(
                        controller: nameController,
                        hintText: 'Name',
                      ),
                      SizedBox(height: 16.0),
                      CustomTextFormField(
                        controller: lastNameController,
                        hintText: 'Last Name',
                      ),
                      SizedBox(height: 16.0),
                      SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            // Actualiza el valor del campo de texto con la fecha seleccionada
                            birthdayController.text = pickedDate.toString().substring(0, 10);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: birthdayController,
                                  enabled: false, // Para deshabilitar la edición directa del texto
                                  decoration: InputDecoration(
                                    hintText: 'Birthday',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () async {
                                  final DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (pickedDate != null) {
                                    // Actualiza el valor del campo de texto con la fecha seleccionada
                                    birthdayController.text = pickedDate.toString().substring(0, 10);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: selectedCampus,
                        onChanged: (newValue) {
                          selectedCampus = newValue!;
                        },
                        items: campuses.map<DropdownMenuItem<String>>((String campus) {
                          return DropdownMenuItem<String>(
                            value: campus,
                            child: Text(campus),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Campus',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: selectedFaculty,
                        onChanged: (newValue) {
                          selectedFaculty = newValue!;
                        },
                        items: faculties.map<DropdownMenuItem<String>>((String faculty) {
                          return DropdownMenuItem<String>(
                            value: faculty,
                            child: Text(faculty),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Faculty',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      CustomTextFormField(
                        controller: careerController,
                        hintText: 'Career',
                      ),
                      SizedBox(height: 16.0),
                      CustomTextFormField(
                        controller: memberSinceController,
                        hintText: 'Member Since',
                      ),
                      SizedBox(height: 16.0),
                      CustomTextFormField(
                        controller: phoneNumberController,
                        hintText: 'Phone Number',
                      ),
                      SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        onChanged: (newValue) {
                          selectedGender = newValue!;
                        },
                        items: Genders.map<DropdownMenuItem<String>>((String faculty) {
                          return DropdownMenuItem<String>(
                            value: faculty,
                            child: Text(faculty),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Faculty',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      CustomElevatedButton(
                        width: 159.h,
                        text: "Guardar",
                        buttonTextStyle: CustomTextStyles.titleSmallBlack900,
                        onPressed: () => _updateProfile(context),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<String?> _getTokenFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


void _updateProfile(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    print(prefs.getString('token'));

    if (token != null) {
      final MutationOptions options = MutationOptions(
        document: gql('''
          mutation UpdateProfile(
            \$token: String!
            \$Name: String
            \$LastName: String
            \$Birthday: String
            \$Campus: String
            \$Faculty: String
            \$Career: String
            \$MemberUNSince: Int
            \$PhoneNumber: String
            \$Gender: String
          ) {
            editUser(
              token: \$token
              Name: \$Name
              LastName: \$LastName
              Birthday: \$Birthday
              Campus: \$Campus
              Faculty: \$Faculty
              Career: \$Career
              MemberUNSince: \$MemberUNSince
              PhoneNumber: \$PhoneNumber
              Gender: \$Gender
            ) {
              Name
              LastName
              Birthday
              Campus
              Faculty
              Career
              MemberUNSince
              PhoneNumber
              Gender
            }
          }
        '''),
        variables: {
          'token': token,
          'Name': nameController.text,
          'LastName': lastNameController.text,
          'Birthday': birthdayController.text,
          'Campus': selectedCampus,
          'Faculty': selectedFaculty,
          'Career': careerController.text,
          'MemberUNSince': int.tryParse(memberSinceController.text),
          'PhoneNumber': phoneNumberController.text,
          'Gender': selectedGender,
        },
      );

      final QueryResult result = await GraphQLProvider.of(context).value.mutate(options);

      if (result.hasException) {
        print('Error: ${result.exception.toString()}');
        print('paila');
      } else {
        print('Usuario actualizado exitosamente');
        Navigator.pushNamed(context, AppRoutes.postsScreen);
      }
    } else {
      // Manejar caso en el que no se encuentre el token en SharedPreferences
    }
  }
}
