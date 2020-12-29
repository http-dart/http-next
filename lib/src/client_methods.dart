// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'client.dart';
import 'request.dart';
import 'response.dart';

/// Convenience methods around [Client.send] that correspond to common HTTP
/// methods.
///
/// For each method a corresponding [Request] using the requested HTTP method is
/// created. The method will only have parameters for a body and its encoding
/// when the HTTP method expects one. If more fine grained control is required,
/// as an example if an API expects a body for a `DELETE` call, then a [Request]
/// should be created manually and passed to [Client.send].
extension ClientMethods on Client {
  /// Sends an HTTP HEAD request with the given [headers] to the given [url].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> head(Uri url, {Map<String, String> headers}) =>
      send(Request.head(url, headers: headers));

  /// Sends an HTTP GET request with the given [headers] to the given [url].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> get(Uri url, {Map<String, String> headers}) =>
      send(Request.get(url, headers: headers));

  /// Sends an HTTP POST request with the given [headers] and [body] to the
  /// given [url].
  ///
  /// [body] sets the body of the request. It can be a [String], or a
  /// [List<int>]. If it's a String, it's encoded using [encoding] and used as
  /// the body of the request. The content-type of the request will default to
  /// `text/plain`.
  ///
  /// If [body] is a List, it's used as a list of bytes for the body of the
  /// request.
  ///
  /// [encoding] defaults to [utf8].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> post(
    Uri url,
    Object body, {
    Map<String, String> headers,
    Encoding encoding,
  }) =>
      send(Request.post(url, body, headers: headers, encoding: encoding));

  /// Sends an HTTP PUT request with the given [headers] and [body] to the given
  /// [url].
  ///
  /// [body] sets the body of the request. It can be a [String], or a
  /// [List<int>]. If it's a String, it's encoded using [encoding] and used as
  /// the body of the request. The content-type of the request will default to
  /// `text/plain`.
  ///
  /// If [body] is a List, it's used as a list of bytes for the body of the
  /// request.
  ///
  /// [encoding] defaults to [utf8].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> put(
    Uri url,
    Object body, {
    Map<String, String> headers,
    Encoding encoding,
  }) =>
      send(Request.put(url, body, headers: headers, encoding: encoding));

  /// Sends an HTTP PATCH request with the given [headers] and [body] to the
  /// given [url].
  ///
  /// [body] sets the body of the request. It can be a [String], or a
  /// [List<int>]. If it's a String, it's encoded using [encoding] and used as
  /// the body of the request. The content-type of the request will default to
  /// `text/plain`.
  ///
  /// If [body] is a List, it's used as a list of bytes for the body of the
  /// request.
  ///
  /// [encoding] defaults to [utf8].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> patch(
    Uri url,
    Object body, {
    Map<String, String> headers,
    Encoding encoding,
  }) =>
      send(Request.patch(url, body, headers: headers, encoding: encoding));

  /// Sends an HTTP DELETE request with the given [headers] to the given [url].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> delete(Uri url, {Map<String, String> headers}) =>
      send(Request.delete(url, headers: headers));
}
