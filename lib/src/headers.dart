// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:collection/collection.dart';
import 'package:http_parser/http_parser.dart';

import 'body.dart';
import 'content_headers.dart';
import 'http_unmodifiable_map.dart';
import 'media_type_encoding.dart';
import 'mime_types.dart';

/// Helpers for manipulating [Message.headers] values.
extension Headers on Map<String, String> {
  /// Creates a [HttpUnmodifiableMap] from the [source] while preventing
  /// re-wrapping itself.
  ///
  /// If [source] is already a [HttpUnmodifiableMap] then it is returned
  /// unchanged.
  ///
  /// If [source] is `null` it is treated as an empty map.
  ///
  /// When creating a [HttpUnmodifiableMap] the [source] is copies to a new
  /// [Map] to ensure changes to the parameter value after constructions are
  /// not reflected.
  static Map<String, String> create(Map<String, String> source) {
    if (source is HttpUnmodifiableMap<String>) {
      return source;
    }

    return source == null || source.isEmpty
        ? const HttpUnmodifiableMap<String>.empty()
        : HttpUnmodifiableMap<String>(
            Map<String, String>.from(source),
            ignoreKeyCase: true,
          );
  }

  /// Returns a [HttpUnmodifiableMap] with the values from [original] and the
  /// values from [updates].
  ///
  /// For keys that are the same between [original] and [updates], the value in
  /// [updates] is used.
  static Map<String, String> update(
    Map<String, String> original,
    Map<String, String> updates,
  ) {
    if (updates == null || updates.isEmpty) {
      return create(original);
    }

    return HttpUnmodifiableMap<String>(
      Map<String, String>.from(original)..addAll(updates),
      ignoreKeyCase: true,
    );
  }

  /// Adjusts the [headers] information about content based on the [body].
  ///
  /// Returns a new map without modifying [headers].
  static Map<String, String> adjust(Map<String, String> headers, Body body) {
    assert(headers is HttpUnmodifiableMap, 'headers are unmodifiable');

    final contentLengthHeader = _contentLengthHeader(headers, body);
    final contentTypeHeader = _contentTypeHeader(headers, body);

    final contentLengthSame = contentLengthHeader == headers.contentLength;
    final contentTypeSame = contentTypeHeader == headers.contentType;

    if (contentLengthSame && contentTypeSame) {
      return headers;
    }

    // The keys for headers are case-insensitive already so just use a map
    final updatedHeaders = Map<String, String>.from(headers);
    if (!contentLengthSame) {
      updatedHeaders.contentLength = contentLengthHeader;
    }
    if (!contentTypeSame) {
      updatedHeaders.contentType = contentTypeHeader;
    }

    return create(updatedHeaders);
  }

  static String _contentLengthHeader(Map<String, String> headers, Body body) {
    final contentLengthHeader = headers.contentLength;
    final bodyLength = body.contentLength;
    if (bodyLength == null || bodyLength == 0) {
      return contentLengthHeader;
    }

    final bodyLengthString = bodyLength.toString();
    if (bodyLengthString == contentLengthHeader) {
      return contentLengthHeader;
    }

    final coding = headers['transfer-encoding'];
    return coding == null || equalsIgnoreAsciiCase(coding, 'identity')
        ? bodyLengthString
        : contentLengthHeader;
  }

  static String _contentTypeHeader(Map<String, String> headers, Body body) {
    final contentTypeHeader = headers.contentType;
    final mediaType = contentTypeHeader != null
        ? MediaType.parse(contentTypeHeader)
        : octetStreamMediaType();

    final mediaEncoding = mediaType.encoding;
    final useEncoding = body.encoding ?? mediaEncoding;

    return useEncoding == mediaEncoding
        ? contentTypeHeader
        : mediaType.changeEncoding(useEncoding).toString();
  }
}
