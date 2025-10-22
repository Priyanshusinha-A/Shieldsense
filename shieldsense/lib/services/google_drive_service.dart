import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class GoogleDriveService {
  static GoogleSignIn? _googleSignIn;

  static GoogleSignIn get _getGoogleSignIn {
    _googleSignIn ??= GoogleSignIn(
      clientId: '705888705837-of2479lth4mieitcq5oqidlenrv1q5en.apps.googleusercontent.com',
      scopes: [
        drive.DriveApi.driveFileScope,
      ],
    );
    return _googleSignIn!;
  }

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static Future<bool> signIn() async {
    if (isDesktop) {
      print('Google Sign-In is not supported on desktop platforms. Please use this app on Android or iOS devices.');
      return false;
    }

    try {
      final account = await _getGoogleSignIn.signIn();
      if (account != null) {
        print('Google Sign-In successful for: ${account.email}');
        return true;
      } else {
        print('Google Sign-In cancelled by user');
        return false;
      }
    } catch (e) {
      print('Google Sign-In failed: $e');

      // Provide more specific error messages
      if (e.toString().contains('network')) {
        print('Error: Network connection issue. Please check your internet connection.');
      } else if (e.toString().contains('cancelled') || e.toString().contains('user')) {
        print('Error: Sign-in was cancelled by the user.');
      } else if (e.toString().contains('configuration') || e.toString().contains('client')) {
        print('Error: App configuration issue. Please check OAuth client ID in Google Cloud Console.');
      } else if (e.toString().contains('play') || e.toString().contains('services')) {
        print('Error: Google Play Services issue. Please update Google Play Services.');
      } else {
        print('Error: Unknown sign-in error. Please try again or check your Google account settings.');
      }

      return false;
    }
  }

  static Future<void> signOut() async {
    await _getGoogleSignIn.signOut();
  }

  static Future<bool> isSignedIn() async {
    return await _getGoogleSignIn.isSignedIn();
  }

  static Future<String?> getUserEmail() async {
    final account = await _getGoogleSignIn.signInSilently();
    return account?.email;
  }

  static Future<drive.DriveApi?> _getDriveApi() async {
    final googleUser = await _getGoogleSignIn.signInSilently();
    if (googleUser == null) return null;

    final client = await _getGoogleSignIn.authenticatedClient();
    if (client == null) return null;

    return drive.DriveApi(client);
  }

  static Future<String?> uploadFile(File file, {String? folderName}) async {
    if (!isMobile) {
      print('Google Drive upload is only available on mobile platforms (Android/iOS)');
      return null;
    }

    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      // Create or find backup folder
      String? folderId;
      if (folderName != null) {
        folderId = await _createOrGetFolder(driveApi, folderName);
      }

      // Upload file
      final fileName = path.basename(file.path);
      final media = drive.Media(file.openRead(), file.lengthSync());

      final driveFile = drive.File()
        ..name = fileName
        ..parents = folderId != null ? [folderId] : null;

      final uploadedFile = await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );

      return uploadedFile.id;
    } catch (e) {
      print('Error uploading file to Google Drive: $e');
      return null;
    }
  }

  static Future<String?> _createOrGetFolder(drive.DriveApi driveApi, String folderName) async {
    try {
      // Check if folder already exists
      final query = "name = '$folderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
      final existingFolders = await driveApi.files.list(q: query);

      if (existingFolders.files != null && existingFolders.files!.isNotEmpty) {
        return existingFolders.files!.first.id;
      }

      // Create new folder
      final folder = drive.File()
        ..name = folderName
        ..mimeType = 'application/vnd.google-apps.folder';

      final createdFolder = await driveApi.files.create(folder);
      return createdFolder.id;
    } catch (e) {
      print('Error creating/getting folder: $e');
      return null;
    }
  }

  static Future<List<drive.File>?> listFiles({String? folderName}) async {
    if (!isMobile) {
      print('Google Drive file listing is only available on mobile platforms (Android/iOS)');
      return null;
    }

    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return null;

      String? query;
      if (folderName != null) {
        final folderId = await _createOrGetFolder(driveApi, folderName);
        if (folderId != null) {
          query = "'$folderId' in parents and trashed = false";
        }
      } else {
        query = "trashed = false";
      }

      final fileList = await driveApi.files.list(q: query);
      return fileList.files;
    } catch (e) {
      print('Error listing files: $e');
      return null;
    }
  }

  static Future<bool> downloadFile(String fileId, String localPath) async {
    if (!isMobile) {
      print('Google Drive download is only available on mobile platforms (Android/iOS)');
      return false;
    }

    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media?;
      if (media == null) return false;

      final file = File(localPath);
      final bytes = <int>[];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      print('Error downloading file: $e');
      return false;
    }
  }

  static Future<bool> deleteFile(String fileId) async {
    if (!isMobile) {
      print('Google Drive delete is only available on mobile platforms (Android/iOS)');
      return false;
    }

    try {
      final driveApi = await _getDriveApi();
      if (driveApi == null) return false;

      await driveApi.files.delete(fileId);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}
