// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2017, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:http_next/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('empty', () {
    final request = http.Request.multipart(dummyUrl);
    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('errors', () {
    expect(
      () => http.Request.multipart(
        dummyUrl,
        fields: <String, Object>{'foo': 2},
      ),
      throwsArgumentError,
    );
  });

  test('with fields and files', () {
    final fields = <String, String>{
      'field1': 'value1',
      'field2': 'value2',
    };
    final files = [
      http.MultipartFile('file1', 'contents1', filename: 'filename1.txt'),
      http.MultipartFile('file2', 'contents2'),
    ];

    final request =
        http.Request.multipart(dummyUrl, fields: fields, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-disposition: form-data; name="field1"

        value1
        --{{boundary}}
        content-disposition: form-data; name="field2"

        value2
        --{{boundary}}
        content-type: text/plain; charset=utf-8
        content-disposition: form-data; name="file1"; filename="filename1.txt"

        contents1
        --{{boundary}}
        content-type: text/plain; charset=utf-8
        content-disposition: form-data; name="file2"

        contents2
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a unicode field name', () {
    final fields = {'fïēld': 'value'};

    final request = http.Request.multipart(dummyUrl, fields: fields);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-disposition: form-data; name="fïēld"

        value
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a field name with newlines', () {
    final fields = {'foo\nbar\rbaz\r\nbang': 'value'};
    final request = http.Request.multipart(dummyUrl, fields: fields);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-disposition: form-data; name="foo%0D%0Abar%0D%0Abaz%0D%0Abang"

        value
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a field name with a quote', () {
    final fields = {'foo"bar': 'value'};
    final request = http.Request.multipart(dummyUrl, fields: fields);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-disposition: form-data; name="foo%22bar"

        value
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a unicode field value', () {
    final fields = {'field': 'vⱥlūe'};
    final request = http.Request.multipart(dummyUrl, fields: fields);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-disposition: form-data; name="field"
        content-type: text/plain; charset=utf-8
        content-transfer-encoding: binary

        vⱥlūe
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with multiple fields of the same name', () {
    final fields = {
      'field': ['value1', 'value2']
    };
    final request = http.Request.multipart(dummyUrl, fields: fields);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-disposition: form-data; name="field"

        value1
        --{{boundary}}
        content-disposition: form-data; name="field"

        value2
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a unicode filename', () {
    final files = [
      http.MultipartFile('file', 'contents', filename: 'fïlēname.txt')
    ];
    final request = http.Request.multipart(dummyUrl, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-type: text/plain; charset=utf-8
        content-disposition: form-data; name="file"; filename="fïlēname.txt"

        contents
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a filename with newlines', () {
    final files = [
      http.MultipartFile('file', 'contents', filename: 'foo\nbar\rbaz\r\nbang')
    ];
    final request = http.Request.multipart(dummyUrl, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-type: text/plain; charset=utf-8
        content-disposition: form-data; name="file"; filename="foo%0D%0Abar%0D%0Abaz%0D%0Abang"

        contents
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a filename with a quote', () {
    final files = [http.MultipartFile('file', 'contents', filename: 'foo"bar')];
    final request = http.Request.multipart(dummyUrl, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-type: text/plain; charset=utf-8
        content-disposition: form-data; name="file"; filename="foo%22bar"

        contents
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a string file with a content-type but no charset', () {
    final files = [
      http.MultipartFile(
        'file',
        '{"hello": "world"}',
        contentType: MediaType('application', 'json'),
      )
    ];
    final request = http.Request.multipart(dummyUrl, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-type: application/json; charset=utf-8
        content-disposition: form-data; name="file"

        {"hello": "world"}
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a file with a iso-8859-1 body', () {
    // "Ã¥" encoded as ISO-8859-1 and then read as UTF-8 results in "å".
    final files = [
      http.MultipartFile(
        'file',
        'non-ascii: "Ã¥"',
        encoding: latin1,
        contentType: MediaType('text', 'plain'),
      )
    ];
    final request = http.Request.multipart(dummyUrl, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-type: text/plain; charset=iso-8859-1
        content-disposition: form-data; name="file"

        non-ascii: "å"
        --{{boundary}}--
        ''',
      ),
    );
  });

  test('with a stream file', () {
    final controller = StreamController<List<int>>(sync: true);
    final files = [http.MultipartFile.fromStream('file', controller.stream, 5)];
    final request = http.Request.multipart(dummyUrl, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-type: application/octet-stream
        content-disposition: form-data; name="file"

        hello
        --{{boundary}}--
        ''',
      ),
    );

    controller
      ..add([104, 101, 108, 108, 111])
      ..close();
  });

  test('with an empty stream file', () {
    final controller = StreamController<List<int>>(sync: true);
    final files = [http.MultipartFile.fromStream('file', controller.stream, 0)];
    final request = http.Request.multipart(dummyUrl, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-type: application/octet-stream
        content-disposition: form-data; name="file"


        --{{boundary}}--
        ''',
      ),
    );

    controller.close();
  });

  test('with a byte file', () {
    final files = [
      http.MultipartFile('file', [104, 101, 108, 108, 111])
    ];
    final request = http.Request.multipart(dummyUrl, files: files);

    expect(
      request,
      multipartBodyMatches(
        '''
        --{{boundary}}
        content-type: application/octet-stream
        content-disposition: form-data; name="file"

        hello
        --{{boundary}}--
        ''',
      ),
    );
  });
}
