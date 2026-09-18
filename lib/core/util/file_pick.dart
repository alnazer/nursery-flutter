import 'package:file_picker/file_picker.dart';

import '../api/api_client.dart';

/// يفتح منتقي ملفات النظام ويحوّل الاختيار إلى ملف جاهز للرفع.
Future<UploadFile?> pickUploadFile({
  required String field,
  List<String>? extensions,
}) async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    withData: true,
    type: extensions == null || extensions.isEmpty ? FileType.any : FileType.custom,
    allowedExtensions: extensions,
  );
  if (result == null || result.files.isEmpty) {
    return null;
  }
  final PlatformFile file = result.files.first;
  final List<int>? bytes = file.bytes;
  if (bytes == null) {
    return null;
  }

  return UploadFile(
    field: field,
    filename: file.name,
    bytes: bytes,
    contentType: mimeForExtension(file.extension),
  );
}

/// نوع المحتوى من الامتداد — يكفي لما يقبله الخادم.
String mimeForExtension(String? extension) {
  switch ((extension ?? '').toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'heic':
      return 'image/heic';
    case 'webp':
      return 'image/webp';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    default:
      return 'application/octet-stream';
  }
}
