// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/network_config.dart';

class ApiService {
  static String get baseUrl => NetworkConfig.apiBaseUrl;
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Fetch all orders
  static Future<List<Order>> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Network error: $e');
    }
  }

  // Update order status
  static Future<Order> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: headers,
        body: json.encode({'status': status}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Order.fromJson(data['order']);
      } else {
        throw Exception('Failed to update order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating order: $e');
      throw Exception('Network error: $e');
    }
  }

  // Fetch menu items (optional - for reference)
  static Future<List<MenuItem>> fetchMenuItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu'),
        headers: headers,
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MenuItem.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch menu: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching menu: $e');
      throw Exception('Network error: $e');
    }
  }
}

// Models (no UI dependencies)
class Order {
  final int id;
  final String customerName;
  final String customerEmail;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerName: json['customer_name'] ?? 'Unknown Customer',
      customerEmail: json['customer_email'] ?? '',
      totalPrice: double.parse(json['total_price'].toString()),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int menuItemId;
  final int quantity;
  final double price;
  final MenuItem? menuItem;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.price,
    this.menuItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['order_id'],
      menuItemId: json['menu_item_id'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      menuItem: json['menu_item'] != null 
          ? MenuItem.fromJson(json['menu_item'])
          : null,
    );
  }
}

class MenuItem {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;

  MenuItem({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      price: double.parse(json['price'].toString()),
    );
  }
}