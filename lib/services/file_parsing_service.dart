import 'dart:io';
import 'dart:convert';

class FileParsingService {
  // Extract text from various file types
  static Future<String?> extractTextFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      switch (extension) {
        case 'txt':
          return await _readTxtFile(filePath);
        case 'json':
          return await _readJsonFile(filePath);
        case 'csv':
          return await _readCsvFile(filePath);
        case 'pdf':
          return await _readPdfFile(filePath);
        case 'docx':
          return await _readDocxFile(filePath);
        case 'md':
          return await _readMarkdownFile(filePath);
        default:
          // Try to read as plain text
          return await _readTxtFile(filePath);
      }
    } catch (e) {
      print('File Parsing Error: $e');
      return null;
    }
  }

  static Future<String> _readTxtFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
  }

  static Future<String> _readJsonFile(String filePath) async {
    final file = File(filePath);
    final content = await file.readAsString();
    try {
      final json = jsonDecode(content);
      return jsonEncode(json); // Pretty print or process as needed
    } catch (e) {
      return content; // Return as-is if not valid JSON
    }
  }

  static Future<String> _readCsvFile(String filePath) async {
    final file = File(filePath);
    final lines = await file.readAsLines();
    return lines.join('\n');
  }

  static Future<String> _readPdfFile(String filePath) async {
    // Note: For production, use pdf package
    // For now, return a placeholder message
    return 'PDF file detected at: $filePath\nNote: PDF parsing requires pdf package integration.';
  }

  static Future<String> _readDocxFile(String filePath) async {
    // Note: For production, use docx package
    return 'DOCX file detected at: $filePath\nNote: DOCX parsing requires docx package integration.';
  }

  static Future<String> _readMarkdownFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsString();
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
