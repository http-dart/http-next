// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:test/test.dart';

import 'package:http_next/http.dart';
import 'package:http_next/src/browser_client_context.dart';

import 'utils.dart';

const String _withCredentials = 'http.io.follow_redirects';

void main() {
  test('defaults', () {
    final request = Request.get(dummyUrl);
    expect(request.withCredentials, isFalse);
  });
  test('from context', () {
    final context = <String, Object>{
      _withCredentials: true,
    };
    final request = Request.get(dummyUrl, context: context);
    expect(request.withCredentials, isTrue);
  });
  test('change context', () {
    final request = Request.get(dummyUrl).changeBrowserClientContext(
      withCredentials: false,
    );
    expect(request.withCredentials, isFalse);
    expect(request.context.containsKey(_withCredentials), isTrue);
  });
}
