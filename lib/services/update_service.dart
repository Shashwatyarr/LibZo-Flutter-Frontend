import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  static Future<bool> isUpdateAvailable() async {
    try {
      await remoteConfig.setDefaults({
        "latest_version": "0.0.1",
        "update_required": false,
        "update_link": "",
      });

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.fetchAndActivate();

      String latestVersion = remoteConfig.getString("latest_version");
      bool forceUpdate = remoteConfig.getBool("update_required");

      PackageInfo info = await PackageInfo.fromPlatform();
      String currentVersion = info.version;

      print("Latest Version: $latestVersion");
      print("Current Version: $currentVersion");

      // Return TRUE only if both:
      // 1. version mismatch
      // 2. update_required = true
      return (latestVersion != currentVersion) && forceUpdate;

    } catch (e) {
      print("Update check error: $e");
      return false;
    }
  }

  static String getUpdateLink() {
    return remoteConfig.getString("update_link");
  }

  static String getlatestversion(){
    return remoteConfig.getString("latest_version");
  }
}
