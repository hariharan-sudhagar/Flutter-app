import 'package:flutter/material.dart';
import 'dart:async';
import 'services/api_service.dart';

void main() {
  runApp(RestaurantPOSApp());
}

// Order status configuration
class OrderStatusConfig {
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final String? nextStatus;
  final String? nextAction;
  final IconData icon;

  OrderStatusConfig({
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    this.nextStatus,
    this.nextAction,
    required this.icon,
  });

  static Map<String, OrderStatusConfig> statusConfigs = {
    'pending': OrderStatusConfig(
      label: 'Pending',
      color: Color(0xFFf59e0b),
      bgColor: Color(0xFFf59e0b).withOpacity(0.1),
      borderColor: Color(0xFFf59e0b).withOpacity(0.3),
      nextStatus: 'in_progress',
      nextAction: 'Start Cooking',
      icon: Icons.schedule,
    ),
    'in_progress': OrderStatusConfig(
      label: 'In Progress',
      color: Color(0xFF3b82f6),
      bgColor: Color(0xFF3b82f6).withOpacity(0.1),
      borderColor: Color(0xFF3b82f6).withOpacity(0.3),
      nextStatus: 'ready',
      nextAction: 'Mark Ready',
      icon: Icons.restaurant,
    ),
    'ready': OrderStatusConfig(
      label: 'Ready',
      color: Color(0xFF10b981),
      bgColor: Color(0xFF10b981).withOpacity(0.1),
      borderColor: Color(0xFF10b981).withOpacity(0.3),
      nextStatus: 'completed',
      nextAction: 'Complete Order',
      icon: Icons.check_circle,
    ),
    'completed': OrderStatusConfig(
      label: 'Completed',
      color: Color(0xFF6b7280),
      bgColor: Color(0xFF6b7280).withOpacity(0.1),
      borderColor: Color(0xFF6b7280).withOpacity(0.3),
      nextStatus: null,
      nextAction: null,
      icon: Icons.done_all,
    ),
  };
}

class RestaurantPOSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF1e293b),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF334155),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: POSPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class POSPage extends StatefulWidget {
  @override
  _POSPageState createState() => _POSPageState();
}

class _POSPageState extends State<POSPage> {
  List<Order> orders = [];
  bool isLoading = true;
  Map<int, bool> updatingOrders = {};
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Auto-refresh every 30 seconds
    refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchOrders(showLoading: false);
      }
    });
  }

  Future<void> _fetchOrders({bool showLoading = true}) async {
    if (showLoading) setState(() => isLoading = true);
    
    try {
      final fetchedOrders = await ApiService.fetchOrders();
      
      // Sort orders by status priority and then by creation time
      final statusPriority = {'pending': 1, 'in_progress': 2, 'ready': 3, 'completed': 4};
      fetchedOrders.sort((a, b) {
        final aPriority = statusPriority[a.status] ?? 5;
        final bPriority = statusPriority[b.status] ?? 5;
        
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
      
      if (mounted) {
        setState(() {
          orders = fetchedOrders;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showErrorSnackBar('Failed to fetch orders: $e');
      }
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    setState(() => updatingOrders[orderId] = true);
    
    try {
      await ApiService.updateOrderStatus(orderId, newStatus);
      await _fetchOrders(showLoading: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #$orderId updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to update order: $e');
      }
    } finally {
      if (mounted) {
        setState(() => updatingOrders[orderId] = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }

  Map<String, int> _getOrderStatusCounts() {
    final counts = <String, int>{};
    for (final status in ['pending', 'in_progress', 'ready', 'completed']) {
      counts[status] = orders.where((order) => order.status == status).length;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1e293b),
              Color(0xFF334155),
              Color(0xFF1e293b),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1e293b).withOpacity(0.95),
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF475569).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kitchen POS',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'Manage orders and kitchen workflow',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : () => _fetchOrders(),
                          icon: Icon(Icons.refresh),
                          label: Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF10b981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Status Summary
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF334155).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF475569).withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Order Status Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _getOrderStatusCounts().entries.map((entry) {
                              final config = OrderStatusConfig.statusConfigs[entry.key]!;
                              return Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: config.bgColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: config.borderColor),
                                    ),
                                    child: Icon(
                                      config.icon,
                                      color: config.color,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${entry.value}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: config.color,
                                    ),
                                  ),
                                  Text(
                                    config.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Orders List
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xFF3b82f6)),
                            SizedBox(height: 16),
                            Text(
                              'Loading orders...',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      )
                    : orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No orders yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Orders from web and app will appear here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _fetchOrders(showLoading: false),
                            child: ListView.builder(
                              padding: EdgeInsets.all(20),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                final statusConfig = OrderStatusConfig.statusConfigs[order.status]!;
                                final isUpdating = updatingOrders[order.id] ?? false;
                                
                                return Container(
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF334155).withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: statusConfig.borderColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Order Header
                                      Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: statusConfig.bgColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          border: Border(
                                            bottom: BorderSide(
                                              color: statusConfig.borderColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Order #${order.id}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  order.customerName,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: statusConfig.color.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: statusConfig.color.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        statusConfig.icon,
                                                        size: 14,
                                                        color: statusConfig.color,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        statusConfig.label,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: statusConfig.color,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  _formatTime(order.createdAt),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white60,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Order Items
                                      Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Items (${order.items.length})',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            
                                            ...order.items.map((item) => Container(
                                              margin: EdgeInsets.only(bottom: 8),
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF1e293b).withOpacity(0.4),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Color(0xFF475569).withOpacity(0.3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          item.menuItem?.name ?? 'Unknown Item',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w500,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(height: 2),
                                                        Text(
                                                          '₹${item.price.toStringAsFixed(0)} × ${item.quantity}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors.white60,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )).toList(),
                                            
                                            // Total
                                            Container(
                                              padding: EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF334155).withOpacity(0.8),
                                                    Color(0xFF475569).withOpacity(0.8),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Color(0xFF64748b).withOpacity(0.5),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'Total Amount',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹${order.totalPrice.toStringAsFixed(0)}',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF10b981),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            SizedBox(height: 16),
                                            
                                            // Action Button
                                            if (statusConfig.nextStatus != null)
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: isUpdating
                                                      ? null
                                                      : () => _updateOrderStatus(
                                                            order.id,
                                                            statusConfig.nextStatus!,
                                                          ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: statusConfig.color,
                                                    foregroundColor: Colors.white,
                                                    padding: EdgeInsets.symmetric(vertical: 12),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  child: isUpdating
                                                      ? Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                                  Colors.white,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text('Updating...'),
                                                          ],
                                                        )
                                                      : Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Icon(
                                                              _getActionIcon(order.status),
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              statusConfig.nextAction!,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                              )
                                            else
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.symmetric(vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: statusConfig.bgColor,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: statusConfig.borderColor,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.check_circle,
                                                      color: statusConfig.color,
                                                      size: 18,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Order Completed',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: statusConfig.color,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getActionIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.play_arrow;
      case 'in_progress':
        return Icons.check;
      case 'ready':
        return Icons.done;
      default:
        return Icons.arrow_forward;
    }
  }
}