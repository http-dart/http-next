// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:pedantic/pedantic.dart';

import 'browser_client_context.dart';
import 'client.dart';
import 'exception.dart';
import 'request.dart';
import 'response.dart';

/// Returns a [BrowserClient].
Client platformClient() => BrowserClient();

/// A `dart:html`-based HTTP client that runs in the browser and is backed by
/// XMLHttpRequests.
///
/// This client inherits some of the limitations of XMLHttpRequest. It is
/// unable to directly set some headers, such as `content-length`. It is also
/// unable to stream requests or responses; a request will only be sent and a
/// response will only be returned once all the data is available.
///
/// You can control the underlying `dart:html` [HttpRequest] by adding values to
/// [Request.context] through [BrowserClientContext].
class BrowserClient implements Client {
  /// Creates a new HTTP client.
  BrowserClient();

  /// The currently active XHRs.
  ///
  /// These are aborted if the client is closed.
  final Set<html.HttpRequest> _xhrs = <html.HttpRequest>{};

  @override
  FutureOr<Response> send(Request request) async {
    final bytes = await collectBytes(request.read());
    final xhr = html.HttpRequest();
    _xhrs.add(xhr);

    xhr
      ..open(request.method, request.url.toString())
      ..responseType = 'arraybuffer'
      ..withCredentials = request.withCredentials;
    request.headers.forEach(xhr.setRequestHeader);

    final completer = Completer<Response>();
    unawaited(
      xhr.onLoad.first.then((_) {
        // ignore: avoid_as
        final buffer = xhr.response as ByteBuffer;
        completer.complete(
          Response(
            Uri.parse(xhr.responseUrl),
            xhr.status,
            reasonPhrase: xhr.statusText,
            body: Stream.fromIterable([buffer.asUint8List()]),
            headers: xhr.responseHeaders,
          ),
        );
      }),
    );

    unawaited(
      xhr.onError.first.then((_) {
        // Unfortunately, the underlying XMLHttpRequest API doesn't expose any
        // specific information about the error itself.
        completer.completeError(
          ClientException('XMLHttpRequest error', request.url),
          StackTrace.current,
        );
      }),
    );

    // Catch the abort event so futures complete when close is called.
    unawaited(
      xhr.onAbort.first.then((_) {
        completer.completeError(
          ClientException('Request cancelled', request.url),
          StackTrace.current,
        );
      }),
    );

    xhr.send(bytes);

    try {
      return await completer.future;
    } finally {
      _xhrs.remove(xhr);
    }
  }

  @override
  void close() {
    for (final xhr in _xhrs) {
      xhr.abort();
    }
  }
}
