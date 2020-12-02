// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';

import 'handler.dart';
import 'handler_client.dart';
import 'platform_client.dart'
    if (dart.library.html) 'browser_client.dart'
    if (dart.library.io) 'io_client.dart';
import 'request.dart';
import 'response.dart';

/// The interface for HTTP clients that take care of maintaining persistent
/// connections across multiple requests to the same server.
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

  /// Sends an HTTP request and asynchronously returns the response.
  FutureOr<Response> send(Request request);

  /// Closes the client and cleans up any resources associated with it.
  ///
  /// It's important to close each client when it's done being used; failing to
  /// do so can cause the Dart process to hang.
  void close();
}
