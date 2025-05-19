import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sellers_food_app/models/items.dart';
import 'package:sellers_food_app/upload_screens/items_upload_screen.dart';
import 'package:sellers_food_app/widgets/items_design.dart';
import 'package:sellers_food_app/widgets/my_drawer.dart';
import 'package:sellers_food_app/widgets/text_widget_header.dart';

import '../global/global.dart';
import '../models/menus.dart';
import '../widgets/progress_bar.dart';

class ItemsScreen extends StatefulWidget {
  final Menus? model;
  const ItemsScreen({Key? key, this.model}) : super(key: key);

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  @override
  void initState() {
    super.initState();
    _printDebugInfo();
  }

  void _printDebugInfo() {
    print('=== ITEMS SCREEN DEBUG INFO ===');
    print('Seller UID: ${sharedPreferences?.getString("uid")}');
    print('Menu ID: ${widget.model?.menuID}');
    print('Menu Title: ${widget.model?.menuTitle}');
    print('==============================');
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
              Color(0xFFFAC898),
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
              backgroundColor: const Color(0xFFFAC898),
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  '${widget.model?.menuTitle ?? "Menu"}\'s ',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFFAC898),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ItemsUploadScreen(model:widget.model),
                      ),
                    );
                  },
                ),
              ],
            ),

            SliverPersistentHeader(
              delegate: TextWidgetHeader(
                title: '${widget.model?.menuTitle ?? "Menu"}\'s Items'.toUpperCase(),
              ),
              pinned: true,
            ),

            const SliverToBoxAdapter(
              child: Divider(color: Colors.white, thickness: 2),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("sellers")
                  .doc(sharedPreferences!.getString("uid"))
                  .collection("menus")
                  .doc(widget.model!.menuID)
                  .collection("items")
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Debug prints
                print('\n=== STREAM UPDATE ===');
                print('Connection state: ${snapshot.connectionState}');
                print('Has data: ${snapshot.hasData}');
                print('Has error: ${snapshot.hasError}');
                if (snapshot.hasError) print('Error: ${snapshot.error}');
                if (snapshot.hasData) {
                  print('Items count: ${snapshot.data!.docs.length}');
                  if (snapshot.data!.docs.isNotEmpty) {
                    print('First item: ${snapshot.data!.docs.first.data()}');
                  }
                }

                if (snapshot.hasError) {
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
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text('Нет доступных ${widget.model!.menuID}'),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (c) =>  ItemsUploadScreen(model: widget.model,),
                                ),
                              );
                            },
                            child: const Text('Добавить'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Changed from 4 to 2 for better mobile layout
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final itemData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        print('Building item $index: ${itemData['title']}');
                        
                        Items model = Items.fromJson(itemData);
                        return ItemsDesign(
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