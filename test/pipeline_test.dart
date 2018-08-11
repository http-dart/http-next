// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';

import 'package:http_next/http.dart';

void main() {
  test('compose middleware with Pipeline', () async {
    var accessLocation = 0;

    final middlewareA = createMiddleware(requestHandler: (request) async {
      expect(accessLocation, 0);
      accessLocation = 1;
      return request;
    }, responseHandler: (response) async {
      expect(accessLocation, 4);
      accessLocation = 5;
      return response;
    });

    final middlewareB = createMiddleware(requestHandler: (request) async {
      expect(accessLocation, 1);
      accessLocation = 2;
      return request;
    }, responseHandler: (response) async {
      expect(accessLocation, 3);
      accessLocation = 4;
      return response;
    });

    final client = const Pipeline()
        .addMiddleware(middlewareA)
        .addMiddleware(middlewareB)
        .addClient(Client.handler((request) async {
      expect(accessLocation, 2);
      accessLocation = 3;
      return Response(Uri.parse('dart:http'), 200);
    }));

    final response = await client.get(Uri.parse('dart:http'));

    expect(response, isNotNull);
    expect(accessLocation, 5);
  });

  test('Pipeline can be used as middleware', () async {
    var accessLocation = 0;

    final middlewareA = createMiddleware(requestHandler: (request) async {
      expect(accessLocation, 0);
      accessLocation = 1;
      return request;
    }, responseHandler: (response) async {
      expect(accessLocation, 4);
      accessLocation = 5;
      return response;
    });

    final middlewareB = createMiddleware(requestHandler: (request) async {
      expect(accessLocation, 1);
      accessLocation = 2;
      return request;
    }, responseHandler: (response) async {
      expect(accessLocation, 3);
      accessLocation = 4;
      return response;
    });

    final innerPipeline =
        const Pipeline().addMiddleware(middlewareA).addMiddleware(middlewareB);

    final client = const Pipeline()
        .addMiddleware(innerPipeline.middleware)
        .addClient(Client.handler((request) async {
      expect(accessLocation, 2);
      accessLocation = 3;
      return Response(Uri.parse('dart:http'), 200);
    }));

    final response = await client.get(Uri.parse('dart:http'));

    expect(response, isNotNull);
    expect(accessLocation, 5);
  });

  test('Pipeline calls close on all middleware', () {
    var accessLocation = 0;

    final middlewareA = createMiddleware(onClose: () {
      expect(accessLocation, 0);
      accessLocation = 1;
    });

    final middlewareB = createMiddleware(onClose: () {
      expect(accessLocation, 1);
      accessLocation = 2;
    });

    const Pipeline()
        .addMiddleware(middlewareA)
        .addMiddleware(middlewareB)
        .addClient(Client.handler((request) async => null, onClose: () {
          expect(accessLocation, 2);
          accessLocation = 3;
        }))
          ..close();

    expect(accessLocation, 3);
  });
}
