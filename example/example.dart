// Copyright (c) 2018 the HTTP Dart Project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:http_next/http.dart' as http;

Future<void> main() async {
  const url = 'https://httpbin.org/post';
  final response = await http.post(url, <String, String>{
    'name': 'doodle',
    'color': 'blue',
  });
  final responseText = await response.readAsString();

  print(response.statusCode);
  print(responseText);
}
