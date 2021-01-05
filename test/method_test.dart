// Copyright (c) 2021, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:test/test.dart';

import 'package:http_next/http.dart';

void main() {
  test('token', () {
    expect(Method.get.token, equals('GET'));
    expect(Method.head.token, equals('HEAD'));
    expect(Method.post.token, equals('POST'));
    expect(Method.put.token, equals('PUT'));
    expect(Method.patch.token, equals('PATCH'));
    expect(Method.delete.token, equals('DELETE'));
    expect(Method.connect.token, equals('CONNECT'));
    expect(Method.options.token, equals('OPTIONS'));
    expect(Method.trace.token, equals('TRACE'));
  });
}
