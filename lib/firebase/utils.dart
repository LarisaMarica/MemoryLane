import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:http/http.dart' as http;

Future<File?> pickImageFromGallery() async {
  final pickedImage =
      await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickedImage == null) {
    return null;
  }
  return File(pickedImage.path);
}

Future<String> uploadFamilyImageForUser(File file) async {
  try {
    String? uid = await AuthService().getAuthenticatedUserId();
    final storageRef = FirebaseStorage.instance.ref();
    final fileName = file.path.split('/').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'users/$uid/family/$timestamp-$fileName';
    final uploadRef = storageRef.child(path);
    await uploadRef.putFile(file);
    return path;
  } catch (e) {
    print(e);
  }
  return '';
}

Future<bool> deleteImageByPath(String path) async {
  try {
    var storageRef = FirebaseStorage.instance.ref();
    final ref = storageRef.child(path);
    await ref.delete();
    print("File deleted successfully");
    return true;
  } catch (e) {
    print("Failed to delete file: $e");
    return false; 
  }
}

Future<String> uploadFriendImageForUser(File file) async {
  try {
    String? uid = await AuthService().getAuthenticatedUserId();
    final storageRef = FirebaseStorage.instance.ref();
    final fileName = file.path.split('/').last;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'users/$uid/friends/$timestamp-$fileName';
    final uploadRef = storageRef.child(path);
    await uploadRef.putFile(file);
    return path;
  } catch (e) {
    print(e);
  }
  return '';
}

Future<String> getImage(String? path) async {
  if (path == null) {
    return '';
  }
  try {
    final ref = FirebaseStorage.instance.ref().child(path);
    final url = await ref.getDownloadURL();
    return url;
  } catch (e) {
    print(e);
  }
  return '';
}

Future<String> getFamilyImagePath(File file) async {
  String? uid = await AuthService().getAuthenticatedUserId();
  final fileName = file.path.split('/').last;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'users/$uid/family/$timestamp-$fileName';
}

Future<String> getFriendImagePath(File file) async {
  String? uid = await AuthService().getAuthenticatedUserId();
  final fileName = file.path.split('/').last;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'users/$uid/friend/$timestamp-$fileName';
}

Future<String?> fetchUrl(Uri uri, {Map<String, String>? headers}) async {
  try {
    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    }
  } catch (e) {
    print(e);
  }
  return null;
}