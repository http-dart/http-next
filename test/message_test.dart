// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2017, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:http_next/src/message.dart';
import 'package:http_next/src/text_message.dart';
import 'package:test/test.dart';

/// A non-ASCII string.
const _nonAscii = 'föøbãr';

/// The UTF-8 encoding of [_nonAscii].
final _utf8Bytes = utf8.encode(_nonAscii);

/// The Latin-1 encoding of [_nonAscii].
final _latin1Bytes = latin1.encode(_nonAscii);

/// The ASCII bytes in the string "hello,".
final _helloBytes = ascii.encode('hello,');

/// The ASCII bytes in the string " world".
final _worldBytes = ascii.encode(' world');

class _TestMessage extends Message {
  _TestMessage(super.body, {super.encoding, super.headers, super.context});

  @override
  Message change({
    Map<String, String>? headers,
    Map<String, Object>? context,
    Object? body,
  }) {
    throw UnimplementedError();
  }
}

Message _createMessage({
  Map<String, String>? headers,
  Map<String, Object>? context,
  Object? body,
  Encoding? encoding,
}) =>
    _TestMessage(body, encoding: encoding, headers: headers, context: context);

void main() {
  group('headers', () {
    test('are case insensitive', () {
      final message = _createMessage(headers: {'foo': 'bar'});

      expect(message.headers, containsPair('foo', 'bar'));
      expect(message.headers, containsPair('Foo', 'bar'));
      expect(message.headers, containsPair('FOO', 'bar'));
    });

    test('default to a constant map', () {
      final message = _createMessage();
      expect(message.headers.containsKey('content-length'), isFalse);
      expect(message.headers, same(_createMessage().headers));
      expect(() => message.headers['h1'] = 'value1', throwsUnsupportedError);
    });

    test('are immutable', () {
      final message = _createMessage(headers: {'h1': 'value'});
      expect(() => message.headers['h1'] = 'value', throwsUnsupportedError);
    });
  });

  group('context', () {
    test('is accessible', () {
      final message = _createMessage(context: {'foo': 'bar'});
      expect(message.context, containsPair('foo', 'bar'));
    });

    test('defaults to an empty immutable map', () {
      final message = _createMessage();
      expect(message.context, isEmpty);
      expect(() => message.context['key'] = 'value', throwsUnsupportedError);
    });

    test('is immutable', () {
      final message = _createMessage(context: {'key': 'value'});
      expect(() => message.context['key'] = 'value', throwsUnsupportedError);
    });
  });

  group('readAsString()', () {
    test('returns an empty string for an empty body', () {
      final message = _createMessage();
      expect(message.readAsString(), completion(isEmpty));
    });

    test('collects a streamed body', () async {
      final controller = StreamController<List<int>>();
      final message = _createMessage(body: controller.stream);
      expect(message.readAsString(), completion(equals('hello, world')));

      controller.add(_helloBytes);
      await pumpEventQueue();
      controller.add(_worldBytes);
      await controller.close();
    });

    test('defaults to decoding the message as UTF-8', () {
      final message = _createMessage(body: _utf8Bytes);
      expect(message.readAsString(), completion(equals(_nonAscii)));
    });
  });

  group('readAsBytes()', () {
    test('returns an empty list for an empty body', () {
      final message = _createMessage();
      expect(message.readAsBytes(), completion(isEmpty));
    });

    test('collects a streamed body', () async {
      final controller = StreamController<List<int>>();
      final message = _createMessage(body: controller.stream);
      expect(
        message.readAsBytes(),
        completion(
          equals(<int>[
            ..._helloBytes,
            ..._worldBytes,
          ]),
        ),
      );

      controller.add(_helloBytes);
      await pumpEventQueue();
      controller.add(_worldBytes);
      await controller.close();
    });
  });

  group('read()', () {
    test('returns an empty stream for an empty body', () {
      final message = _createMessage();
      expect(message.read().toList(), completion(isEmpty));
    });

    test('returns a streamed body', () async {
      final controller = StreamController<List<int>>();
      final message = _createMessage(body: controller.stream);
      expect(
        message.read().toList(),
        completion(equals([_helloBytes, _worldBytes])),
      );

      controller.add(_helloBytes);
      await pumpEventQueue();
      controller.add(_worldBytes);
      await controller.close();
    });

    test('returns a List<int> body', () {
      final message = _createMessage(body: _helloBytes);
      expect(message.read().toList(), completion(equals([_helloBytes])));
    });

    test('throws when calling read()/readAsString() multiple times', () {
      var message = _createMessage();
      expect(message.read().toList(), completion(isEmpty));
      expect(() => message.read(), throwsStateError);

      message = _createMessage();
      expect(message.readAsString(), completion(isEmpty));
      expect(() => message.readAsString(), throwsStateError);

      message = _createMessage();
      expect(message.readAsString(), completion(isEmpty));
      expect(() => message.read(), throwsStateError);

      message = _createMessage();
      expect(message.read().toList(), completion(isEmpty));
      expect(() => message.readAsString(), throwsStateError);
    });
  });

  group('content-length', () {
    test('is null with a default body and without a content-length header', () {
      final message = _createMessage();
      expect(message.contentLength, isNull);
    });

    test('comes from a byte body', () {
      final message = _createMessage(body: [1, 2, 3]);
      expect(message.contentLength, 3);
      expect(message.isEmpty, isFalse);
    });

    test('comes from a string body', () {
      final message = _createMessage(body: 'foobar');
      expect(message.contentLength, 6);
      expect(message.isEmpty, isFalse);
    });

    test('is set based on byte length for a string body', () {
      var message = _createMessage(body: 'fööbär');
      expect(message.contentLength, 9);
      expect(message.isEmpty, isFalse);

      message = _createMessage(body: 'fööbär', encoding: latin1);
      expect(message.contentLength, 6);
      expect(message.isEmpty, isFalse);
    });

    test('is null for a stream body', () {
      final message = _createMessage(body: const Stream<List<int>>.empty());
      expect(message.contentLength, isNull);
    });

    test('uses the content-length header for a stream body', () {
      final message = _createMessage(
        body: const Stream<List<int>>.empty(),
        headers: {'content-length': '42'},
      );
      expect(message.contentLength, 42);
      expect(message.isEmpty, isFalse);
    });

    test('real body length takes precedence over content-length header', () {
      final message = _createMessage(
        body: [1, 2, 3],
        headers: {'content-length': '42'},
      );
      expect(message.contentLength, 3);
      expect(message.isEmpty, isFalse);
    });

    test('is null for a chunked transfer encoding', () {
      final message = _createMessage(
        body: '1\r\na0\r\n\r\n',
        headers: {'transfer-encoding': 'chunked'},
      );
      expect(message.contentLength, isNull);
    });

    test('is null for a non-identity transfer encoding', () {
      final message = _createMessage(
        body: '1\r\na0\r\n\r\n',
        headers: {'transfer-encoding': 'custom'},
      );
      expect(message.contentLength, isNull);
    });

    test('is set for identity transfer encoding', () {
      final message = _createMessage(
        body: '1\r\na0\r\n\r\n',
        headers: {'transfer-encoding': 'identity'},
      );
      expect(message.contentLength, equals(9));
      expect(message.isEmpty, isFalse);
    });
  });

  group('mimeType', () {
    test('is null without a content-type header', () {
      expect(_createMessage().mimeType, isNull);
    });

    test('comes from the content-type header', () {
      expect(
        _createMessage(headers: {'content-type': 'text/plain'}).mimeType,
        equals('text/plain'),
      );
    });

    test('does not include parameters', () {
      expect(
        _createMessage(
          headers: {'content-type': 'text/plain; foo=bar; bar=baz'},
        ).mimeType,
        equals('text/plain'),
      );
    });
  });

  group('isMimeType', () {
    test('is false without a content-type header', () {
      final message = _createMessage();
      expect(message.mimeType, isNull);
      expect(message.isMimeType('application'), isFalse);
      expect(message.isMimeType('text'), isFalse);
      expect(message.isMimeType('application', 'octet-stream'), isFalse);
      expect(message.isMimeType('text', 'plain'), isFalse);
    });

    test('can query based on type and subtype', () {
      final message = _createMessage(headers: {'content-type': 'text/plain'});
      expect(message.mimeType, isNotNull);
      expect(message.isMimeType('application'), isFalse);
      expect(message.isMimeType('text'), isTrue);
      expect(message.isMimeType('application', 'octet-stream'), isFalse);
      expect(message.isMimeType('text', 'plain'), isTrue);
      expect(message.isMimeType('text', 'csv'), isFalse);
    });
  });

  group('encoding', () {
    group('is null and content-type header is unchanged with', () {
      group('no content-type header and', () {
        test('no body', () {
          final message = _createMessage();
          expect(message.encoding, isNull);
          expect(message.headers, isNot(contains('content-type')));
        });

        test('a plain ASCII body', () {
          final message = _createMessage(body: 'foo');
          expect(message.encoding, isNull);
          expect(message.headers, isNot(contains('content-type')));
        });

        test('body bytes', () {
          final message = _createMessage(body: _utf8Bytes);
          expect(message.encoding, isNull);
          expect(message.headers, isNot(contains('content-type')));
        });
      });

      group('an unknown content-type header and', () {
        test('no body', () {
          final message = _createMessage(
            headers: {'Content-Type': 'text/plain; charset=not-a-real-charset'},
          );
          expect(message.encoding, isNull);
          expect(
            message.headers,
            containsPair(
              'content-type',
              'text/plain; charset=not-a-real-charset',
            ),
          );
        });

        test('a plain ASCII body', () {
          final message = _createMessage(
            body: 'foo',
            headers: {'Content-Type': 'text/plain; charset=not-a-real-charset'},
          );
          expect(message.encoding, isNull);
          expect(
            message.headers,
            containsPair(
              'content-type',
              'text/plain; charset=not-a-real-charset',
            ),
          );
        });

        test('body bytes', () {
          final message = _createMessage(
            body: _utf8Bytes,
            headers: {'Content-Type': 'text/plain; charset=not-a-real-charset'},
          );
          expect(message.encoding, isNull);
          expect(
            message.headers,
            containsPair(
              'content-type',
              'text/plain; charset=not-a-real-charset',
            ),
          );
          expect(message.readAsString(), completion(equals(_nonAscii)));
        });
      });
    });

    group('defaults to UTF-8 with a non-ASCII body and', () {
      test('no content-type header', () {
        final message = _createMessage(body: _nonAscii);
        expect(message.encoding, equals(utf8));
        expect(
          message.headers,
          containsPair(
            'content-type',
            'application/octet-stream; charset=utf-8',
          ),
        );
        expect(message.readAsBytes(), completion(equals(_utf8Bytes)));
      });

      test('a content-type header', () {
        final message = _createMessage(
          body: _nonAscii,
          headers: {'Content-Type': 'text/plain; charset=iso-8859-1'},
        );
        expect(message.encoding, equals(utf8));
        expect(
          message.headers,
          containsPair('content-type', 'text/plain; charset=utf-8'),
        );
        expect(message.readAsBytes(), completion(equals(_utf8Bytes)));
      });
    });

    group('uses the encoding parameter with', () {
      group('no content-type header and', () {
        test('no body', () {
          final message = _createMessage(encoding: latin1);
          expect(message.encoding, equals(latin1));
          expect(
            message.headers,
            containsPair(
              'content-type',
              'application/octet-stream; charset=iso-8859-1',
            ),
          );
        });

        test('a plain ASCII body', () {
          final message = _createMessage(body: 'foo', encoding: latin1);
          expect(message.encoding, equals(latin1));
          expect(
            message.headers,
            containsPair(
              'content-type',
              'application/octet-stream; charset=iso-8859-1',
            ),
          );
        });

        test('a non-ASCII body', () {
          final message = _createMessage(body: _nonAscii, encoding: latin1);
          expect(message.encoding, equals(latin1));
          expect(
            message.headers,
            containsPair(
              'content-type',
              'application/octet-stream; charset=iso-8859-1',
            ),
          );
          expect(message.readAsBytes(), completion(equals(_latin1Bytes)));
        });

        test('body bytes', () {
          final message = _createMessage(encoding: latin1, body: _latin1Bytes);
          expect(message.encoding, equals(latin1));
          expect(
            message.headers,
            containsPair(
              'content-type',
              'application/octet-stream; charset=iso-8859-1',
            ),
          );
          expect(message.readAsString(), completion(equals(_nonAscii)));
        });
      });

      test('a content-type header without a charset', () {
        final message = _createMessage(
          encoding: latin1,
          headers: {'Content-Type': 'text/plain'},
        );
        expect(
          message.headers,
          containsPair('content-type', 'text/plain; charset=iso-8859-1'),
        );
      });

      group('a content-type header and', () {
        test('no body', () {
          final message = _createMessage(
            encoding: latin1,
            headers: {'Content-Type': 'text/plain; charset=utf-8'},
          );
          expect(message.encoding, equals(latin1));
          expect(
            message.headers,
            containsPair('content-type', 'text/plain; charset=iso-8859-1'),
          );
        });

        test('a plain ASCII body', () {
          final message = _createMessage(
            body: 'foo',
            encoding: latin1,
            headers: {'Content-Type': 'text/plain; charset=utf-8'},
          );
          expect(message.encoding, equals(latin1));
          expect(
            message.headers,
            containsPair('content-type', 'text/plain; charset=iso-8859-1'),
          );
        });

        test('a non-ASCII body', () {
          final message = _createMessage(
            body: _nonAscii,
            encoding: latin1,
            headers: {'Content-Type': 'text/plain; charset=utf-8'},
          );
          expect(message.encoding, equals(latin1));
          expect(
            message.headers,
            containsPair('content-type', 'text/plain; charset=iso-8859-1'),
          );
          expect(message.readAsBytes(), completion(equals(_latin1Bytes)));
        });

        test('body bytes', () {
          final message = _createMessage(
            encoding: latin1,
            body: _latin1Bytes,
            headers: {'Content-Type': 'text/plain; charset=utf-8'},
          );
          expect(message.encoding, equals(latin1));
          expect(
            message.headers,
            containsPair('content-type', 'text/plain; charset=iso-8859-1'),
          );
          expect(message.readAsString(), completion(equals(_nonAscii)));
        });
      });
    });

    group('uses the content-type header with', () {
      test('no body', () {
        final message = _createMessage(
          headers: {'Content-Type': 'text/plain; charset=iso-8859-1'},
        );
        expect(message.encoding!.name, equals(latin1.name));
        expect(
          message.headers,
          containsPair('content-type', 'text/plain; charset=iso-8859-1'),
        );
      });

      test('a plain ASCII body', () {
        final message = _createMessage(
          body: 'foo',
          headers: {'Content-Type': 'text/plain; charset=iso-8859-1'},
        );
        expect(message.encoding!.name, equals(latin1.name));
        expect(
          message.headers,
          containsPair('content-type', 'text/plain; charset=iso-8859-1'),
        );
      });

      test('body bytes', () {
        final message = _createMessage(
          body: _latin1Bytes,
          headers: {'Content-Type': 'text/plain; charset=iso-8859-1'},
        );
        expect(message.encoding!.name, equals(latin1.name));
        expect(
          message.headers,
          containsPair('content-type', 'text/plain; charset=iso-8859-1'),
        );
        expect(message.readAsString(), completion(equals(_nonAscii)));
      });
    });
  });
}
