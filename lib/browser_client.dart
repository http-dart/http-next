// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:async/async.dart';

import 'src/base_client.dart';
import 'src/exception.dart';
import 'src/request.dart';
import 'src/response.dart';

// TODO(nweiz): Move this under src/, re-export from lib/http.dart, and use this
// automatically from [new Client] once sdk#24581 is fixed.

/// A `dart:html`-based HTTP client that runs in the browser and is backed by
/// XMLHttpRequests.
///
/// This client inherits some of the limitations of XMLHttpRequest. It is
/// unable to directly set some headers, such as `content-length`. It is also
/// unable to stream requests or responses; a request will only be sent and a
/// response will only be returned once all the data is available.
///
/// You can control the underlying `dart:html` [HttpRequest] by adding values to
/// [Request.context]:
///
/// * `"http.html.with_credentials"` is a boolean that defaults to `false`. If
///   it's `true`, cross-site requests will include credentials such as cookies
///   or authorization headers. See also [HttpRequest.withCredentials].
class BrowserClient extends BaseClient {
  /// The currently active XHRs.
  ///
  /// These are aborted if the client is closed.
  final _xhrs = new Set<HttpRequest>();

  /// Creates a new HTTP client.
  BrowserClient();

  Future<Response> send(Request request) async {
    var bytes = await collectBytes(request.read());
    var xhr = new HttpRequest();
    _xhrs.add(xhr);

    xhr.open(request.method, request.url.toString());
    xhr.responseType = 'blob';
    xhr.withCredentials =
        request.context['http.html.with_credentials'] ?? false;
    request.headers.forEach(xhr.setRequestHeader);

    var completer = new Completer<Response>();
    xhr.onLoad.first.then((_) {
      // TODO(nweiz): Set the response type to "arraybuffer" when issue 18542
      // is fixed.
      var blob = xhr.response == null ? new Blob([]) : xhr.response;
      var reader = new FileReader();

      reader.onLoad.first.then((_) {
        var body = reader.result as Uint8List;
        completer.complete(new Response(xhr.responseUrl, xhr.status,
            reasonPhrase: xhr.statusText,
            body: new Stream.fromIterable([body]),
            headers: xhr.responseHeaders));
      });

      reader.onError.first.then((error) {
        completer.completeError(
            new ClientException(error.toString(), request.url),
            StackTrace.current);
      });

      reader.readAsArrayBuffer(blob);
    });

    xhr.onError.first.then((_) {
      // Unfortunately, the underlying XMLHttpRequest API doesn't expose any
      // specific information about the error itself.
      completer.completeError(
          new ClientException("XMLHttpRequest error.", request.url),
          StackTrace.current);
    });

    // Catch the abort event so futures complete when close is called.
    xhr.onAbort.first.then((_) {
      completer.completeError(
          new ClientException('Request cancelled', request.url),
          StackTrace.current);
    });

    xhr.send(bytes);

    try {
      return await completer.future;
    } finally {
      _xhrs.remove(xhr);
    }
  }

  void close() {
    for (var xhr in _xhrs) {
      xhr.abort();
    }
  }
}
