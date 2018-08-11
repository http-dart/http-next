// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:http_parser/http_parser.dart';

/// Returns the [Encoding] that corresponds to [charset].
///
/// Returns `null` if [charset] is `null` or if no [Encoding] was found that
/// corresponds to [charset].
Encoding encodingForCharset(String charset) =>
    charset != null ? Encoding.getByName(charset) : null;

/// Determines the encoding from the media [type].
///
/// Returns `null` if the charset is not specified in the [type] or if no
/// [Encoding] was found that corresponds to the `charset`.
Encoding encodingForMediaType(MediaType type) =>
    type != null ? encodingForCharset(type.parameters['charset']) : null;
