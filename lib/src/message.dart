// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2017, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';

import 'body.dart';
import 'content_headers.dart';
import 'context.dart';
import 'headers.dart';
import 'media_type_encoding.dart';
import 'media_type_query.dart';

/// Represents logic shared between [Request] and [Response].
abstract class Message {
  /// Creates a new [Message].
  ///
  /// [body] is the message body. It may be either a [String], a [List<int>], a
  /// [Stream<List<int>>], or `null` to indicate no body. If it's a [String],
  /// [encoding] is used to encode it to a [Stream<List<int>>]. It defaults to
  /// UTF-8.
  ///
  /// If [headers] is `null`, it's treated as empty.
  ///
  /// If [encoding] is passed, the "encoding" field of the Content-Type header
  /// in [headers] will be set appropriately. If there is no existing
  /// Content-Type header, it will be set to "application/octet-stream".
  Message(
    Object? body, {
    Encoding? encoding,
    Map<String, String>? headers,
    Map<String, Object>? context,
  }) : this._(Body(body, encoding), Headers.create(headers), context);

  Message._(
    Body body,
    Map<String, String> headers,
    Map<String, Object>? context,
  )   : _body = body,
        headers = Headers.adjust(headers, body),
        context = Context.create(context);

  /// The HTTP headers.
  ///
  /// This is immutable. A copy of this with new headers can be created using
  /// [change].
  final Map<String, String> headers;

  /// Extra context that can be used by middleware and handlers.
  ///
  /// For requests, this is used to pass data to inner middleware and handlers;
  /// for responses, it's used to pass data to outer middleware and handlers.
  ///
  /// Context properties that are used by a particular package should begin with
  /// that package's name followed by a period. For example, if there was a
  /// package `foo` which contained a middleware `bar` and it wanted to take
  /// a context property, its property would be `"foo.bar"`.
  ///
  /// This is immutable. A copy of this with new context values can be created
  /// using [change].
  final Map<String, Object> context;

  /// The streaming body of the message.
  ///
  /// This can be read via [read] or [readAsString].
  final Body _body;

  /// If `true`, the stream returned by [read] won't emit any bytes.
  ///
  /// This may have false negatives, but it won't have false positives.
  bool get isEmpty => _body.contentLength == 0;

  /// The contents of the content-length field in [headers].
  ///
  /// If not set, `null`.
  int? get contentLength {
    if (_contentLengthCache != null) {
      return _contentLengthCache;
    }

    final contentLengthHeader = headers.contentLength;
    if (contentLengthHeader == null) {
      // ignore: avoid_returning_null
      return null;
    }

    return _contentLengthCache = int.parse(contentLengthHeader);
  }

  int? _contentLengthCache;

  /// The MIME type declared in [headers].
  ///
  /// This is parsed from the Content-Type header in [headers]. It contains only
  /// the MIME type, without any Content-Type parameters.
  ///
  /// If [headers] doesn't have a Content-Type header, this will be `null`.
  String? get mimeType => _contentType?.mimeType;

  /// The encoding of the body returned by [read].
  ///
  /// This is parsed from the "charset" parameter of the Content-Type header in
  /// [headers].
  ///
  /// If [headers] doesn't have a Content-Type header or it specifies an
  /// encoding that [dart:convert] doesn't support, this will be `null`.
  Encoding? get encoding => _contentType?.encoding;

  /// The parsed version of the Content-Type header in [headers].
  ///
  /// This is cached for efficient access.
  MediaType? get _contentType {
    if (_contentTypeCache != null) {
      return _contentTypeCache;
    }

    final contentTypeHeader = headers.contentType;
    if (contentTypeHeader == null) {
      return null;
    }

    return _contentTypeCache = MediaType.parse(contentTypeHeader);
  }

  MediaType? _contentTypeCache;

  /// Determines if the MIME type declared in [headers] is of the same [type]
  /// and optional [subtype].
  bool isMimeType(String type, [String? subtype]) {
    final mimeType = _contentType;
    if (mimeType == null) {
      return false;
    }

    return mimeType.isMimeType(type, subtype);
  }

  /// Returns the message body as byte chunks.
  ///
  /// Throws a [StateError] if [read] or [readAsBytes] or [readAsString] has
  /// already been called.
  Stream<List<int>> read() => _body.read();

  /// Returns the message body as a list of bytes.
  ///
  /// Throws a [StateError] if [read] or [readAsBytes] or [readAsString] has
  /// already been called.
  Future<List<int>> readAsBytes() => collectBytes(read());

  /// Creates a copy of this by copying existing values and applying specified
  /// changes.
  Message change({
    Map<String, String> headers,
    Map<String, Object> context,
    Object body,
  });

  /// Retrieves the [Body] contained in the [message].
  ///
  /// This is meant for internal use by `http` so the message body is accessible
  /// for subclasses of [Message] but hidden elsewhere.
  @protected
  Body getBody() => _body;
}
