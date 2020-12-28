// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:convert';

import 'package:http_parser/http_parser.dart';

/// Convenience methods around [MediaType] to interact with an [Encoding]
/// specified by the `charset` parameter.
extension MediaTypeEncoding on MediaType {
  static const String _charsetParameter = 'charset';

  /// Retrieves the [Encoding] for the [MediaType] specified in the `charset`
  /// parameter.
  Encoding get encoding => Encoding.getByName(parameters[_charsetParameter]);

  /// Modifies the [Encoding] for the [MediaType] specified in the `charset`
  /// parameter.
  MediaType changeEncoding(Encoding encoding) =>
      change(parameters: <String, String>{_charsetParameter: encoding.name});
}
