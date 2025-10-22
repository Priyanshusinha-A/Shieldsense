import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/backup_file.dart';

class BackupService {
  static Future<List<PlatformFile>?> pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        return result.files;
      }
      return null;
    } catch (e) {
      print('Error picking files: $e');
      return null;
    }
  }

  static Future<bool> validateFile(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return false;
      }

      // Check file size (limit to 100MB per file)
      final fileSize = await file.length();
      const maxFileSize = 100 * 1024 * 1024; // 100MB
      if (fileSize > maxFileSize) {
        return false;
      }

      // Check for potentially dangerous file types
      final extension = file.path.split('.').last.toLowerCase();
      const dangerousExtensions = [
        'exe', 'bat', 'cmd', 'scr', 'pif', 'com', 'vbs', 'js', 'jar', 'msi'
      ];

      if (dangerousExtensions.contains(extension)) {
        return false;
      }

      return true;
    } catch (e) {
      print('Error validating file: $e');
      return false;
    }
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static Future<bool> requestStoragePermission() async {
    try {
      // For Android 13+ (API 33+), request granular permissions
      if (await Permission.photos.isGranted &&
          await Permission.videos.isGranted &&
          await Permission.audio.isGranted) {
        return true;
      }

      // Request granular permissions for Android 13+
      final photosStatus = await Permission.photos.request();
      final videosStatus = await Permission.videos.request();
      final audioStatus = await Permission.audio.request();

      // For Android 11+ (API 30+), request manage external storage if needed
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final manageStatus = await Permission.manageExternalStorage.request();

      // Fallback to legacy storage permission for older Android versions
      final storageStatus = await Permission.storage.request();

      return photosStatus.isGranted || videosStatus.isGranted ||
             audioStatus.isGranted || manageStatus.isGranted || storageStatus.isGranted;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<List<BackupFile>> getBackedUpFiles(String userId) async {
    try {
      final backupDir = await _getBackupDirectory(userId);
      final files = <BackupFile>[];

      if (await backupDir.exists()) {
        final entities = backupDir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            final stat = await entity.stat();
            files.add(BackupFile(
              id: entity.path.hashCode.toString(),
              userId: userId,
              fileName: entity.path.split(Platform.pathSeparator).last,
              filePath: entity.path,
              fileSize: stat.size,
              mimeType: _getMimeType(entity.path),
              backupDate: stat.modified,
            ));
          }
        }
      }

      return files;
    } catch (e) {
      print('Error getting backed up files: $e');
      return [];
    }
  }

  static Future<List<BackupFile>> backupFiles(List<PlatformFile> files, String userId) async {
    final backedUpFiles = <BackupFile>[];

    try {
      final backupDir = await _getBackupDirectory(userId);

      for (final file in files) {
        if (file.path != null) {
          final sourceFile = File(file.path!);
          final fileName = file.name;
          final destinationPath = '${backupDir.path}${Platform.pathSeparator}$fileName';

          // Copy file to backup directory
          await sourceFile.copy(destinationPath);

          final destinationFile = File(destinationPath);
          final stat = await destinationFile.stat();

          backedUpFiles.add(BackupFile(
            id: destinationPath.hashCode.toString(),
            userId: userId,
            fileName: fileName,
            filePath: destinationPath,
            fileSize: stat.size,
            mimeType: file.extension != null ? 'application/${file.extension}' : 'application/octet-stream',
            backupDate: stat.modified,
          ));
        }
      }

      return backedUpFiles;
    } catch (e) {
      print('Error backing up files: $e');
      return backedUpFiles;
    }
  }

  static Future<bool> deleteBackupFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting backup file: $e');
      return false;
    }
  }

  static Future<List<File>> getCommonBackupFiles() async {
    final List<File> commonFiles = [];
    final homeDir = Directory(Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '');

    // Common directories to backup
    final commonPaths = [
      'Documents',
      'Pictures',
      'Videos',
      'Music',
      'Desktop',
      'Downloads',
    ];

    for (final path in commonPaths) {
      final dir = Directory('${homeDir.path}${Platform.pathSeparator}$path');
      if (await dir.exists()) {
        try {
          await for (final entity in dir.list(recursive: false, followLinks: false)) {
            if (entity is File) {
              // Limit to reasonable file sizes and safe file types
              final fileSize = await entity.length();
              if (fileSize < 50 * 1024 * 1024) { // 50MB limit
                final extension = entity.path.split('.').last.toLowerCase();
                const safeExtensions = [
                  'txt', 'doc', 'docx', 'pdf', 'jpg', 'jpeg', 'png', 'gif',
                  'mp4', 'avi', 'mov', 'mp3', 'wav', 'xls', 'xlsx', 'ppt', 'pptx'
                ];
                if (safeExtensions.contains(extension)) {
                  commonFiles.add(entity);
                }
              }
            }
          }
        } catch (e) {
          print('Error scanning directory $path: $e');
        }
      }
    }

    return commonFiles.take(20).toList(); // Limit to 20 files
  }

  static Future<Directory> _getBackupDirectory(String userId) async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}${Platform.pathSeparator}backups${Platform.pathSeparator}$userId');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  static String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'avi':
        return 'video/x-msvideo';
      case 'mov':
        return 'video/quicktime';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      default:
        return 'application/octet-stream';
    }
  }
}
