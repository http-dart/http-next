// Copyright (c) 2021, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:convert';

import 'package:http_next/src/media_type_encoding.dart';
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';

MediaType _text() => MediaType('text', 'plain');

MediaType _textWithCharset(String charset) =>
    MediaType('text', 'plain', <String, String>{'charset': charset});

void main() {
  group('encoding', () {
    test('none', () {
      final mediaType = _text();
      expect(mediaType.encoding, isNull);
    });
    test('unknown', () {
      final mediaType = _textWithCharset('not-a-charset');
      expect(mediaType.encoding, isNull);
    });
    test('ascii', () {
      final mediaType = _textWithCharset(ascii.name);
      expect(mediaType.encoding, ascii);
    });
    test('latin', () {
      final mediaType = _textWithCharset(latin1.name);
      expect(mediaType.encoding, latin1);
    });
    test('utf8', () {
      final mediaType = _textWithCharset(utf8.name);
      expect(mediaType.encoding, utf8);
    });
  });
  group('defaultEncoding', () {
    test('text', () {
      final plain = _text();
      expect(plain.defaultEncoding, ascii);
      final csv = MediaType('text', 'csv');
      expect(csv.defaultEncoding, ascii);
    });
    test('json', () {
      final json = MediaType('application', 'json');
      expect(json.defaultEncoding, utf8);
    });
    test('unknown', () {
      final octet = MediaType('application', 'octet-stream');
      expect(octet.defaultEncoding, isNull);
      final image = MediaType('image', 'png');
      expect(image.defaultEncoding, isNull);
    });
  });
  group('changeEncoding', () {
    test('ascii', () {
      final mediaType = _text().changeEncoding(ascii);
      expect(mediaType.parameters['charset'], ascii.name);
      expect(mediaType.encoding, ascii);
    });
    test('latin', () {
      final mediaType = _text().changeEncoding(latin1);
      expect(mediaType.parameters['charset'], latin1.name);
      expect(mediaType.encoding, latin1);
    });
    test('utf8', () {
      final mediaType = _text().changeEncoding(utf8);
      expect(mediaType.parameters['charset'], utf8.name);
      expect(mediaType.encoding, utf8);
    });
  });
}
