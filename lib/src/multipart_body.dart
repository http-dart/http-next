// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2017, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:typed_data/typed_buffers.dart';

import 'body.dart';
import 'boundary.dart';
import 'multipart_file.dart';
import 'utils.dart';

/// A `multipart/form-data` request [Body].
///
/// Such a request has both string fields, which function as normal form
/// fields, and (potentially streamed) binary files.
class MultipartBody implements Body {
  /// Creates a [MultipartBody] from the given [fields] and [files].
  ///
  /// The content of the body is specified through the values of [fields] and
  /// [files]. The name for a field can be reused so the [fields] type is
  /// treated as `Map<String, String | List<String>>`.
  ///
  /// The [boundary] is used to separate key value pairs within the body.
  factory MultipartBody(
    Map<String, Object> fields,
    Iterable<MultipartFile> files,
    String boundary,
  ) {
    if (!validBoundaryString(boundary)) {
      throw ArgumentError.value(
          boundary, 'boundary', 'not a valid boundary string');
    }

    final controller = StreamController<List<int>>(sync: true);
    final buffer = Uint8Buffer();

    void writeAscii(String string) {
      buffer.addAll(string.codeUnits);
    }

    void writeUtf8(String string) {
      buffer.addAll(utf8.encode(string));
    }

    void writeLine() {
      buffer
        ..add(13)
        ..add(10); // \r\n
    }

    // Write the fields to the buffer.
    fields.forEach((name, value) {
      void writeField(String value) {
        writeAscii('--$boundary\r\n');
        writeUtf8(_headerForField(name, value));
        writeUtf8(value);
        writeLine();
      }

      if (value is List<String>) {
        value.forEach(writeField);
      } else if (value is String) {
        writeField(value);
      } else if (value == null) {
        throw ArgumentError.notNull('field[$name]');
      } else {
        throw ArgumentError.value(
            value, 'field[$name]', 'must be a String or List<String>');
      }
    });

    controller.add(buffer);

    // Iterate over the files to get the length and compute the headers ahead of
    // time so the length can be synchronously accessed.
    final fileList = files.toList();
    final fileHeaders = <List<int>>[];
    var fileContentsLength = 0;

    for (final file in fileList) {
      final header = <int>[
        ...'--$boundary\r\n'.codeUnits,
        ...utf8.encode(_headerForFile(file)),
      ];

      fileContentsLength += header.length + file.length + 2;
      fileHeaders.add(header);
    }

    // Ending characters.
    final ending = '--$boundary--\r\n'.codeUnits;
    fileContentsLength += ending.length;

    // Write the files to the stream asynchronously.
    _writeFilesToStream(controller, fileList, fileHeaders, ending);

    return MultipartBody._(
        controller.stream, buffer.length + fileContentsLength);
  }

  MultipartBody._(this._stream, this.contentLength);

  /// The contents of the message body.
  ///
  /// This will be `null` after [read] is called.
  Stream<List<int>> _stream;

  @override
  final int contentLength;

  /// Multipart forms do not have an encoding.
  @override
  Encoding get encoding => null;

  @override
  Stream<List<int>> read() {
    if (_stream == null) {
      throw StateError("The 'read' method can only be called once on a "
          'http.Request/http.Response object.');
    }
    final stream = _stream;
    _stream = null;
    return stream;
  }

  /// Writes the [files] to the [controller].
  static Future<void> _writeFilesToStream(
    StreamController<List<int>> controller,
    List<MultipartFile> files,
    List<List<int>> fileHeaders,
    List<int> ending,
  ) async {
    for (var i = 0; i < files.length; ++i) {
      controller.add(fileHeaders[i]);

      // file.read() can throw synchronously
      try {
        final stream = files[i].read();
        final completer = Completer<void>();

        stream.listen(
          controller.add,
          onError: controller.addError,
          onDone: completer.complete,
        );

        await completer.future;
      } on Exception catch (exception, stackTrace) {
        controller.addError(exception, stackTrace);
      }

      controller.add([13, 10]);
    }

    controller.add(ending);

    return controller.close();
  }

  /// Returns the header string for a field.
  static String _headerForField(String name, String value) {
    var header =
        'content-disposition: form-data; name="${_browserEncode(name)}"';
    if (!isPlainAscii(value)) {
      header = '$header\r\n'
          'content-type: text/plain; charset=utf-8\r\n'
          'content-transfer-encoding: binary';
    }
    return '$header\r\n\r\n';
  }

  /// Returns the header string for a file.
  ///
  /// The return value is guaranteed to contain only ASCII characters.
  static String _headerForFile(MultipartFile file) {
    var header = 'content-type: ${file.contentType}\r\n'
        'content-disposition: form-data; name="${_browserEncode(file.field)}"';

    final filename = file.filename;
    if (filename.isNotEmpty) {
      header = '$header; filename="${_browserEncode(filename)}"';
    }

    return '$header\r\n\r\n';
  }

  static final _newlineRegExp = RegExp(r'\r\n|\r|\n');

  /// Encode [value] in the same way browsers do.
  static String _browserEncode(String value) =>
      // http://tools.ietf.org/html/rfc2388 mandates some complex encodings for
      // field names and file names, but in practice user agents seem not to
      // follow this at all. Instead, they URL-encode `\r`, `\n`, and `\r\n` as
      // `\r\n`; URL-encode `"`; and do nothing else (even for `%` or non-ASCII
      // characters). We follow their behavior.
      value.replaceAll(_newlineRegExp, '%0D%0A').replaceAll('"', '%22');
}
