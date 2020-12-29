// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'mime_types.dart';
import 'unmodifiable_map.dart';

/// Helpers for setting headers around the content of the message.
extension ContentHeaders on Map<String, String> {
  static const String _contentLengthHeader = 'content-length';
  static const String _contentTypeHeader = 'content-type';

  /// Returns an immutable map containing a `content-type` header for JSON
  /// data.
  static Map<String, String> json() => const UnmodifiableMap<String, String>({
        _contentTypeHeader: '$applicationType/$jsonSubtype',
      });

  /// Returns an immutable map containing a `content-type` header for multi-part
  /// form data.
  static Map<String, String> multipart(String boundary) =>
      UnmodifiableMap<String, String>({
        _contentTypeHeader: 'multipart/form-data; boundary=$boundary',
      });

  /// Returns an immutable map containing a `content-type` header for url
  /// encoded form data.
  static Map<String, String> urlEncoded() =>
      const UnmodifiableMap<String, String>({
        _contentTypeHeader: '$applicationType/x-www-form-urlencoded',
      });

  /// The `content-length` header value.
  String get contentLength => this[_contentLengthHeader];
  set contentLength(String value) {
    _setOrRemove(_contentLengthHeader, value);
  }

  /// The `content-type` header value.
  String get contentType => this[_contentTypeHeader];
  set contentType(String value) {
    _setOrRemove(_contentTypeHeader, value);
  }

  void _setOrRemove(String key, String value) {
    if (value == null) {
      remove(key);
    } else {
      this[key] = value;
    }
  }
}
