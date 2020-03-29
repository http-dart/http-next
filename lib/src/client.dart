// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'base_client.dart';
import 'handler.dart';
import 'handler_client.dart';
import 'platform_client.dart'
    if (dart.library.html) 'browser_client.dart'
    if (dart.library.io) 'io_client.dart';
import 'request.dart';
import 'response.dart';

/// The interface for HTTP clients that take care of maintaining persistent
/// connections across multiple requests to the same server. If you only need to
/// send a single request, it's usually easier to use [head], [get], [post],
/// [put], [patch], or [delete] instead.
///
/// When creating an HTTP client class with additional functionality, you must
/// extend [BaseClient] rather than [Client]. In most cases, you can wrap
/// another instance of [Client] and add functionality on top of that. This
/// allows all classes implementing [Client] to be mutually composable.
abstract class Client {
  /// Creates a new client.
  ///
  /// This will create a [BrowserClient] if `dart:html` is available, otherwise
  /// it will create an [IOClient].
  factory Client() => platformClient();

  /// Creates a new [Client] from a [handler] callback.
  ///
  /// The [handler] is a function that receives a [Request] and returns a
  /// [FutureOr<Response>]. It will be called when [Client.send] is invoked.
  ///
  /// When [Client.close] is called the [onClose] function will be called.
  factory Client.handler(Handler handler, {void Function() onClose}) =>
      HandlerClient(handler, onClose ?? () {});

  /// Sends an HTTP HEAD request with the given headers to the given URL, which
  /// can be a [Uri] or a [String].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> head(url, {Map<String, String> headers});

  /// Sends an HTTP GET request with the given headers to the given URL, which
  /// can be a [Uri] or a [String].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> get(url, {Map<String, String> headers});

  /// Sends an HTTP POST request with the given headers and body to the given
  /// URL, which can be a [Uri] or a [String].
  ///
  /// [body] sets the body of the request. It can be a [String], a [List<int>]
  /// or a [Map<String, String>]. If it's a String, it's encoded using
  /// [encoding] and used as the body of the request. The content-type of the
  /// request will default to "text/plain".
  ///
  /// If [body] is a List, it's used as a list of bytes for the body of the
  /// request.
  ///
  /// If [body] is a Map, it's encoded as form fields using [encoding]. The
  /// content-type of the request will be set to
  /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
  ///
  /// [encoding] defaults to [utf8].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> post(
    url,
    body, {
    Map<String, String> headers,
    Encoding encoding,
  });

  /// Sends an HTTP PUT request with the given headers and body to the given
  /// URL, which can be a [Uri] or a [String].
  ///
  /// [body] sets the body of the request. It can be a [String], a [List<int>]
  /// or a [Map<String, String>]. If it's a String, it's encoded using
  /// [encoding] and used as the body of the request. The content-type of the
  /// request will default to "text/plain".
  ///
  /// If [body] is a List, it's used as a list of bytes for the body of the
  /// request.
  ///
  /// If [body] is a Map, it's encoded as form fields using [encoding]. The
  /// content-type of the request will be set to
  /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
  ///
  /// [encoding] defaults to [utf8].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> put(
    url,
    body, {
    Map<String, String> headers,
    Encoding encoding,
  });

  /// Sends an HTTP PATCH request with the given headers and body to the given
  /// URL, which can be a [Uri] or a [String].
  ///
  /// [body] sets the body of the request. It can be a [String], a [List<int>]
  /// or a [Map<String, String>]. If it's a String, it's encoded using
  /// [encoding] and used as the body of the request. The content-type of the
  /// request will default to "text/plain".
  ///
  /// If [body] is a List, it's used as a list of bytes for the body of the
  /// request.
  ///
  /// If [body] is a Map, it's encoded as form fields using [encoding]. The
  /// content-type of the request will be set to
  /// `"application/x-www-form-urlencoded"`; this cannot be overridden.
  ///
  /// [encoding] defaults to [utf8].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> patch(
    url,
    body, {
    Map<String, String> headers,
    Encoding encoding,
  });

  /// Sends an HTTP DELETE request with the given headers to the given URL,
  /// which can be a [Uri] or a [String].
  ///
  /// For more fine-grained control over the request, use [send] instead.
  FutureOr<Response> delete(url, {Map<String, String> headers});

  /// Sends an HTTP GET request with the given headers to the given URL, which
  /// can be a [Uri] or a [String], and returns a Future that completes to the
  /// body of the response as a String.
  ///
  /// The Future will emit a [ClientException] if the response doesn't have a
  /// success status code.
  ///
  /// For more fine-grained control over the request and response, use [send] or
  /// [get] instead.
  FutureOr<String> read(url, {Map<String, String> headers});

  /// Sends an HTTP GET request with the given headers to the given URL, which
  /// can be a [Uri] or a [String], and returns a Future that completes to the
  /// body of the response as a list of bytes.
  ///
  /// The Future will emit a [ClientException] if the response doesn't have a
  /// success status code.
  ///
  /// For more fine-grained control over the request and response, use [send] or
  /// [get] instead.
  FutureOr<Uint8List> readBytes(url, {Map<String, String> headers});

  /// Sends an HTTP request and asynchronously returns the response.
  FutureOr<Response> send(Request request);

  /// Closes the client and cleans up any resources associated with it.
  ///
  /// It's important to close each client when it's done being used; failing to
  /// do so can cause the Dart process to hang.
  void close();
}
