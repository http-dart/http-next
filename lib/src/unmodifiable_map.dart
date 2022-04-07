// Copyright (c) 2020, the HTTP Dart project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

import 'empty_unmodifiable_map.dart';

/// A [Map] whose values are unmodifiable.
class UnmodifiableMap<K, V>
    with UnmodifiableMapMixin<K, V>
    implements Map<K, V> {
  /// Creates an [UnmodifiableMap] over the value.
  const UnmodifiableMap(this._map);

  /// An empty [UnmodifiableMap].
  const factory UnmodifiableMap.empty() = EmptyUnmodifiableMap;

  final Map<K, V> _map;

  @override
  Map<RK, RV> cast<RK, RV>() => _map.cast<RK, RV>();

  @override
  bool containsKey(Object? key) => _map.containsKey(key);

  @override
  bool containsValue(Object? value) => _map.containsValue(value);

  @override
  V? operator [](Object? key) => _map[key];

  @override
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K key, V value) f) =>
      _map.map<K2, V2>(f);

  @override
  void forEach(void Function(K key, V value) f) {
    _map.forEach(f);
  }

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<K> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  Iterable<V> get values => _map.values;
}

/// Mixin that implements a throwing version of all map operations that
/// change the Map.
mixin UnmodifiableMapMixin<K, V> implements Map<K, V> {
  static Never _throw() {
    throw UnsupportedError('Cannot modify an unmodifiable Map');
  }

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  void operator []=(K key, V value) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  void addEntries(Iterable<MapEntry<K, V>> newEntries) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  V update(K key, V Function(V value) update, {V Function()? ifAbsent}) =>
      _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  void updateAll(V Function(K key, V value) update) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  void removeWhere(bool Function(K key, V value) predicate) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  V putIfAbsent(K key, V Function() ifAbsent) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  void addAll(Map<K, V> other) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  V remove(Object? key) => _throw();

  /// Throws an [UnsupportedError];
  /// operations that change the map are disallowed.
  @override
  void clear() => _throw();
}
