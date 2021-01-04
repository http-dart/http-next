// Copyright (c) 2021, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:test/test.dart';

import 'package:http_parser/http_parser.dart';
import 'package:http_next/src/media_type_query.dart';

void main() {
  group('isMimeType', () {
    test('text', () {
      final type = MediaType('text', 'plain');
      expect(type.isMimeType('text'), isTrue);
      expect(type.isMimeType('text', 'plain'), isTrue);
      expect(type.isMimeType('text', 'csv'), isFalse);
      expect(type.isMimeType('application'), isFalse);
      expect(type.isMimeType('application', 'json'), isFalse);
    });
    test('application', () {
      final type = MediaType('application', 'json');
      expect(type.isMimeType('application'), isTrue);
      expect(type.isMimeType('application', 'json'), isTrue);
      expect(type.isMimeType('application', 'octet-stream'), isFalse);
      expect(type.isMimeType('text'), isFalse);
      expect(type.isMimeType('text', 'plain'), isFalse);
    });
  });
}
