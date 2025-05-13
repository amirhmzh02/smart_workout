// shared/constrain/ip/ip.dart
import 'package:flutter/material.dart';

abstract class IP {
  static const String rumah = "192.168.0.246/Bolt-API";
  static const String rumahsewa = "89.0.142.86";
  static const String other = "192.168.5.27/Bolt-API";  // Just IP (no path)
  static const String utem = "89.0.142.86";
}

// Make this public (remove underscore) so it can be imported
const String activeIP = IP.rumah;  // Now using 'other' IP