import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellers_food_app/authentication/login.dart';
import 'package:sellers_food_app/screens/history_screen.dart';
import 'package:sellers_food_app/screens/home_screen.dart';
import 'package:sellers_food_app/screens/new_orders_screen.dart';

import '../global/global.dart';
import '../admin/screens/home_screen2.dart';//sellers_food_app/lib/admin/screens/home_screen2.dart
class MyDrawer extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  MyDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: FractionalOffset(-2.0, 0.0),
            end: FractionalOffset(5.0, -1.0),
            colors: [
              Color.fromARGB(255, 52, 12, 185),
              Color.fromARGB(255, 52, 12, 185),
            ],
          ),
        ),
        child: ListView(
          children: [
            //header drawer
            Container(
              padding: const EdgeInsets.only(top: 25, bottom: 10),
              child: Column(
                children: [
                  Material(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(80),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: SizedBox(
                        height: 160,
                        width: 160,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.4),
                                offset: const Offset(-1, 10),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            //we get the profile image from sharedPreferences (global.dart)
                            backgroundImage: NetworkImage(
                              'https://www.servicenow.com/community/s/legacyfs/online/avatars_servicenow/a9a7392fdbbfdb00d58ea345ca96198f.jpg'
//                              sharedPreferences!.getString("photoUrl")!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  //we get the user name from sharedPreferences (global.dart)
                  Text(
                    sharedPreferences!.getString("name")!,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            //body drawer
            Container(
              padding: const EdgeInsets.only(top: 1),
              child: Column(
                children: [
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.home,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'Домой',
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 20,color:Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.reorder,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'Новые заказы',
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 20,color:Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const NewOrdersScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.local_shipping,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'История',
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 20,color:Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                   ListTile(
                    leading: const Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'Админ',
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 20,color:Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                     
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const AdminHomeScreen(),
                          ),
                        );
                    
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text(
                      'Выход',
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(
                          fontSize: 20,color:Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      firebaseAuth.signOut().then((value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const LoginScreen(),
                          ),
                        );
                        _controller.clear();
                      });
                    },
                  ),
                  const Divider(
                    height: 10,
                    color: Colors.white,
                    thickness: 2,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
