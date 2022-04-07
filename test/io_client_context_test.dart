// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:http_next/http.dart';
import 'package:http_next/io_client.dart';
import 'package:test/test.dart';

import 'utils.dart';

const String _followRedirects = 'http.io.follow_redirects';
const String _maxRedirects = 'http.io.max_redirects';
const String _persistentConnection = 'http.io.persistent_connection';

void main() {
  test('defaults', () {
    final request = Request.get(dummyUrl);
    expect(request.followRedirects, isTrue);
    expect(request.maxRedirects, equals(5));
    expect(request.persistentConnection, isTrue);
  });
  test('from context', () {
    final context = <String, Object>{
      _followRedirects: false,
      _maxRedirects: 10,
      _persistentConnection: false,
    };
    final request = Request.get(dummyUrl, context: context);
    expect(request.followRedirects, isFalse);
    expect(request.maxRedirects, equals(10));
    expect(request.persistentConnection, isFalse);
  });
  test('change context', () {
    final initialRequest = Request.get(dummyUrl);
    var request = initialRequest.changeIOClientContext(
      followRedirects: false,
      maxRedirects: 10,
      persistentConnection: false,
    );
    expect(request.followRedirects, isFalse);
    expect(request.maxRedirects, equals(10));
    expect(request.persistentConnection, isFalse);

    request = initialRequest.changeIOClientContext(
      followRedirects: true,
    );
    expect(request.followRedirects, isTrue);
    expect(request.context.containsKey(_followRedirects), isTrue);
    expect(request.context.containsKey(_maxRedirects), isFalse);
    expect(request.context.containsKey(_persistentConnection), isFalse);

    request = initialRequest.changeIOClientContext(
      maxRedirects: 10,
    );
    expect(request.maxRedirects, equals(10));
    expect(request.context.containsKey(_followRedirects), isFalse);
    expect(request.context.containsKey(_maxRedirects), isTrue);
    expect(request.context.containsKey(_persistentConnection), isFalse);

    request = initialRequest.changeIOClientContext(
      persistentConnection: true,
    );
    expect(request.persistentConnection, isTrue);
    expect(request.context.containsKey(_followRedirects), isFalse);
    expect(request.context.containsKey(_maxRedirects), isFalse);
    expect(request.context.containsKey(_persistentConnection), isTrue);
  });
}
