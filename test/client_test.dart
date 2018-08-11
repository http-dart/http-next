// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:test/test.dart';

import 'package:http_next/http.dart';

import 'user_agent.dart'
    if (dart.library.html) 'hybrid/user_agent_html.dart'
    if (dart.library.io) 'hybrid/user_agent_io.dart';
import 'utils.dart';

void main() {
  group('client', () {
    // The server url of the spawned server
    Uri serverUrl;

    setUp(() async {
      var channel = spawnHybridUri('hybrid/server.dart');
      serverUrl = Uri.parse(await channel.stream.cast<String>().first);
    });

    test('head', () async {
      var response = await Client().head(serverUrl);
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(body, equals(''));
    });

    test('get', () async {
      var response = await Client().get(serverUrl, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'GET',
            'path': '',
            'headers': {
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            }
          })));
    });

    test('post with string', () async {
      var response = await Client().post(serverUrl, 'request body', headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'POST',
            'path': '',
            'headers': {
              'content-length': '12',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('request body')
          })));
    });

    test('post with string and encoding', () async {
      var response = await Client()
          .post(serverUrl, 'request body', encoding: utf8, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'POST',
            'path': '',
            'headers': {
              'content-type': 'application/octet-stream; charset=utf-8',
              'content-length': '12',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': 'request body'
          })));
    });

    test('post with bytes', () async {
      var response =
          await Client().post(serverUrl, ascii.encode('hello'), headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'POST',
            'path': '',
            'headers': {
              'content-length': '5',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('hello')
          })));
    });

    test('post with fields', () async {
      var response = await Client().post(serverUrl, {
        'some-field': 'value',
        'other-field': 'other value'
      }, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'POST',
            'path': '',
            'headers': {
              'content-type': 'application/x-www-form-urlencoded',
              'content-length': '40',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('some-field=value&other-field=other+value')
          })));
    });

    test('put with string', () async {
      var response = await Client().put(serverUrl, 'request body', headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'PUT',
            'path': '',
            'headers': {
              'content-length': '12',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('request body')
          })));
    });

    test('put with string and encoding', () async {
      var response = await Client()
          .put(serverUrl, 'request body', encoding: utf8, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'PUT',
            'path': '',
            'headers': {
              'content-type': 'application/octet-stream; charset=utf-8',
              'content-length': '12',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': 'request body'
          })));
    });

    test('put with bytes', () async {
      var response =
          await Client().put(serverUrl, ascii.encode('hello'), headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'PUT',
            'path': '',
            'headers': {
              'content-length': '5',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('hello')
          })));
    });

    test('put with fields', () async {
      var response = await Client().put(serverUrl, {
        'some-field': 'value',
        'other-field': 'other value'
      }, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'PUT',
            'path': '',
            'headers': {
              'content-type': 'application/x-www-form-urlencoded',
              'content-length': '40',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('some-field=value&other-field=other+value')
          })));
    });

    test('patch with string', () async {
      var response = await Client().patch(serverUrl, 'request body', headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'PATCH',
            'path': '',
            'headers': {
              'content-length': '12',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('request body')
          })));
    });

    test('patch with string and encoding', () async {
      var response = await Client()
          .patch(serverUrl, 'request body', encoding: utf8, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'PATCH',
            'path': '',
            'headers': {
              'content-type': 'application/octet-stream; charset=utf-8',
              'content-length': '12',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': 'request body'
          })));
    });

    test('patch with bytes', () async {
      var response =
          await Client().patch(serverUrl, ascii.encode('hello'), headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'PATCH',
            'path': '',
            'headers': {
              'content-length': '5',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('hello')
          })));
    });

    test('patch with fields', () async {
      var response = await Client().patch(serverUrl, {
        'some-field': 'value',
        'other-field': 'other value'
      }, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'PATCH',
            'path': '',
            'headers': {
              'content-type': 'application/x-www-form-urlencoded',
              'content-length': '40',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            },
            'body': ascii.encode('some-field=value&other-field=other+value')
          })));
    });

    test('delete', () async {
      var response = await Client().delete(serverUrl, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      var body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(
          body,
          parse(equals({
            'method': 'DELETE',
            'path': '',
            'headers': {
              'content-length': '0',
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            }
          })));
    });

    test('read', () async {
      var body = await Client().read(serverUrl, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });

      expect(
          body,
          parse(equals({
            'method': 'GET',
            'path': '',
            'headers': {
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            }
          })));
    });

    test('read throws an error for a 4** status code', () async {
      expect(() => Client().read(serverUrl.resolve('/error')),
          throwsClientException());
    });

    test('readBytes', () async {
      var body = await Client().readBytes(serverUrl, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });

      expect(
          String.fromCharCodes(body),
          parse(equals({
            'method': 'GET',
            'path': '',
            'headers': {
              'user-agent': userAgent(),
              'x-random-header': 'Value',
              'x-other-header': 'Other Value'
            }
          })));
    });

    test('readBytes throws an error for a 4** status code', () async {
      expect(() => Client().readBytes(serverUrl.resolve('/error')),
          throwsClientException());
    });
  });
}
