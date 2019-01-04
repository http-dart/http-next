// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';

import 'client.dart';
import 'exception.dart';
import 'request.dart';
import 'response.dart';
import 'utils.dart';

/// The abstract base class for an HTTP client.
///
/// Subclasses only need to implement [send] and maybe [close], and then they
/// get various convenience methods for free.
abstract class BaseClient implements Client {
  @override
  FutureOr<Response> head(url, {Map<String, String> headers}) =>
      send(Request.head(url, headers: headers));

  @override
  FutureOr<Response> get(url, {Map<String, String> headers}) =>
      send(Request.get(url, headers: headers));

  @override
  FutureOr<Response> post(
    url,
    body, {
    Map<String, String> headers,
    Encoding encoding,
  }) =>
      send(Request.post(url, body, headers: headers, encoding: encoding));

  @override
  FutureOr<Response> put(
    url,
    body, {
    Map<String, String> headers,
    Encoding encoding,
  }) =>
      send(Request.put(url, body, headers: headers, encoding: encoding));

  @override
  FutureOr<Response> patch(
    url,
    body, {
    Map<String, String> headers,
    Encoding encoding,
  }) =>
      send(Request.patch(url, body, headers: headers, encoding: encoding));

  @override
  FutureOr<Response> delete(url, {Map<String, String> headers}) =>
      send(Request.delete(url, headers: headers));

  @override
  FutureOr<String> read(url, {Map<String, String> headers}) async {
    final response = await get(url, headers: headers);
    _checkResponseSuccess(url, response);

    return response.readAsString();
  }

  @override
  FutureOr<Uint8List> readBytes(url, {Map<String, String> headers}) async {
    final response = await get(url, headers: headers);
    _checkResponseSuccess(url, response);

    return collectBytes(response.read());
  }

  @override
  FutureOr<Response> send(Request request);

  @override
  void close() {}

  /// Throws an error if [response] is not successful.
  void _checkResponseSuccess(url, Response response) {
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
