// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:convert';

import 'message.dart';
import 'mime_types.dart';
import 'text_message.dart';

/// A [Message] whose body contains JSON data.
extension JsonMessage on Message {
  /// Whether the [mimeType] of the [Message] signifies a JSON.
  bool get isJson => isMimeType(applicationType, jsonSubtype);

  /// Reads the [Message] as JSON data.
  Future<T> readJson<T>() async {
    final str = await readAsString(utf8);
    // ignore: avoid_as
    return jsonDecode(str) as T;
  }
}
