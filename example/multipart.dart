
// Copyright (c) 2018 the HTTP Dart Project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:http_next/http.dart' as http;

import 'util.dart';

Future<void> main() async {
  // Open a file for reading to create a stream
  final fileStream = File('example/upload.txt').openRead();

  // Reads from the stream to create a multipart file
  final file = await http.MultipartFile.loadStream('file', fileStream);

  // Create the multipart request
  final request = http.Request.multipart('https://httpbin.org/anything',
      fields: <String, String>{
        'dart': 'The programming language used',
        'http': 'The package used for this request',
      },
      files: [
        file
      ],);

  // Create a client
  final client = http.Client();
  final response = await client.send(request);

  // Read the response
  final responseText = await response.readAsString();

  printHttpBin(responseText);

  // Close the client
  client.close();
}
