import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:users_food_app/authentication/login.dart';
import 'package:users_food_app/models/sellers.dart';
import 'package:users_food_app/widgets/design/sellers_design.dart';
import 'package:users_food_app/widgets/items_avatar_carousel.dart';
import 'package:users_food_app/widgets/my_drawer.dart';
import 'package:users_food_app/widgets/seller_avatar_carousel.dart';
import 'package:users_food_app/widgets/user_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Рестораны', style: GoogleFonts.lato()),
        backgroundColor: const Color(0xFFFAC898),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _auth.signOut().then((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const LoginScreen()),
              );
            }),
          ),
        ],
      ),
      drawer:  MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFAC898)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const UserInformation(),
              const SizedBox(height: 16),
              
              // Carousels Row
              SizedBox(
                height: 200,
                child: Row(
                  children: const [
                    Expanded(child: SellerCarouselWidget()),
                    SizedBox(width: 8),
                    Expanded(child: ItemsAvatarCarousel()),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Все рестораны',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Restaurants Grid
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection("sellers").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Нет доступных ресторанов'),
                    );
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final seller = Sellers.fromJson(
                          snapshot.data!.docs[index].data() as Map<String, dynamic>);
                        return SellersDesignWidget(
                          model: seller,
                          context: context,
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}