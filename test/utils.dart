// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2013, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:convert';

import 'package:http_next/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';

/// A dummy URL for constructing requests that won't be sent.
Uri get dummyUrl => Uri.parse('http://dartlang.org/');

/// Removes eight spaces of leading indentation from a multiline string.
///
/// Note that this is very sensitive to how the literals are styled. They should
/// be:
///     '''
///     Text starts on own line. Lines up with subsequent lines.
///     Lines are indented exactly 8 characters from the left margin.
///     Close is on the same line.'''
///
/// This does nothing if text is only a single line.
String cleanUpLiteral(String text) {
  final lines = text.split('\n');
  if (lines.length <= 1) {
    return text;
  }

  final leadingSpaces = _getLeadingSpaces(lines[0]);
  final lineCount = lines.length;

  for (var i = 0; i < lineCount; i++) {
    final line = lines[i];
    final lineLength = line.length;

    lines[i] =
        (lineLength > leadingSpaces) ? line.substring(leadingSpaces) : '';
  }

  return lines.join('\n');
}

/// Returns the number of leading spaces in the [value].
int _getLeadingSpaces(String value) {
  final count = value.length;

  for (var i = 0; i < count; ++i) {
    // An ascii value of 32 corresponds to a space
    if (value.codeUnitAt(i) != 32) {
      return i;
    }
  }

  return count;
}

/// A matcher that matches JSON that parses to a value that matches the inner
/// matcher.
Matcher parse(Matcher matcher) => _Parse(matcher);

class _Parse extends Matcher {
  final Matcher _matcher;

  _Parse(this._matcher);

  @override
  bool matches(item, Map matchState) {
    if (item is! String) {
      return false;
    }

    final String encoded = item;
    dynamic parsed;

    try {
      parsed = jsonDecode(encoded);
    } catch (e) {
      return false;
    }

    return _matcher.matches(parsed, matchState);
  }

  @override
  Description describe(Description description) =>
      description.add('parses to a value that ').addDescriptionOf(_matcher);
}

/// A matcher that validates the body of a multipart request after finalization.
///
/// The string "{{boundary}}" in [pattern] will be replaced by the boundary
/// string for the request, and LF newlines will be replaced with CRLF.
/// Indentation will be normalized.
Matcher multipartBodyMatches(String pattern) => _MultipartBodyMatches(pattern);

class _MultipartBodyMatches extends Matcher {
  final String _pattern;

  _MultipartBodyMatches(this._pattern);

  @override
  bool matches(item, Map matchState) {
    if (item is! http.Request) {
      return false;
    }

    final http.Request request = item;

    final future = request.readAsBytes().then((bodyBytes) {
      final body = utf8.decode(bodyBytes);
      final contentType = MediaType.parse(request.headers['content-type']);
      final boundary = contentType.parameters['boundary'];
      final expected = cleanUpLiteral(_pattern)
          .replaceAll('\n', '\r\n')
          .replaceAll('{{boundary}}', boundary);

      expect(body, equals(expected));
      expect(item.contentLength, equals(bodyBytes.length));
    });

    return completes.matches(future, matchState);
  }

  @override
  Description describe(Description description) =>
      description.add('has a body that matches "$_pattern"');
}

/// A matcher that matches a [http.ClientException] with the given [message].
///
/// [message] can be a String or a [Matcher].
Matcher isClientException([message]) => predicate((error) {
      expect(error, const TypeMatcher<http.ClientException>());
      if (message != null) {
        expect(error.message, message);
      }
      return true;
    });

/// A matcher that matches function or future that throws a
/// [http.ClientException] with the given [message].
///
/// [message] can be a String or a [Matcher].
Matcher throwsClientException([message]) => throwsA(isClientException(message));
