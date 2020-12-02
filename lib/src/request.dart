// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2013, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:convert';

import 'boundary.dart';
import 'message.dart';
import 'multipart_body.dart';
import 'multipart_file.dart';
import 'utils.dart';

/// Represents an HTTP request to be sent to a server.
class Request extends Message {
  /// Creates a new [Request] for [url], which can be a [Uri] or a [String],
  /// using [method].
  ///
  /// [body] is the request body. It may be either a [String], a [List<int>], a
  /// [Stream<List<int>>], or `null` to indicate no body. If it's a [String],
  /// [encoding] is used to encode it to a [Stream<List<int>>]. It defaults to
  /// UTF-8.
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  Request(
    String method,
    Object url, {
    Object body,
    Encoding encoding,
    Map<String, String> headers,
    Map<String, Object> context,
  }) : this._(method, getUrl(url), body, encoding, headers, context);

  /// Creates a new HEAD [Request] to [url], which can be a [Uri] or a [String].
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  Request.head(
    Object url, {
    Map<String, String> headers,
    Map<String, Object> context,
  }) : this('HEAD', url, headers: headers, context: context);

  /// Creates a new GET [Request] to [url], which can be a [Uri] or a [String].
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  Request.get(
    Object url, {
    Map<String, String> headers,
    Map<String, Object> context,
  }) : this('GET', url, headers: headers, context: context);

  /// Creates a new POST [Request] to [url], which can be a [Uri] or a [String].
  ///
  /// [body] is the request body. It may be either a [String], a [List<int>], a
  /// [Stream<List<int>>], or `null` to indicate no body. If it's a [String],
  /// [encoding] is used to encode it to a [Stream<List<int>>]. It defaults to
  /// UTF-8.
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  Request.post(
    Object url,
    Object body, {
    Encoding encoding,
    Map<String, String> headers,
    Map<String, Object> context,
  }) : this('POST', url,
            body: body, encoding: encoding, headers: headers, context: context);

  /// Creates a new PUT [Request] to [url], which can be a [Uri] or a [String].
  ///
  /// [body] is the request body. It may be either a [String], a [List<int>], a
  /// [Stream<List<int>>], or `null` to indicate no body. If it's a [String],
  /// [encoding] is used to encode it to a [Stream<List<int>>]. It defaults to
  /// UTF-8.
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  Request.put(
    Object url,
    Object body, {
    Encoding encoding,
    Map<String, String> headers,
    Map<String, Object> context,
  }) : this('PUT', url,
            body: body, encoding: encoding, headers: headers, context: context);

  /// Creates a new PATCH [Request] to [url], which can be a [Uri] or a
  /// [String].
  ///
  /// [body] is the request body. It may be either a [String], a [List<int>], a
  /// [Stream<List<int>>], or `null` to indicate no body. If it's a [String],
  /// [encoding] is used to encode it to a [Stream<List<int>>]. It defaults to
  /// UTF-8.
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  Request.patch(
    Object url,
    Object body, {
    Encoding encoding,
    Map<String, String> headers,
    Map<String, Object> context,
  }) : this('PATCH', url,
            body: body, encoding: encoding, headers: headers, context: context);

  /// Creates a new DELETE [Request] to [url], which can be a [Uri] or a
  /// [String].
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  Request.delete(
    Object url, {
    Map<String, String> headers,
    Map<String, Object> context,
  }) : this('DELETE', url, headers: headers, context: context);

  /// Creates a new [`application/json`](https://www.ietf.org/rfc/rfc4627.txt)
  /// [Request] to the [url], which can be a [Uri] or a [String].
  ///
  /// The [body] is converted using a [JsonEncoder] into a [String]. [encoding]
  /// is used to encode the values in the body. It defaults to UTF-8.
  ///
  /// If [method] is not specified it defaults to `POST`.
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  factory Request.json(
    Object url,
    Object body, {
    String method,
    Encoding encoding,
    Map<String, String> headers,
    Map<String, Object> context,
  }) =>
      Request._(
        method ?? 'POST',
        getUrl(url),
        jsonEncode(body),
        encoding ?? utf8,
        updateMap(
          const <String, String>{'content-type': 'application/json'},
          headers,
        ),
        context,
      );

  /// Creates a new
  /// [`multipart/form-data`](https://en.wikipedia.org/wiki/MIME#Multipart_messages)
  /// [Request] to [url], which can be a [Uri] or a [String].
  ///
  /// The content of the body is specified through the values of [fields] and
  /// [files]. The name for a field can be reused so the [fields] type is
  /// treated as `Map<String, String | List<String>>`.
  ///
  /// The [boundary] is used to separate key value pairs within the body. If
  /// [boundary] is `null` a random boundary string will be generated.
  ///
  /// If [method] is not specified it defaults to POST.
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  factory Request.multipart(
    Object url, {
    String method,
    Map<String, String> headers,
    Map<String, Object> context,
    Map<String, Object> fields,
    Iterable<MultipartFile> files,
    String boundary,
  }) {
    fields ??= const <String, Object>{};
    files ??= const <MultipartFile>[];
    boundary ??= boundaryString();

    return Request._(
      method ?? 'POST',
      getUrl(url),
      MultipartBody(fields, files, boundary),
      null,
      updateMap(
        <String, String>{
          'content-type': 'multipart/form-data; boundary=$boundary'
        },
        headers,
      ),
      context,
    );
  }

  /// Creates a new
  /// [`multipart/form-data`](https://en.wikipedia.org/wiki/MIME#Multipart_messages)
  /// [Request] to [url], which can be a [Uri] or a [String].
  ///
  /// The [body] is a map of strings with the values. [encoding] is used to
  /// encode the values in the body. It defaults to UTF-8.
  ///
  /// If [method] is not specified it defaults to POST.
  ///
  /// [headers] are the HTTP headers for the request. If [headers] is `null`,
  /// it is treated as empty.
  ///
  /// Extra [context] can be used to pass information between inner middleware
  /// and handlers.
  factory Request.urlEncoded(
    Object url,
    Map<String, String> body, {
    String method,
    Encoding encoding,
    Map<String, String> headers,
    Map<String, Object> context,
  }) {
    encoding ??= utf8;

    final pairs = <List<String>>[];
    body.forEach((key, value) => pairs.add([
          Uri.encodeQueryComponent(key, encoding: encoding),
          Uri.encodeQueryComponent(value, encoding: encoding)
        ]));

    return Request._(
      method ?? 'POST',
      getUrl(url),
      pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&'),
      null,
      updateMap(
        const <String, String>{
          'content-type': 'application/x-www-form-urlencoded'
        },
        headers,
      ),
      context,
    );
  }

  Request._(
    this.method,
    this.url,
    Object body,
    Encoding encoding,
    Map<String, String> headers,
    Map<String, Object> context,
  ) : super(body, encoding: encoding, headers: headers, context: context);

  /// The HTTP method of the request.
  ///
  /// Most commonly "GET" or "POST", less commonly "HEAD", "PUT", or "DELETE".
  /// Non-standard method names are also supported.
  final String method;

  /// The URL to which the request will be sent.
  final Uri url;

  /// Creates a new [Request] by copying existing values and applying specified
  /// changes.
  ///
  /// New key-value pairs in [context] and [headers] will be added to the copied
  /// [Request]. If [context] or [headers] includes a key that already exists,
  /// the key-value pair will replace the corresponding entry in the copied
  /// [Request]. All other context and header values from the [Request] will be
  /// included in the copied [Request] unchanged.
  ///
  /// [body] is the request body. It may be either a [String], a [List<int>], a
  /// [Stream<List<int>>], or `null` to indicate no body.
  @override
  Request change({
    Map<String, String> headers,
    Map<String, Object> context,
    Object body,
  }) {
    final updatedHeaders = updateMap(this.headers, headers);
    final updatedContext = updateMap(this.context, context);

    return Request._(
      method,
      url,
      body ?? getBody(),
      encoding,
      updatedHeaders,
      updatedContext,
    );
  }
}
