// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2017, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';

import 'client.dart';
import 'handler_client.dart';
import 'request.dart';
import 'response.dart';

/// A function which creates a new [Client] by wrapping a [Client].
///
/// You can extend the functions of a [Client] by wrapping it in [Middleware]
/// that can intercept and process a HTTP request before it it sent to a
/// client, a response after it is received by a client, or both.
///
/// Because [Middleware] consumes a [Client] and returns a new [Client],
/// multiple [Middleware] instances can be composed together to offer rich
/// functionality.
///
/// Common uses for middleware include caching, logging, and authentication.
///
/// A simple [Middleware] can be created using [createMiddleware].
typedef Middleware = Client Function(Client inner);

/// A function which may return a modified [request].
///
/// A [RequestHandler] is used to create a [Middleware] through the
/// [createMiddleware] function.
typedef RequestHandler = FutureOr<Request> Function(Request request);

/// A function which may return a modified [response].
///
/// A [ResponseHandler] is used to create a [Middleware] through the
/// [createMiddleware] function.
typedef ResponseHandler = FutureOr<Response> Function(Response response);

/// Creates a [Middleware] using the provided functions.
///
/// If provided, [requestHandler] receives a [Request]. It replies to the
/// request by returning a [FutureOr<Request>]. The modified [Request] is then
/// sent to the inner [Client].
///
/// If provided, [responseHandler] is called with the [Response] generated
/// by the inner [Client]. It replies to the response by returning a
/// [FutureOr<Response]. The modified [Response] is then returned.
///
/// If provided, [onClose] will be invoked when the [Client.close] method is
/// called. Any cleanup of resources should happen at this point.
///
/// If provided, [errorHandler] receives errors thrown by the inner handler. It
/// does not receive errors thrown by [requestHandler] or [responseHandler].
/// It can either return a new response or throw an error.
Middleware createMiddleware({
  RequestHandler requestHandler,
  ResponseHandler responseHandler,
  void Function() onClose,
  void Function(Exception, [StackTrace]) errorHandler,
}) {
  requestHandler ??= _defaultRequestHandler;
  responseHandler ??= _defaultResponseHandler;

  return (inner) => HandlerClient(
        (request) async {
          try {
            final req = await requestHandler(request);
            final res = await inner.send(req);

            return responseHandler(res);
          } on Exception catch (e, stackTrace) {
            errorHandler?.call(e, stackTrace);
            return Response(Uri(), 400);
          }
        },
        onClose == null
            ? inner.close
            : () {
                onClose();
                inner.close();
              },
      );
}

/// Default [RequestHandler] which just returns the given [request] without
/// modification.
Request _defaultRequestHandler(Request request) => request;

/// Default [ResponseHandler] which just returns the given [response] without
/// modification.
Response _defaultResponseHandler(Response response) => response;
