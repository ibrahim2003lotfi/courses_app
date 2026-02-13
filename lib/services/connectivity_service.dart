import 'dart:async';
import 'dart:io';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  Timer? _timer;
  bool _isOnline = true;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  void initialize() {
    _checkConnectivity();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkConnectivity());
  }

  Future<bool> checkConnectivity() async {
    return _checkConnectivity();
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('8.8.8.8');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      _isOnline = false;
    } catch (_) {
      _isOnline = false;
    }
    return _isOnline;
  }

  void dispose() {
    _timer?.cancel();
  }
}
