// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:test/test.dart';

import 'package:http_next/http.dart';
import 'package:http_next/src/boundary.dart';

final _validBoundaries = [
  // 1 character is fine
  'd',
  'dart-http-boundary',
  // Generated boundary
  boundaryString(),
];

final _invalidBoundaries = [
  // Boundary must be at least 1 character
  '',
  // Boundary must be less than 70 characters
  String.fromCharCodes(List.generate(71, (index) => 92)),
  // Invalid character !
  'dart-http-boundary-!',
  // Invalid character %
  'dart-http-boundary-%',
];

void main() {
  test('create boundary', () {
    final boundary = boundaryString();
    expect(boundary, startsWith('dart-http-boundary-'));
    expect(boundary, hasLength(70));
    expect(validBoundaryString(boundary), isTrue);
  });

  test('valid boundary', () {
    for (final boundary in _validBoundaries) {
      expect(validBoundaryString(boundary), isTrue);
    }
  });

  test('invalid boundary', () {
    for (final boundary in _invalidBoundaries) {
      expect(validBoundaryString(boundary), isFalse);
    }
  });

  test('invalid boundary in multipart', () {
    final url = Uri.parse('http://localhost/');
    for (final boundary in _invalidBoundaries) {
      expect(
        () => Request.multipart(url, boundary: boundary),
        throwsArgumentError,
      );
    }
  });
}
