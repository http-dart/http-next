// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'context.dart';
import 'request.dart';

/// Allows the [Request] to control the underlying [BrowserClient].
extension BrowserClientContext on Request {
  static const _withCredentialsKey = 'http.html.with_credentials';

  /// Whether cross-site requests will include credentials such as cookies or
  /// or authorization headers.
  ///
  /// The default value is `false`. See also [HttpRequest.withCredentials].
  bool get withCredentials =>
      context.getOrDefault<bool>(_withCredentialsKey, false);

  /// Modifies the [Request.context] to set [BrowserClient] specific values.
  Request changeBrowserClientContext({
    bool? withCredentials,
  }) {
    final context = <String, Object>{};

    if (withCredentials != null) {
      context[_withCredentialsKey] = withCredentials;
    }

    return change(context: context);
  }
}
