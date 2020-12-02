// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2017, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';

import 'client.dart';
import 'handler.dart';
import 'request.dart';
import 'response.dart';

/// A [Handler]-based HTTP client.
///
/// The [HandlerClient] allows composition of a [Client] within a larger
/// application.
class HandlerClient implements Client {
  /// Creates a new client using the [_handler] and [onClose] functions.
  HandlerClient(this._handler, void Function() onClose) : _close = onClose;

  final Handler _handler;
  final void Function() _close;

  @override
  FutureOr<Response> send(Request request) => _handler(request);

  @override
  void close() {
    _close();
  }
}
