// Copyright (c) 2021, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:http_parser/http_parser.dart';

/// Convenience methods for querying a [MediaType]'s `type/subtype`.
extension MediaTypeQuery on MediaType {
  /// Determines if the [MediaType] is the same [type], and optional [subtype].
  ///
  /// If no [subtype] is specified only the [type] is checked.
  bool isMimeType(String type, [String subtype]) {
    final subtypeMatch = subtype == null || subtype == this.subtype;
    return type == this.type && subtypeMatch;
  }
}
