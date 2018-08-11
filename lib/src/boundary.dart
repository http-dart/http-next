// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

/// All character codes that are valid in multipart boundaries.
///
/// This is the intersection of the characters allowed in the `bcharsnospace`
/// production defined in [RFC 2046][] and those allowed in the `token`
/// production defined in [RFC 1521][].
///
/// [RFC 2046]: http://tools.ietf.org/html/rfc2046#section-5.1.1.
/// [RFC 1521]: https://tools.ietf.org/html/rfc1521#section-4
const List<int> _boundaryCharacters = const <int>[
  43, 95, 45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, //
  69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86,
  87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107,
  108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121,
  122
];

/// The total length of the multipart boundaries used when building the
/// request body.
///
/// According to http://tools.ietf.org/html/rfc1341.html, this can't be longer
/// than 70.
const int _boundaryLength = 70;

final Random _random = Random();

/// Returns a randomly-generated multipart boundary string
String boundaryString() {
  final prefix = 'dart-http-boundary-';
  final list = List<int>.generate(
      _boundaryLength - prefix.length,
      (index) =>
          _boundaryCharacters[_random.nextInt(_boundaryCharacters.length)],
      growable: false);
  return '$prefix${String.fromCharCodes(list)}';
}
