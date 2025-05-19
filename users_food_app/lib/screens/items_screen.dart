import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:users_food_app/widgets/app_bar.dart';
import 'package:users_food_app/widgets/design/items_design.dart';

import '../models/items.dart';
import '../models/menus.dart';
import '../widgets/progress_bar.dart';

class ItemsScreen extends StatefulWidget {
  final Menus? model;
  const ItemsScreen({Key? key, this.model}) : super(key: key);

  @override
  _ItemsScreenState createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _printDebugInfo() {
    print('=== DEBUG INFO ===');
    print('Seller UID: ${widget.model?.sellerUID ?? 'NULL'}');
    print('Menu ID: ${widget.model?.menuID ?? 'NULL'}');
    print('Menu Title: ${widget.model?.menuTitle ?? 'NULL'}');
    print('==================');
  }

  @override
  void initState() {
    super.initState();
    _printDebugInfo();
  }
void _checkFirestorePath() async {
  try {
    print('=== FIRESTORE PATH VERIFICATION ===');
    
    // Проверка существования документа продавца
    final sellerDoc = await FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.model!.sellerUID)
        .get();
    print('Seller exists: ${sellerDoc.exists}');
    
    // Проверка существования меню
    final menuDoc = await FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.model!.sellerUID)
        .collection("menus")
        .doc(widget.model!.menuID)
        .get();
    print('Menu exists: ${menuDoc.exists}');
    
    // Проверка элементов
    final itemsQuery = await FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.model!.sellerUID)
        .collection("menus")
        .doc(widget.model!.menuID)
        .collection("items")
        .get();
    
    print('Items count: ${itemsQuery.docs.length}');
    if (itemsQuery.docs.isNotEmpty) {
      print('First item ID: ${itemsQuery.docs.first.id}');
      print('First item data: ${itemsQuery.docs.first.data()}');
    }
  } catch (e) {
    print('Verification error: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: MyAppBar(sellerUID: widget.model!.sellerUID),
      ),
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
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.7),
              child: Text(
                '${widget.model!.menuTitle}\'s продукты в меню'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white, thickness: 2),

            // Items Grid Section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection("sellers")
      .doc(widget.model!.sellerUID)
      .collection("menus")
      .doc(widget.model!.menuID)
      .collection("items")
      .snapshots(),
  builder: (context, snapshot) {
    // Расширенная отладка
    print('=== FIREBASE QUERY DEBUG ===');
    print('Full path: sellers/${widget.model!.sellerUID}/menus/${widget.model!.menuID}/items');
    
    if (snapshot.hasError) {
      print('ERROR: ${snapshot.error}');
      return Center(child: Text('Ошибка: ${snapshot.error}'));
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: circularProgress());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      print('DOCUMENT PATHS IN COLLECTION:');
      
      // Дополнительная проверка существования коллекции
      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.model!.sellerUID)
          .collection("menus")
          .doc(widget.model!.menuID)
          .collection("items")
          .get()
          .then((querySnapshot) {
            print('TOTAL ITEMS FOUND: ${querySnapshot.docs.length}');
            if (querySnapshot.docs.isNotEmpty) {
              print('FIRST ITEM DATA: ${querySnapshot.docs.first.data()}');
            }
          });

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Пусто'),
            TextButton(
              child: const Text('Обновить'),
              onPressed: () => setState(() {}),
            ),
            TextButton(
              child: const Text('Проверить БД'),
              onPressed: () {
                print('Checking Firestore path...');
                _checkFirestorePath();
              },
            ),
          ],
        ),
      );
    }

    print('ITEMS COUNT: ${snapshot.data!.docs.length}');
    print('FIRST ITEM: ${snapshot.data!.docs.first.data()}');

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        final item = snapshot.data!.docs[index];
        print('Item $index: ${item.id} - ${item.data()}');
        return ItemsDesignWidget(
          model: Items.fromJson(item.data() as Map<String, dynamic>),
        );
      },
    );
  },
),
            ),
          ],
        ),
      ),
    );
  }
}