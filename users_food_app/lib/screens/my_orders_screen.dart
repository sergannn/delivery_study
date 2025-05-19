import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:users_food_app/assistantMethods/assistant_methods.dart';
import 'package:users_food_app/global/global.dart';
import 'package:users_food_app/widgets/design/order_card_design.dart';
import 'package:users_food_app/widgets/progress_bar.dart';
import 'package:users_food_app/widgets/simple_app_bar.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({Key? key}) : super(key: key);

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    _printInitialDebugInfo();
  }

  void _printInitialDebugInfo() {
    debugPrint('=== MY ORDERS SCREEN INITIALIZED ===');
    debugPrint('User UID: ${sharedPreferences?.getString("uid")}');
    debugPrint('===================================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child:  SimpleAppBar(title: "My Orders"),
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
              .collection("users")
              .doc(sharedPreferences!.getString("uid"))
              .collection("orders")
              .where("status", isEqualTo: "normal")
              .orderBy("orderTime", descending: true)
              .snapshots(),
          builder: (context, ordersSnapshot) {
            _debugPrintOrdersSnapshot(ordersSnapshot);

            if (ordersSnapshot.hasError) {
              return _buildErrorWidget(ordersSnapshot.error.toString());
            }

            if (ordersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!ordersSnapshot.hasData || ordersSnapshot.data!.docs.isEmpty) {
              return _buildEmptyOrdersWidget();
            }

            return ListView.builder(
              itemCount: ordersSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final orderDoc = ordersSnapshot.data!.docs[index];
                final orderData = orderDoc.data() as Map<String, dynamic>;
                
                debugPrint('\nProcessing order ${orderDoc.id}');
                debugPrint('Order data: $orderData');

                return FutureBuilder<QuerySnapshot>(
                  future: _fetchOrderItems(orderData, orderDoc.id),
                  builder: (context, itemsSnapshot) {
                    _debugPrintItemsSnapshot(itemsSnapshot, orderDoc.id);

                    if (itemsSnapshot.hasError) {
                      return _buildOrderErrorCard(
                        orderDoc.id, 
                        itemsSnapshot.error.toString()
                      );
                    }

                    if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                      return _buildOrderLoadingCard(orderDoc.id);
                    }

                    if (!itemsSnapshot.hasData || itemsSnapshot.data!.docs.isEmpty) {
                      return _buildEmptyOrderItemsCard(orderDoc.id);
                    }

                    return OrderCard(
                      itemCount: itemsSnapshot.data!.docs.length,
                      data: itemsSnapshot.data!.docs,
                      orderID: orderDoc.id,
                      seperateQuantitiesList: separateOrderItemQuantities(
                        orderData["productIDs"]
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<QuerySnapshot> _fetchOrderItems(Map<String, dynamic> orderData, String orderId) async {
    debugPrint('\nFetching items for order $orderId');
    
    final productIDs = separateOrdesItemIDs(orderData["productIDs"]);
    final orderBy = orderData["uid"];
    
    debugPrint('Product IDs: $productIDs');
    debugPrint('Order by UID: $orderBy');

    if (productIDs.isEmpty) {
      debugPrint('No product IDs found for order $orderId');
      throw Exception('No product IDs in order');
    }

        return await FirebaseFirestore.instance
    .collection("items")
    .where("itemID", whereIn: productIDs)
    .where("orderBy", isEqualTo: orderBy)
    .get();
  }

  void _debugPrintOrdersSnapshot(AsyncSnapshot<QuerySnapshot> snapshot) {
    debugPrint('\n=== ORDERS STREAM UPDATE ===');
    debugPrint('Connection state: ${snapshot.connectionState}');
    debugPrint('Has data: ${snapshot.hasData}');
    debugPrint('Has error: ${snapshot.hasError}');
    
    if (snapshot.hasError) {
      debugPrint('Error: ${snapshot.error}');
    }
    
    if (snapshot.hasData) {
      debugPrint('Number of orders: ${snapshot.data!.docs.length}');
      if (snapshot.data!.docs.isNotEmpty) {
        debugPrint('First order ID: ${snapshot.data!.docs.first.id}');
      }
    }
  }

  void _debugPrintItemsSnapshot(AsyncSnapshot<QuerySnapshot> snapshot, String orderId) {
    debugPrint('\n=== ITEMS FOR ORDER $orderId ===');
    debugPrint('Connection state: ${snapshot.connectionState}');
    debugPrint('Has data: ${snapshot.hasData}');
    debugPrint('Has error: ${snapshot.hasError}');
    
    if (snapshot.hasError) {
      debugPrint('Error: ${snapshot.error}');
    }
    
    if (snapshot.hasData) {
      debugPrint('Number of items: ${snapshot.data!.docs.length}');
      if (snapshot.data!.docs.isNotEmpty) {
        debugPrint('First item ID: ${snapshot.data!.docs.first.id}');
      }
    }
  }

  Widget _buildErrorWidget(String error) {
    debugPrint('Displaying error widget: $error');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 50, color: Colors.red),
          const SizedBox(height: 20),
          Text('Ошибка загрузки', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 10),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersWidget() {
    debugPrint('Displaying empty orders widget');
    return const Center(
      child: Text('Не найдено', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _buildOrderErrorCard(String orderId, String error) {
    debugPrint('Error loading items for order $orderId: $error');
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Заказ #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(height: 10),
            Text('Загрузка не удалась', style: TextStyle(color: Colors.grey[600])),
            Text(error, style: const TextStyle(color: Colors.blue, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderLoadingCard(String orderId) {
    debugPrint('Loading items for order $orderId');
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Заказ #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text('Загрузка...'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrderItemsCard(String orderId) {
    debugPrint('No items found for order $orderId');
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Заказ #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(height: 10),
            const Text('Заказ пустой'),
          ],
        ),
      ),
    );
  }
}