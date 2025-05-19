import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sellers_food_app/global/global.dart';
import 'package:sellers_food_app/models/menus.dart';
import 'package:sellers_food_app/widgets/my_drawer.dart';
import 'package:sellers_food_app/widgets/progress_bar.dart';
import 'package:sellers_food_app/widgets/seller_info.dart';

import '../upload_screens/menus_upload_screen.dart';
import '../widgets/info_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _printDebugInfo();
  }

  void _printDebugInfo() {
    print('=== DEBUG INFO ===');
    print('Seller UID: ${sharedPreferences?.getString("uid")}');
    print('=================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer:  MyDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color.fromARGB(255, 116, 112, 108),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              elevation: 1,
              pinned: true,
              backgroundColor: const Color.fromARGB(255, 92, 89, 86),
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Для продавцов',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                centerTitle: false,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color.fromARGB(255, 66, 64, 62),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const MenusUploadScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SliverToBoxAdapter(
              child: SellerInfo(),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(sharedPreferences!.getString("uid"))
                  .collection("menus")
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Debug output
                print('\n=== STREAM UPDATE ===');
                print('Connection state: ${snapshot.connectionState}');
                print('Has data: ${snapshot.hasData}');
                print('Has error: ${snapshot.hasError}');
                
                if (snapshot.hasError) {
                  print('Error details: ${snapshot.error}');
                  return SliverToBoxAdapter(
                    child: Center(child: Text('Ошибка: ${snapshot.error}')),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  print('No menus found in collection');
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Нет доступных меню'),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => const MenusUploadScreen(),
                              ),
                            ),
                            child: const Text('Добавить в меню'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                print('Menus count: ${snapshot.data!.docs.length}');
                print('First menu: ${snapshot.data!.docs.first.data()}');

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Changed from 4 to 2 for better mobile view
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final menuData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        print('Building menu $index: ${menuData['title']}');
                        
                        Menus model = Menus.fromJson(menuData);
                        return InfoDesignWidget(
                          model: model,
                          context: context,
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}