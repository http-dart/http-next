// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// Indicate the desired action to be performed for a given resource as
/// specified by the HTTP standard.
enum Method {
  /// The `GET` method requests a representation of the specified resource.
  ///
  /// Requests using `GET` should only retrieve data.
  get,

  /// The `HEAD` method asks for a response identical to that of a GET request,
  /// but without the response body.
  head,

  /// The `POST` method is used to submit an entity to the specified resource,
  /// often causing a change in state or side effects on the server.
  post,

  /// The `PUT` method replaces all current representations of the target
  /// resource with the request payload.
  put,

  /// The `PATCH` method is used to apply partial modifications to a resource.
  patch,

  /// The `DELETE` method deletes the specified resource.
  delete,

  /// The `CONNECT` method establishes a tunnel to the server identified by
  /// the target resource.
  connect,

  /// The `OPTIONS` method is used to describe the communication options for
  /// the target resource.
  options,

  /// The `TRACE` method performs a message loop-back test along the path to
  /// the target resource.
  trace,
}

/// Mapping from a [Method] to a recognized token for the action.
extension MethodToken on Method {
  /// Token for a [Method.get] request.
  static const String get = 'GET';

  /// Token for a [Method.head] request.
  static const String head = 'HEAD';

  /// Token for a [Method.post] request.
  static const String post = 'POST';

  /// Token for a [Method.put] request.
  static const String put = 'PUT';

  /// Token for a [Method.patch] request.
  static const String patch = 'PATCH';

  /// Token for a [Method.delete] request.
  static const String delete = 'DELETE';

  /// Token for a [Method.connect] request.
  static const String connect = 'CONNECT';

  /// Token for a [Method.options] request.
  static const String options = 'OPTIONS';

  /// Token for a [Method.trace] request.
  static const String trace = 'TRACE';

  /// Retrieves the token associated with the [Method].
  String get token {
    switch (this) {
      case Method.get:
        return get;
      case Method.head:
        return head;
      case Method.post:
        return post;
      case Method.put:
        return put;
      case Method.patch:
        return patch;
      case Method.delete:
        return delete;
      case Method.connect:
        return connect;
      case Method.options:
        return options;
      case Method.trace:
        return trace;
    }
    return '';
  }
}
