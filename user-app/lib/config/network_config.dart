// lib/config/network_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConfig {
  // Your Laravel backend port
  static const int laravelPort = 8000;
  
  // Your React frontend port  
  static const int reactPort = 5713;
  
  // Your computer's IP address (replace with your actual IP)
  static const String hostIP = '192.168.0.96'; // Change this to your IP
  
  // Get appropriate base URL based on platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      // Running in web browser
      return 'http://localhost:$laravelPort/api';
    } else if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to access host machine
      return 'http://10.0.2.2:$laravelPort/api';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return 'http://localhost:$laravelPort/api';
    } else {
      // For real devices, use your computer's IP
      return 'http://$hostIP:$laravelPort/api';
    }
  }
  
  // Get appropriate React URL for QR code
  // QR codes should ALWAYS use real IP address since phones will scan them
  static String get reactMenuUrl {
    return 'http://$hostIP:$reactPort';
  }
  
  // Get URL for direct launch button (platform-specific)
  static String get reactMenuUrlForDirectLaunch {
    if (kIsWeb) {
      return 'http://localhost:$reactPort';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:$reactPort';
    } else if (Platform.isIOS) {
      return 'http://localhost:$reactPort';
    } else {
      return 'http://$hostIP:$reactPort';
    }
  }
  
  // Check if we're running on emulator/simulator
  static bool get isEmulator {
    if (kIsWeb) return false;
    
    // Note: This is a simple check, more sophisticated detection possible
    return Platform.isAndroid || Platform.isIOS;
  }
}

// Usage instructions:
// 1. Find your computer's IP address:
//    - Windows: ipconfig
//    - Mac/Linux: ifconfig or ip addr show
//    - Look for something like 192.168.1.100
//
// 2. Update the hostIP constant above with your actual IP
//
// 3. For real device testing, ensure:
//    - Device and computer are on same WiFi network
//    - Laravel backend is running with --host=0.0.0.0:
//      php artisan serve --host=0.0.0.0 --port=8000
//    - React app is accessible from network