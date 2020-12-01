// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:pedantic/pedantic.dart';

import 'base_client.dart';
import 'client.dart';
import 'exception.dart';
import 'io_client_context.dart';
import 'request.dart';
import 'response.dart';

/// Returns an [IOClient].
Client platformClient() => IOClient();

/// A `dart:io`-based HTTP client.
///
/// This is the default client when running on the command line.
///
/// You can control the underlying `dart:io` [HttpRequest] by adding values to
/// [Request.context] through [IOClientContext].
class IOClient extends BaseClient {
  /// Creates a new HTTP client.
  IOClient([HttpClient inner]) : _inner = inner ?? HttpClient();

  /// The underlying `dart:io` HTTP client.
  HttpClient _inner;

  @override
  FutureOr<Response> send(Request request) async {
    try {
      final ioRequest = await _inner.openUrl(request.method, request.url);

      ioRequest
        ..followRedirects = request.followRedirects
        ..maxRedirects = request.maxRedirects
        ..persistentConnection = request.persistentConnection;

      request.headers.forEach(ioRequest.headers.set);

      unawaited(request.read().pipe(ioRequest));
      final response = await ioRequest.done;

      final headers = <String, String>{};
      response.headers.forEach((key, values) {
        headers[key] = values.join(',');
      });

      return Response(
        _responseUrl(request, response),
        response.statusCode,
        reasonPhrase: response.reasonPhrase,
        body: StreamView(response).handleError(
          (error) {
            // ignore: avoid_as
            final httpError = error as HttpException;
            throw ClientException(httpError.message, httpError.uri);
          },
          test: (error) => error is HttpException,
        ),
        headers: headers,
      );
    } on HttpException catch (error) {
      throw ClientException(error.message, error.uri);
    } on SocketException catch (error) {
      throw ClientException(error.message, request.url);
    }
  }

  @override
  void close() {
    _inner?.close(force: true);
    _inner = null;
  }

  /// Determines the finalUrl retrieved by evaluating any redirects received in
  /// the [response] based on the initial [request].
  Uri _responseUrl(Request request, HttpClientResponse response) {
    var finalUrl = request.url;

    for (final redirect in response.redirects) {
      final location = redirect.location;

      // Redirects can either be absolute or relative
      finalUrl = location.isAbsolute ? location : finalUrl.resolveUri(location);
    }

    return finalUrl;
  }
}
