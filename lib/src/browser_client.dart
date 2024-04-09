// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:async/async.dart';

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
  final Set<_XmlHttpRequest> _xhrs = <_XmlHttpRequest>{};

  @override
  FutureOr<Response> send(Request request) async {
    final bytes = await collectBytes(request.read());
    final xhr = _XmlHttpRequest();
    _xhrs.add(xhr);

    xhr
      ..open(request.method, request.url.toString(), true)
      ..responseType = 'arraybuffer'
      ..withCredentials = request.withCredentials;
    for (final header in request.headers.entries) {
      xhr.setRequestHeader(header.key, header.value);
    }

    final completer = Completer<Response>();

    void onLoad(JSAny _) {
      final buffer = xhr.response as ByteBuffer;
      completer.complete(
        Response(
          Uri.parse(xhr.responseURL),
          xhr.status,
          reasonPhrase: xhr.statusText,
          body: Stream.fromIterable([buffer.asUint8List()]),
          headers: xhr.responseHeaders,
        ),
      );
    }

    xhr.addEventListener('load', onLoad.toJS);

    void onError(JSAny _) {
      // Unfortunately, the underlying XMLHttpRequest API doesn't expose any
      // specific information about the error itself.
      completer.completeError(
        ClientException('XMLHttpRequest error', request.url),
        StackTrace.current,
      );
    }

    xhr.addEventListener('error', onError.toJS);

    void onAbort(JSAny _) {
      completer.completeError(
        ClientException('Request cancelled', request.url),
        StackTrace.current,
      );
    }

    xhr.addEventListener('abort', onAbort.toJS);

    void onTimeout(JSAny _) {
      completer.completeError(
        ClientException('Request timed out', request.url),
        StackTrace.current,
      );
    }

    xhr.addEventListener('timeout', onTimeout.toJS);

    xhr.send(bytes.toJS);

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

@JS('XMLHttpRequest')
extension type _XmlHttpRequest._(JSObject _) {
  external factory _XmlHttpRequest();

  external void open(
    String method,
    String url, [
    bool async,
    String? username,
    String? password,
  ]);
  external void setRequestHeader(String name, String value);
  external void send([JSAny? body]);
  external void abort();
  external String getAllResponseHeaders();

  external JSAny? get response;
  external String get responseURL;
  external int get status;
  external String get statusText;

  external String get responseType;
  external set responseType(String value);

  external bool get withCredentials;
  external set withCredentials(bool value);

  external void addEventListener(
    String type,
    JSFunction? callback, [
    JSAny options,
  ]);

  Map<String, String> get responseHeaders {
    // from Closure's goog.net.Xhrio.getResponseHeaders.
    final headers = <String, String>{};
    for (var header in getAllResponseHeaders().split('\r\n')) {
      if (header.isEmpty) {
        continue;
      }

      final splitAt = header.indexOf(': ');
      if (splitAt == -1) {
        continue;
      }

      final key = header.substring(0, splitAt).toLowerCase();
      final value = header.substring(splitAt + 2);
      headers[key] =
          headers.containsKey(key) ? '${headers[key]}, $value' : value;
    }

    return headers;
  }
}
