// Copyright (c) 2018 the HTTP Dart Project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

void _printMap(String key, value) {
  print('  $key: $value');
}

/// Decodes and prints out the [response] from httpbin.
void printHttpBin(String response) {
  final converted = json.decode(response);

  print('URL: ${converted['url']}');
  print('Method: ${converted['method']}');

  final headers = converted['headers'] ?? <String, String>{};

  print('Request headers:\n');
  headers.forEach(_printMap);

  final form = converted['form'] ?? <String, String>{};

  print('\nForm values:\n');
  form.forEach(_printMap);
}
