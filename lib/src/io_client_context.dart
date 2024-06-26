// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'context.dart';
import 'request.dart';

/// Allows the [Request] to control the underlying [IOClient].
extension IOClientContext on Request {
  static const _followRedirectsKey = 'http.io.follow_redirects';
  static const _maxRedirectsKey = 'http.io.max_redirects';
  static const _persistentConnectionKey = 'http.io.persistent_connection';

  /// Whether the `dart:io` [HttpRequest] should follow redirects.
  ///
  /// When its `true` (the default) then the request will automatically follow
  /// HTTP redirects. If it's `false`, the client will need to handle redirects
  /// manually. See also [HttpClientRequest.followRedirects].
  bool get followRedirects =>
      context.getOrDefault<bool>(_followRedirectsKey, true);

  /// The maximum number of redirects that will be followed if [followRedirects]
  /// is `true`.
  ///
  /// If the site redirects more than this, [send] will throw a
  /// [ClientException]. It defaults to `5`. See also
  /// [HttpClientRequest.maxRedirects].
  int get maxRedirects => context.getOrDefault<int>(_maxRedirectsKey, 5);

  /// Whether the client will request that the TCP connection be kept alive
  /// after the request completes.
  ///
  /// The default value is `true`. See also
  /// [HttpClientRequest.persistentConnection].
  bool get persistentConnection =>
      context.getOrDefault<bool>(_persistentConnectionKey, true);

  /// Modifies the [Request.context] to set [IOClient] specific values.
  Request changeIOClientContext({
    bool? followRedirects,
    int? maxRedirects,
    bool? persistentConnection,
  }) {
    final context = <String, Object>{};

    if (followRedirects != null) {
      context[_followRedirectsKey] = followRedirects;
    }
    if (maxRedirects != null) {
      context[_maxRedirectsKey] = maxRedirects;
    }
    if (persistentConnection != null) {
      context[_persistentConnectionKey] = persistentConnection;
    }
    return change(context: context);
  }
}
