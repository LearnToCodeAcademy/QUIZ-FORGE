import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import '../models/models.dart';

class FileParsingService {
  // Extract text from various file types
  static Future<String?> extractTextFromFile(UploadedFileMeta fileMeta) async {
    try {
      final extension = fileMeta.name.split('.').last.toLowerCase();
      Uint8List? bytes = fileMeta.bytes;

      if (bytes == null && fileMeta.path != null && !kIsWeb) {
        final file = File(fileMeta.path!);
        bytes = await file.readAsBytes();
      }

      if (bytes == null) {
        throw Exception('No file data available');
      }

      switch (extension) {
        case 'txt':
        case 'md':
          return utf8.decode(bytes);
        case 'json':
          try {
            final content = utf8.decode(bytes);
            final json = jsonDecode(content);
            return jsonEncode(json);
          } catch (e) {
            return utf8.decode(bytes);
          }
        case 'csv':
          return utf8.decode(bytes);
        case 'pdf':
          return await _readPdfBytes(bytes);
        case 'docx':
          return docxToText(bytes);
        default:
          return utf8.decode(bytes);
      }
    } catch (e) {
      print('File Parsing Error: $e');
      return null;
    }
  }

  static Future<String> _readPdfBytes(Uint8List bytes) async {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final String text = PdfTextExtractor(document).extractText();
      document.dispose();
      return text;
    } catch (e) {
      print('PDF Parsing Error: $e');
      return 'Error reading PDF: $e';
    }
  }

  // Legacy support or if path is still needed for some reason
  static Future<String?> extractTextFromPath(String filePath) async {
    if (kIsWeb) return null;
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final name = filePath.split('/').last;
      return await extractTextFromFile(UploadedFileMeta(name: name, path: filePath, bytes: bytes, createdAt: DateTime.now()));
    } catch (e) {
      return null;
    }
  }

  // Get supported file types
  static const List<String> supportedFormats = [
    'txt',
    'json',
    'csv',
    'md',
    'pdf',
    'docx',
    'pptx',
    'code files (dart, java, python, etc.)',
  ];
}
