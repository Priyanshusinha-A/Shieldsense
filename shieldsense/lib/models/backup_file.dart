class BackupFile {
  final String id;
  final String userId;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final DateTime backupDate;
  final String? description;

  BackupFile({
    required this.id,
    required this.userId,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    required this.backupDate,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fileName': fileName,
      'filePath': filePath,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'backupDate': backupDate.toIso8601String(),
      'description': description,
    };
  }

  factory BackupFile.fromJson(Map<String, dynamic> json) {
    return BackupFile(
      id: json['id'],
      userId: json['userId'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      fileSize: json['fileSize'],
      mimeType: json['mimeType'],
      backupDate: DateTime.parse(json['backupDate']),
      description: json['description'],
    );
  }
}
