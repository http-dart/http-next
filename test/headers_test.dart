// Copyright (c) 2022, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:http_next/src/body.dart';
import 'package:http_next/src/headers.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('create', () {
    test('null headers', () {
      final headers = Headers.create(null);
      expect(headers, isEmpty);
    });
    test('empty headers', () {
      final headers = Headers.create(<String, String>{});
      expect(headers, isEmpty);
    });
    test('will not rewrap', () {
      final a = Headers.create(<String, String>{'content-length': '0'});
      expect(a, isNotEmpty);
      expect(a, hasLength(1));
      expect(a, containsPair('content-length', '0'));
      final b = Headers.create(a);
      expect(b, isNotEmpty);
      expect(b, hasLength(1));
      expect(b, containsPair('content-length', '0'));
      expect(b, isIdentical(a));
    });
  });

  group('update', () {
    test('with null headers', () {
      final headers = Headers.create(null);
      expect(headers, isEmpty);
      final updated = Headers.update(headers, null);
      expect(updated, isEmpty);
      expect(updated, isIdentical(headers));
    });
    test('with empty headers', () {
      final headers = Headers.create(null);
      expect(headers, isEmpty);
      final updates = Headers.create(null);
      expect(updates, isEmpty);
      final updated = Headers.update(headers, updates);
      expect(updated, isEmpty);
      expect(updated, isIdentical(headers));
    });
    test('will add header', () {
      final headers = Headers.create(<String, String>{'content-length': '0'});
      expect(headers, isNotEmpty);
      expect(headers, hasLength(1));
      expect(headers, containsPair('content-length', '0'));
      final updates =
          Headers.create(<String, String>{'transfer-encoding': 'identity'});
      expect(updates, isNotEmpty);
      expect(updates, hasLength(1));
      expect(updates, containsPair('transfer-encoding', 'identity'));
      final updated = Headers.update(headers, updates);
      expect(updated, isNotEmpty);
      expect(updated, hasLength(2));
      expect(updated, containsPair('content-length', '0'));
      expect(updated, containsPair('transfer-encoding', 'identity'));
    });
    test('will overwrite header', () {
      final headers = Headers.create(<String, String>{'content-length': '0'});
      expect(headers, isNotEmpty);
      expect(headers, hasLength(1));
      expect(headers, containsPair('content-length', '0'));
      final updates = Headers.create(<String, String>{'content-length': '42'});
      expect(updates, isNotEmpty);
      expect(updates, hasLength(1));
      expect(updates, containsPair('content-length', '42'));
      final updated = Headers.update(headers, updates);
      expect(updated, isNotEmpty);
      expect(updated, hasLength(1));
      expect(updated, containsPair('content-length', '42'));
    });
  });

  group('adjust', () {
    test('will not add a content-length of 0', () {
      final headers = Headers.create(null);
      final body = Body(null);
      expect(body.contentLength, 0);
      final adjusted = Headers.adjust(headers, body);
      expect(adjusted, isEmpty);
      expect(adjusted, isIdentical(headers));
    });
    test('keep content-length of 0 when explicitly added', () {
      final headers = Headers.create(<String, String>{'content-length': '0'});
      final body = Body(null);
      expect(body.contentLength, 0);
      final adjusted = Headers.adjust(headers, body);
      expect(adjusted, isNotEmpty);
      expect(adjusted, hasLength(1));
      expect(adjusted, containsPair('content-length', '0'));
    });
    test('remove non-zero content-length when body length is 0', () {
      final headers = Headers.create(<String, String>{'content-length': '42'});
      final body = Body(null);
      expect(body.contentLength, 0);
      final adjusted = Headers.adjust(headers, body);
      expect(adjusted, isEmpty);
    });
    test('add content-length when body length is greater than 0', () {
      final headers = Headers.create(null);
      final body = Body([0, 1, 2]);
      expect(body.contentLength, 3);
      final adjusted = Headers.adjust(headers, body);
      expect(adjusted, isNotEmpty);
      expect(adjusted, hasLength(1));
      expect(adjusted, containsPair('content-length', '3'));
    });
  });
}
