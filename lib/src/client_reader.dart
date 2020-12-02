// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:typed_data';

import 'package:async/async.dart';

import 'client.dart';
import 'client_methods.dart';
import 'exception.dart';
import 'response.dart';
import 'utils.dart';

/// Convenience methods for HTTP GET requests that return the body of the
/// [Response].
extension ClientReader on Client {
  /// Sends an HTTP GET request with the given [headers] to the given [url],
  /// which can be a [Uri] or a [String], and returns a Future that completes
  /// to the body of the response as a [String].
  ///
  /// The Future will emit a [ClientException] if the response doesn't have a
  /// success status code.
  ///
  /// For more fine-grained control over the request and response, use [send] or
  /// [get] instead.
  FutureOr<String> read(Object url, {Map<String, String> headers}) async {
    final response = await get(url, headers: headers);
    _checkResponseSuccess(url, response);

    return response.readAsString();
  }

  /// Sends an HTTP GET request with the given [headers] to the given [url],
  /// which can be a [Uri] or a [String], and returns a Future that completes
  /// to the body of the response as a list of bytes.
  ///
  /// The Future will emit a [ClientException] if the response doesn't have a
  /// success status code.
  ///
  /// For more fine-grained control over the request and response, use [send] or
  /// [get] instead.
  FutureOr<Uint8List> readBytes(
    Object url, {
    Map<String, String> headers,
  }) async {
    final response = await get(url, headers: headers);
    _checkResponseSuccess(url, response);

    return collectBytes(response.read());
  }

  /// Throws an error if [response] is not successful.
  static void _checkResponseSuccess(Object url, Response response) {
    if (response.statusCode < 400) {
      return;
    }

    var message = 'Request to $url failed with status ${response.statusCode}';
    if (response.reasonPhrase.isNotEmpty) {
      message = '$message: ${response.reasonPhrase}';
    }
    throw ClientException('$message.', getUrl(url));
  }
}
