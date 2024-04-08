// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:convert';

import 'package:http_parser/http_parser.dart';

import 'media_type_query.dart';
import 'mime_types.dart';

/// Convenience methods around [MediaType] to interact with an [Encoding]
/// specified by the `charset` parameter.
extension MediaTypeEncoding on MediaType {
  static const String _charsetParameter = 'charset';

  /// Retrieves the [Encoding] for the [MediaType] specified in the `charset`
  /// parameter.
  Encoding? get encoding => Encoding.getByName(parameters[_charsetParameter]);

  /// Retrieves the default [Encoding] for the [MediaType].
  ///
  /// For `text` types the default encoding is [ascii]. For `application/json`
  /// the default is [utf8]. For all other types no default is specified.
  Encoding? get defaultEncoding {
    if (isMimeType(textType)) {
      return ascii;
    }

    if (isMimeType(applicationType, jsonSubtype)) {
      return utf8;
    }

    return null;
  }

  /// Modifies the [Encoding] for the [MediaType] specified in the `charset`
  /// parameter.
  MediaType changeEncoding(Encoding encoding) =>
      change(parameters: <String, String>{_charsetParameter: encoding.name});
}
