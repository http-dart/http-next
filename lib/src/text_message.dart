// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:convert';

import 'message.dart';
import 'mime_types.dart';

/// A [Message] whose body contains text data.
extension TextMessage on Message {
  /// Whether the [mimeType] of the [Message] signifies text.
  bool get isText => isMimeType(textType);

  /// Whether the [mimeType] of the [Message] signifies plain text.
  bool get isPlainText => isMimeType(textType, plainTextSubtype);

  /// Returns the message body as a string.
  ///
  /// If [encoding] is passed, that's used to decode the body. Otherwise the
  /// encoding is taken from the Content-Type header. If that doesn't exist or
  /// doesn't have a "charset" parameter, UTF-8 is used.
  ///
  /// Throws a [StateError] if [read] or [readAsBytes] or [readAsString] has
  /// already been called.
  Future<String> readAsString([Encoding encoding]) {
    encoding ??= this.encoding ?? utf8;
    return encoding.decodeStream(read());
  }
}
