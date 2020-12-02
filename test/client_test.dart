// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2014, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

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
    // The HTTP client to use
    Client client;

    setUpAll(() async {
      final channel = spawnHybridUri('hybrid/server.dart');
      serverUrl = Uri.parse(await channel.stream.cast<String>().first);

      client = Client();
    });

    tearDownAll(() {
      client.close();
    });

    test('head', () async {
      final response = await client.head(serverUrl);
      final body = await response.readAsString();

      expect(response.statusCode, equals(200));
      expect(body, equals(''));
    });

    test('get', () async {
      final response = await client.get(serverUrl, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final response = await client.post(serverUrl, 'request body', headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final response = await client
          .post(serverUrl, 'request body', encoding: utf8, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final response =
          await client.post(serverUrl, ascii.encode('hello'), headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final request = Request.urlEncoded(
        serverUrl,
        {'some-field': 'value', 'other-field': 'other value'},
        method: 'POST',
        headers: {
          'X-Random-Header': 'Value',
          'X-Other-Header': 'Other Value',
          'User-Agent': userAgent()
        },
      );

      final response = await client.send(request);
      final body = await response.readAsString();

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
      final response = await client.put(serverUrl, 'request body', headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final response =
          await client.put(serverUrl, 'request body', encoding: utf8, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final response =
          await client.put(serverUrl, ascii.encode('hello'), headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final request = Request.urlEncoded(
        serverUrl,
        {'some-field': 'value', 'other-field': 'other value'},
        method: 'PUT',
        headers: {
          'X-Random-Header': 'Value',
          'X-Other-Header': 'Other Value',
          'User-Agent': userAgent()
        },
      );
      final response = await client.send(request);
      final body = await response.readAsString();

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
      final response = await client.patch(serverUrl, 'request body', headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final response = await client
          .patch(serverUrl, 'request body', encoding: utf8, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final response =
          await client.patch(serverUrl, ascii.encode('hello'), headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final request = Request.urlEncoded(
        serverUrl,
        {'some-field': 'value', 'other-field': 'other value'},
        method: 'PATCH',
        headers: {
          'X-Random-Header': 'Value',
          'X-Other-Header': 'Other Value',
          'User-Agent': userAgent()
        },
      );
      final response = await client.send(request);
      final body = await response.readAsString();

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
      final response = await client.delete(serverUrl, headers: {
        'X-Random-Header': 'Value',
        'X-Other-Header': 'Other Value',
        'User-Agent': userAgent()
      });
      final body = await response.readAsString();

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
      final body = await client.read(serverUrl, headers: {
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
      expect(() => client.read(serverUrl.resolve('/error')),
          throwsClientException());
    });

    test('readBytes', () async {
      final body = await client.readBytes(serverUrl, headers: {
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
      expect(() => client.readBytes(serverUrl.resolve('/error')),
          throwsClientException());
    });
  });
}
