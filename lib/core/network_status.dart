import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> choreIsOnline() async {
  final r = await Connectivity().checkConnectivity();
  if (r.isEmpty) return false;
  return !r.contains(ConnectivityResult.none);
}
