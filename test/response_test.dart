// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2018, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:http_next/http.dart' as http;
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('expires', () {
    test('is null by default', () {
      final response = http.Response(dummyUrl, 200);
      expect(response.expires, isNull);
    });

    test('is parsed from the header', () {
      final response = http.Response(dummyUrl, 200,
          headers: {'Expires': 'Wed, 21 Oct 2015 07:28:00 GMT'});
      expect(response.expires, equals(DateTime.utc(2015, 10, 21, 7, 28)));
    });

    test('throws a FormatException if the header is invalid', () {
      final message =
          http.Response(dummyUrl, 200, headers: {'Expires': 'foobar'});
      expect(() => message.expires, throwsFormatException);
    });
  });

  group('lastModified', () {
    test('is null by default', () {
      final response = http.Response(dummyUrl, 200);
      expect(response.lastModified, isNull);
    });

    test('is parsed from the header', () {
      final response = http.Response(dummyUrl, 200,
          headers: {'Last-Modified': 'Wed, 21 Oct 2015 07:28:00 GMT'});
      expect(response.lastModified, equals(DateTime.utc(2015, 10, 21, 7, 28)));
    });

    test('throws a FormatException if the header is invalid', () {
      final message =
          http.Response(dummyUrl, 200, headers: {'Last-Modified': 'foobar'});
      expect(() => message.lastModified, throwsFormatException);
    });
  });
}
