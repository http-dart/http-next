// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'unmodifiable_map.dart';

/// An [UnmodifiableMap] that is empty.
class EmptyUnmodifiableMap<K, V>
    with UnmodifiableMapMixin<K, V>
    implements UnmodifiableMap<K, V> {
  /// Creates an instance of [EmptyUnmodifiableMap].
  const EmptyUnmodifiableMap();

  @override
  Map<RK, RV> cast<RK, RV>() => const {};

  @override
  bool containsKey(Object? key) => false;

  @override
  bool containsValue(Object? value) => false;

  @override
  V? operator [](Object? key) => null;

  @override
  Iterable<MapEntry<K, V>> get entries => const Iterable.empty();

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) f) =>
      const EmptyUnmodifiableMap();

  @override
  void forEach(void Function(K key, V value) f) {}

  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;

  @override
  Iterable<K> get keys => const Iterable.empty();

  @override
  int get length => 0;

  @override
  Iterable<V> get values => const Iterable.empty();
}
