// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'unmodifiable_map.dart';

/// Helpers for manipulating [Message.context] values.
extension Context on Map<String, Object> {
  /// Creates a [HttpUnmodifiableMap] from the [source] while preventing
  /// re-wrapping itself.
  ///
  /// If [source] is already a [HttpUnmodifiableMap] then it is returned
  /// unchanged.
  ///
  /// If [source] is `null` it is treated as an empty map.
  ///
  /// When creating a [HttpUnmodifiableMap] the [source] is copies to a new
  /// [Map] to ensure changes to the parameter value after constructions are
  /// not reflected.
  static Map<String, Object> create(Map<String, Object> source) {
    if (source is UnmodifiableMap<String, Object>) {
      return source;
    }

    return source == null || source.isEmpty
        ? const UnmodifiableMap<String, Object>.empty()
        : UnmodifiableMap<String, Object>(Map.from(source));
  }

  /// Returns a [HttpUnmodifiableMap] with the values from [original] and the
  /// values from [updates].
  ///
  /// For keys that are the same between [original] and [updates], the value in
  /// [updates] is used.
  static Map<String, Object> update(
    Map<String, Object> original,
    Map<String, Object> updates,
  ) {
    if (updates == null || updates.isEmpty) {
      return create(original);
    }

    return UnmodifiableMap<String, Object>(Map.from(original)..addAll(updates));
  }

  /// Retrieves the value at [name] if present; otherwise [defaultsTo] is
  /// returned.
  T getOrDefault<T>(String name, T defaultsTo) =>
      // ignore: avoid_as
      this[name] as T ?? defaultsTo;
}
