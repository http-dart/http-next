// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2012, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'package:collection/collection.dart';

import 'http_unmodifiable_map.dart';

/// Returns a [Map] with the values from [original] and the values from
/// [updates].
///
/// For keys that are the same between [original] and [updates], the value in
/// [updates] is used.
///
/// If [updates] is `null` or empty, [original] is returned unchanged.
Map<K, V> updateMap<K, V>(Map<K, V> original, Map<K, V> updates) {
  if (updates == null || updates.isEmpty) {
    return original;
  }

  return Map<K, V>.from(original)..addAll(updates);
}

/// A regular expression that matches strings that are composed entirely of
/// ASCII-compatible characters.
final RegExp _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

/// Returns whether [string] is composed entirely of ASCII-compatible
/// characters.
bool isPlainAscii(String string) => _asciiOnly.hasMatch(string);

/// Returns the header with the given [name] in [headers].
///
/// This works even if [headers] is `null`, or if it's not yet a
/// case-insensitive map.
String getHeader(Map<String, String> headers, String name) {
  if (headers == null) {
    return null;
  }
  if (headers is HttpUnmodifiableMap) {
    return headers[name];
  }

  for (final key in headers.keys) {
    if (equalsIgnoreAsciiCase(key, name)) {
      return headers[key];
    }
  }
  return null;
}

/// Returns the value with the given [name] in [context].
///
/// If the value is not present in [context] then [defaultsTo] is returned.
T getContext<T>(Map<String, Object> context, String name, T defaultsTo) {
  if (context == null) {
    return defaultsTo;
  }

  // ignore: avoid_as
  return context.containsKey(name) ? context[name] as T : defaultsTo;
}

/// Returns a [Uri] from the [url], which can be a [Uri] or a [String].
///
/// If the [url] is not a [Uri] or [String] an [ArgumentError] is thrown.
Uri getUrl(Object url) {
  if (url is Uri) {
    return url;
  } else if (url is String) {
    return Uri.parse(url);
  } else {
    throw ArgumentError.value(url, 'url', 'Not a Uri or String');
  }
}
