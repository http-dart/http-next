// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2013, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// A composable, [Future]-based library for making HTTP requests.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'src/client.dart';
import 'src/response.dart';

export 'src/base_client.dart';
export 'src/client.dart';
export 'src/exception.dart';
export 'src/handler.dart';
export 'src/io_client.dart';
export 'src/middleware.dart';
export 'src/multipart_file.dart';
export 'src/pipeline.dart';
export 'src/request.dart';
export 'src/response.dart';

/// Sends an HTTP HEAD request with the given headers to the given URL, which
/// can be a [Uri] or a [String].
///
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
///
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
Future<Response> head(url, {Map<String, String> headers}) =>
    _withClient((client) => client.head(url, headers: headers));

/// Sends an HTTP GET request with the given headers to the given URL, which can
/// be a [Uri] or a [String].
///
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
///
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
Future<Response> get(url, {Map<String, String> headers}) =>
    _withClient((client) => client.get(url, headers: headers));

/// Sends an HTTP POST request with the given headers and body to the given URL,
/// which can be a [Uri] or a [String].
///
/// [body] sets the body of the request. It can be a [String], a [List<int>] or
/// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
/// used as the body of the request. The content-type of the request will
/// default to "text/plain".
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
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
Future<Response> post(url, body,
        {Map<String, String> headers, Encoding encoding}) =>
    _withClient((client) =>
        client.post(url, body, headers: headers, encoding: encoding));

/// Sends an HTTP PUT request with the given headers and body to the given URL,
/// which can be a [Uri] or a [String].
///
/// [body] sets the body of the request. It can be a [String], a [List<int>] or
/// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
/// used as the body of the request. The content-type of the request will
/// default to "text/plain".
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
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
Future<Response> put(url, body,
        {Map<String, String> headers, Encoding encoding}) =>
    _withClient((client) =>
        client.put(url, body, headers: headers, encoding: encoding));

/// Sends an HTTP PATCH request with the given headers and body to the given
/// URL, which can be a [Uri] or a [String].
///
/// [body] sets the body of the request. It can be a [String], a [List<int>] or
/// a [Map<String, String>]. If it's a String, it's encoded using [encoding] and
/// used as the body of the request. The content-type of the request will
/// default to "text/plain".
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
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
Future<Response> patch(url, body,
        {Map<String, String> headers, Encoding encoding}) =>
    _withClient((client) =>
        client.patch(url, body, headers: headers, encoding: encoding));

/// Sends an HTTP DELETE request with the given headers to the given URL, which
/// can be a [Uri] or a [String].
///
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
Future<Response> delete(url, {Map<String, String> headers}) =>
    _withClient((client) => client.delete(url, headers: headers));

/// Sends an HTTP GET request with the given headers to the given URL, which can
/// be a [Uri] or a [String], and returns a Future that completes to the body of
/// the response as a [String].
///
/// The Future will emit a [ClientException] if the response doesn't have a
/// success status code.
///
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
Future<String> read(url, {Map<String, String> headers}) =>
    _withClient((client) => client.read(url, headers: headers));

/// Sends an HTTP GET request with the given headers to the given URL, which can
/// be a [Uri] or a [String], and returns a Future that completes to the body of
/// the response as a list of bytes.
///
/// The Future will emit a [ClientException] if the response doesn't have a
/// success status code.
///
/// This automatically initializes a new [Client] and closes that client once
/// the request is complete. If you're planning on making multiple requests to
/// the same server, you should use a single [Client] for all of those requests.
Future<Uint8List> readBytes(url, {Map<String, String> headers}) =>
    _withClient((client) => client.readBytes(url, headers: headers));

Future<T> _withClient<T>(Future<T> fn(Client client)) async {
  final client = Client();
  try {
    return await fn(client);
  } finally {
    client.close();
  }
}
