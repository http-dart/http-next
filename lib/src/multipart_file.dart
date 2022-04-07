// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'media_type_encoding.dart';
import 'mime_types.dart';

/// A file to be uploaded as part of a `multipart/form-data` Request.
///
/// This doesn't need to correspond to a physical file.
class MultipartFile {
  /// Creates a [MultipartFile] from the [value].
  ///
  /// [value] can be either a [String] or a [List<int>].
  ///
  /// For a String [value] the content will be encoded using [encoding] which
  /// defaults to [utf8]. The `charset` from [contentType] is ignored when
  /// encoding the String.
  ///
  /// [contentType] if not specified will attempt to be looked up from the
  /// bytes contained within the [stream] and the [filename] if provided. It
  /// will default to `plain/text` for [String]s and `application/octet-stream`
  /// for [List<int>].
  factory MultipartFile(
    String field,
    Object value, {
    String? filename,
    MediaType? contentType,
    Encoding? encoding,
  }) {
    List<int> bytes;
    MediaType defaultMediaType;

    if (value is String) {
      encoding ??= utf8;
      bytes = encoding.encode(value);
      defaultMediaType = plainTextMediaType();
    } else if (value is List<int>) {
      bytes = value;
      defaultMediaType = octetStreamMediaType();
    } else {
      throw ArgumentError.value(
        value,
        'value',
        'value must be either a String or a List<int>',
      );
    }

    filename ??= '';
    contentType ??= _lookUpMediaType(filename, bytes) ?? defaultMediaType;

    if (encoding != null) {
      contentType = contentType.changeEncoding(encoding);
    }

    return MultipartFile.fromStream(
      field,
      Stream.fromIterable([bytes]),
      bytes.length,
      filename: filename,
      contentType: contentType,
    );
  }

  /// Creates a new [MultipartFile] from a chunked [stream] of bytes.
  ///
  /// The [length] of the file in bytes must be known in advance. If it's not
  /// then use [loadStream] to create the [MultipartFile] instance.
  ///
  /// [contentType] if not specified will attempt to be looked up from the
  /// [filename] if provided. It will default to `application/octet-stream`.
  MultipartFile.fromStream(
    this.field,
    Stream<List<int>> stream,
    this.length, {
    String? filename,
    MediaType? contentType,
  })  : _stream = stream,
        filename = filename ?? '',
        contentType = contentType ??
            _lookUpMediaType(filename ?? '') ??
            octetStreamMediaType();

  /// The stream that will emit the file's contents.
  Stream<List<int>>? _stream;

  /// The name of the form field for the file.
  final String field;

  /// The size of the file in bytes.
  ///
  /// This must be known in advance, even if this file is created from a
  /// [Stream].
  final int length;

  /// The basename of the file.
  ///
  /// If unspecified the value will be the empty string.
  final String? filename;

  /// The content-type of the file.
  ///
  /// Defaults to `application/octet-stream`.
  final MediaType? contentType;

  /// Creates a new [MultipartFile] from the [stream].
  ///
  /// This method should be used when the length of [stream] in bytes is not
  /// known ahead of time.
  ///
  /// [contentType] if not specified will attempt to be looked up from the
  /// bytes contained within the [stream] and the [filename] if provided. It
  /// will default to `application/octet-stream`.
  static Future<MultipartFile> loadStream(
    String field,
    Stream<List<int>> stream, {
    String? filename,
    MediaType? contentType,
  }) async {
    final bytes = await collectBytes(stream);

    return MultipartFile(
      field,
      bytes,
      filename: filename,
      contentType: contentType,
    );
  }

  /// Returns a [Stream] representing the contents of the file.
  ///
  /// Can only be called once.
  Stream<List<int>> read() {
    if (_stream == null) {
      throw StateError(
        'The "read" method can only be called once on a '
        'http.MultipartFile object.',
      );
    }
    final stream = _stream;
    _stream = null;
    return stream!;
  }

  /// Looks up the [MediaType] from the [filename]'s extension or from
  /// magic numbers contained within a file header's [bytes].
  static MediaType? _lookUpMediaType(String filename, [List<int>? bytes]) {
    if (filename.isEmpty && bytes == null) {
      return null;
    }

    final mimeType = lookupMimeType(filename, headerBytes: bytes);

    return mimeType != null ? MediaType.parse(mimeType) : null;
  }
}
