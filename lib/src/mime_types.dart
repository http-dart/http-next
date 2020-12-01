// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:http_parser/http_parser.dart';

/// The text mime type.
const String textType = 'text';

/// The application mime type.
const String applicationType = 'application';

/// The plain text mime subtype.
const String plainTextSubtype = 'plain';

/// The octet stream mime subtype.
const String octetStreamSubtype = 'octet-stream';

/// A `text/plain` media type.
///
/// This is the default media type for text data.
MediaType plainTextMediaType() => MediaType(textType, plainTextSubtype);

/// An `application/octet-stream` media type.
///
/// The is the default media type for binary data.
MediaType octetStreamMediaType() =>
    MediaType(applicationType, octetStreamSubtype);
