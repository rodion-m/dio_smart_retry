import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

/// Creates an instance of [MultipartFile] that can be recreated and reused.
class MultipartFileRecreatable extends MultipartFile {
  /// Default constructor.
  MultipartFileRecreatable(
    super.stream,
    super.length, {
    super.filename,
    super.contentType,
    super.headers,
  }) : data = stream;

  /// Creates a [MultipartFileRecreatable] object with [bytes].
  factory MultipartFileRecreatable.fromBytes(
    List<int> bytes, {
    String? filename,
    MediaType? contentType,
    Map<String, List<String>>? headers,
  }) {
    return MultipartFileRecreatable(
      Stream.fromIterable(<List<int>>[bytes]),
      bytes.length,
      filename: filename,
      contentType: contentType,
      headers: headers,
    );
  }

  /// Creates a [MultipartFileRecreatable] object from a [File] in [filePath].
  factory MultipartFileRecreatable.fromFileSync(
    String filePath, {
    String? filename,
    MediaType? contentType,
    Map<String, List<String>>? headers,
  }) {
    filename ??= p.basename(filePath);
    final file = File(filePath);
    final length = file.lengthSync();
    final stream = file.openRead();
    return MultipartFileRecreatable(
      stream,
      length,
      filename: filename,
      contentType: contentType,
      headers: headers,
    );
  }

  /// The stream that will emit the file's contents.
  final Stream<List<int>> data;

  /// Recreates the [MultipartFileRecreatable] object.
  MultipartFileRecreatable recreate() {
    return MultipartFileRecreatable(
      data,
      length,
      filename: filename,
      contentType: contentType,
      headers: headers,
    );
  }
}
