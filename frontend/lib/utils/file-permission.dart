import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPhotosPermission() async {
  var status = await Permission.storage.status;
  if (status.isGranted) {
    return true;
  } else {
    status = await Permission.photos.request();
    return status.isGranted;
  }
}