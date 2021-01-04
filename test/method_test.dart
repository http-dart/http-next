// Copyright (c) 2021, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:test/test.dart';

import 'package:http_next/http.dart';

void main() {
  test('token', () {
    expect(Method.get.token, 'GET');
    expect(Method.head.token, 'HEAD');
    expect(Method.post.token, 'POST');
    expect(Method.put.token, 'PUT');
    expect(Method.patch.token, 'PATCH');
    expect(Method.delete.token, 'DELETE');
    expect(Method.connect.token, 'CONNECT');
    expect(Method.options.token, 'OPTIONS');
    expect(Method.trace.token, 'TRACE');
  });
}
