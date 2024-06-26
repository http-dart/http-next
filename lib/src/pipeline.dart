// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2017, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'client.dart';
import 'handler.dart';
import 'middleware.dart';

/// A helper that makes it easy to compose a set of [Middleware] and a
/// [Client].
///
///     var client = const Pipeline()
///         .addMiddleware(loggingMiddleware)
///         .addMiddleware(basicAuthMiddleware)
///         .addClient(new Client());
class Pipeline {
  /// Creates a [Pipeline].
  const Pipeline();

  /// Returns a new [Pipeline] with [middleware] added to the existing set of
  /// [Middleware].
  ///
  /// [middleware] will be the last [Middleware] to process a request and
  /// the first to process a response.
  Pipeline addMiddleware(Middleware middleware) => _Pipeline(this, middleware);

  /// Returns a new [Client] with [client] as the final processor of a
  /// [Request] if all of the middleware in the pipeline have passed the request
  /// through.
  Client addClient(Client client) => client;

  /// Returns a new [Client] with [handler] as the final processor of a
  /// [Request] if all of the middleware in the pipeline have passed the request
  /// through.
  Client addHandler(Handler handler) => addClient(Client.handler(handler));

  /// Exposes this pipeline of [Middleware] as a single middleware instance.
  Middleware get middleware => addClient;
}

class _Pipeline extends Pipeline {
  final Pipeline _parent;
  final Middleware _middleware;

  _Pipeline(this._parent, this._middleware);

  @override
  Client addClient(Client client) => _parent.addClient(_middleware(client));
}
