// Copyright (c) 2018, the HTTP Dart project authors.
// Copyright (c) 2017, the Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'dart:async';

import 'request.dart';
import 'response.dart';

/// The signature of a function which handles a [Request] and returns a
/// [FutureOr<Response>].
///
/// A [Handler] may call an underlying HTTP implementation, or it may wrap
/// another [Handler] or a [Client].
typedef Handler = FutureOr<Response> Function(Request request);
