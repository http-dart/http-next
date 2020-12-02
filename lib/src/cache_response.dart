// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:http_parser/http_parser.dart';

import 'response.dart';

/// HTTP Cache information for a [Response].
///
/// A server provides caching information on requested resources through a
/// [Response]'s headers. A [CacheResponse] provides convenience methods to
/// access cache information through the headers.
extension CacheResponse on Response {
  /// The date and time after which the response's data should be considered
  /// stale.
  ///
  /// This is parsed from the Expires header in [headers]. If [headers] doesn't
  /// have an Expires header, this will be `null`.
  ///
  /// This value is not cached internally so subsequent calls will reparse the
  /// HTTP date header.
  DateTime get expires => _parseHeaderHttpDate('expires');

  /// The date and time the source of the response's data was last modified.
  ///
  /// This is parsed from the Last-Modified header in [headers]. If [headers]
  /// doesn't have a Last-Modified header, this will be `null`.
  ///
  /// This value is not cached internally so subsequent calls will reparse the
  /// HTTP date header.
  DateTime get lastModified => _parseHeaderHttpDate('last-modified');

  DateTime _parseHeaderHttpDate(String key) {
    final value = headers[key];

    return value != null ? parseHttpDate(value) : null;
  }
}
