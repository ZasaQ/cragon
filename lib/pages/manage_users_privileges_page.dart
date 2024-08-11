import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

import 'package:cragon/services/utilities.dart';


class ManageUsersPrivilegesPage extends StatefulWidget {
  const ManageUsersPrivilegesPage({super.key});

  @override
  State<ManageUsersPrivilegesPage> createState() => _ManageUsersPrivilegesPageState();
}

class _ManageUsersPrivilegesPageState extends State<ManageUsersPrivilegesPage> {

  @override
  void initState() {
    super.initState();
    
    developer.log(
      name: "ManageUsersPrivilegesPage -> initState",
      "Current user has entered ManageUsersPrivilegesPage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(128, 128, 0, 1),
      ),
      body: Column(
        children: <Widget>[
          const Icon(
            Icons.admin_panel_settings,
            size: 100,
          ),

          const Center(
            child: Text('Here you can manage privileges of users',
              style: TextStyle(color: Colors.black, fontSize: 16.0)
            ),
          ),

          const SizedBox(height: 50,),

          StreamBuilder(
            stream: utilsUsersCollection.orderBy('email').snapshots(),
            builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> usersSnapshot) {
              if(usersSnapshot.hasError) {
                return const Text("Can't load users");
              }

              if(usersSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: usersSnapshot.data!.docs.map((DocumentSnapshot document){
                      Map<String,dynamic> userData = document.data()! as Map<String, dynamic>;
                      
                      return ListTile(
                        title: Text(userData["email"]),
                        subtitle: userData["isAdmin"] ? const Text("Admin") : const Text("Normal User"),
                        trailing: Wrap(children: [
                          IconButton(onPressed: () async {
                            await utilsUsersCollection.doc(userData["uid"]).update(
                              {
                                'isAdmin': !userData["isAdmin"]
                              }
                            );
                          },
                          icon: const Icon(Icons.admin_panel_settings))
                        ]),
                      );
                    }).toList()
                  ),
                )
              );
            }
          )
        ]
      ),
    );
  }
}