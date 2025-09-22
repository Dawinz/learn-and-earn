import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:root/root.dart';

class DeviceDetection {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Check if device is an emulator
  static Future<bool> isEmulator() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.isPhysicalDevice == false;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice == false;
      }
      return false;
    } catch (e) {
      print('Error checking emulator status: $e');
      return false;
    }
  }

  /// Check if device is rooted (Android) or jailbroken (iOS)
  static Future<bool> isRooted() async {
    try {
      if (Platform.isAndroid) {
        final result = await Root.isRooted();
        return result ?? false;
      } else if (Platform.isIOS) {
        // iOS jailbreak detection is more complex, return false for now
        return false;
      }
      return false;
    } catch (e) {
      print('Error checking root status: $e');
      return false;
    }
  }

  /// Get device information for debugging
  static Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'hardware': androidInfo.hardware,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'localizedModel': iosInfo.localizedModel,
        };
      }
      return {'platform': 'Unknown'};
    } catch (e) {
      print('Error getting device info: $e');
      return {'platform': 'Unknown', 'error': e.toString()};
    }
  }

  /// Check if device should be blocked from payouts
  static Future<bool> shouldBlockPayouts() async {
    final isEmulatorDevice = await isEmulator();
    final isRootedDevice = await isRooted();

    // Block payouts for emulators and rooted/jailbroken devices
    return isEmulatorDevice || isRootedDevice;
  }

  /// Get device integrity status
  static Future<Map<String, dynamic>> getIntegrityStatus() async {
    final isEmulatorDevice = await isEmulator();
    final isRootedDevice = await isRooted();
    final shouldBlock = await shouldBlockPayouts();

    return {
      'isEmulator': isEmulatorDevice,
      'isRooted': isRootedDevice,
      'shouldBlockPayouts': shouldBlock,
      'deviceInfo': await getDeviceInfo(),
    };
  }
}
