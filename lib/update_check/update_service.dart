import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';

class UpdateService {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero, // SET TO ZERO FOR TESTING
    ));

    await _remoteConfig.setDefaults({'min_required_version': '1.0.0'});

    bool activated = await _remoteConfig.fetchAndActivate();
    debugPrint('Remote Config fetched. Activated new values: $activated');

    final fetchedVersion = _remoteConfig.getString('min_required_version');
    debugPrint('min_required_version from Firebase: $fetchedVersion');
  }

  static Future<bool> isUpdateRequired() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;
    final minVersion = _remoteConfig.getString('min_required_version');

    debugPrint('Current app version: $currentVersion');
    debugPrint('Min required version: $minVersion');

    final result = _isVersionLower(currentVersion, minVersion);
    debugPrint('Update required: $result');

    return result;
  }

  static bool _isVersionLower(String current, String minimum) {
    final cur = current.split('.').map(int.parse).toList();
    final min = minimum.split('.').map(int.parse).toList();

    for (int i = 0; i < min.length; i++) {
      final c = i < cur.length ? cur[i] : 0;
      if (c < min[i]) return true;
      if (c > min[i]) return false;
    }
    return false;
  }
}