// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:test/test.dart';

import 'package:http_next/http.dart';
import 'package:http_next/src/message.dart';

final _uri = Uri.parse('http://localhost/');

void main() {
  group('Request', () {
    _testChange(({body, headers, context}) =>
        Request('GET', _uri, body: body, headers: headers, context: context));
  });

  group('Response', () {
    _testChange(({body, headers, context}) =>
        Response(_uri, 200, body: body, headers: headers, context: context));
  });
}

/// Shared test method used by [Request] and [Response] tests to validate
/// the behavior of `change` with different `headers` and `context` values.
void _testChange(
    Message factory(
        {body, Map<String, String> headers, Map<String, Object> context})) {
  group('body', () {
    test('with String', () async {
      final request = factory(body: 'Hello, world');
      final copy = request.change(body: 'Goodbye, world');

      final newBody = await copy.readAsString();

      expect(newBody, equals('Goodbye, world'));
    });

    test('with Stream', () async {
      final request = factory(body: 'Hello, world');
      final copy = request.change(
          body:
              Stream.fromIterable(['Goodbye, world']).transform(utf8.encoder));

      final newBody = await copy.readAsString();

      expect(newBody, equals('Goodbye, world'));
    });
  });

  test('with empty headers returns identical instance', () {
    final request = factory(headers: {'header1': 'header value 1'});
    final copy = request.change(headers: {});

    expect(copy.headers, same(request.headers));
  });

  test('with empty context returns identical instance', () {
    final request = factory(context: {'context1': 'context value 1'});
    final copy = request.change(context: {});

    expect(copy.context, same(request.context));
  });

  test('new header values are added', () {
    final request = factory(headers: {'test': 'test value'});
    final copy = request.change(headers: {'test2': 'test2 value'});

    expect(copy.headers,
        {'test': 'test value', 'test2': 'test2 value', 'content-length': '0'});
  });

  test('existing header values are overwritten', () {
    final request = factory(headers: {'test': 'test value'});
    final copy = request.change(headers: {'test': 'new test value'});

    expect(copy.headers, {'test': 'new test value', 'content-length': '0'});
  });

  test('new context values are added', () {
    final request = factory(context: {'test': 'test value'});
    final copy = request.change(context: {'test2': 'test2 value'});

    expect(copy.context, {'test': 'test value', 'test2': 'test2 value'});
  });

  test('existing context values are overwritten', () {
    final request = factory(context: {'test': 'test value'});
    final copy = request.change(context: {'test': 'new test value'});

    expect(copy.context, {'test': 'new test value'});
  });
}
