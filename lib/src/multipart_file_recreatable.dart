import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

class MultipartFileRecreatable extends MultipartFile {
  MultipartFileRecreatable(
    Stream<List<int>> stream,
    int length,
    String? filename,
    this.filePath, {
    super.contentType,
  }) : super.fromStream(stream.asBroadcastStream, length, filename: filename);

  final String filePath;

  // ignore: prefer_constructors_over_static_methods
  static MultipartFileRecreatable fromFileSync(
    String filePath, {
    String? filename,
    MediaType? contentType,
  }) {
    filename ??= p.basename(filePath);
    final file = File(filePath);
    final length = file.lengthSync();
    final stream = file.openRead();
    return MultipartFileRecreatable(
      stream,
      length,
      filename,
      filePath,
      contentType: contentType,
    );
  }

  MultipartFileRecreatable recreate() => fromFileSync(
        filePath,
        filename: filename,
        contentType: contentType,
      );
}
