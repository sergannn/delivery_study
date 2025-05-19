import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:users_food_app/assistantMethods/assistant_methods.dart';
import 'package:users_food_app/models/menus.dart';
import 'package:users_food_app/models/sellers.dart';
import 'package:users_food_app/splash_screen/splash_screen.dart';
import 'package:users_food_app/widgets/design/menus_design.dart';

class MenusScreen extends StatefulWidget {
  final Sellers? model;
  const MenusScreen({Key? key, this.model}) : super(key: key);

  @override
  _MenusScreenState createState() => _MenusScreenState();
}

class _MenusScreenState extends State<MenusScreen> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFAC898),
              ],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            clearCartNow(context);
            Navigator.push(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
            Fluttertoast.showToast(msg: "Очищено");
          },
        ),
        title: Text(
          "${widget.model!.sellerName} Меню",
          style: GoogleFonts.lato(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFAC898),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("sellers")
              .doc(widget.model!.sellerUID)
              .collection("menus")
              .orderBy("publishedDate", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return  Center(child: Text("Меню отутствуют "+widget.model!.toJson().toString()));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Menus model = Menus.fromJson(
                    snapshot.data!.docs[index].data()! as Map<String, dynamic>);
                  return MenusDesignWidget(
                    model: model,
                    context: context,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}