// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_log_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$eventLogRepositoryHash() =>
    r'c08958465d2c01c133a568de34a87436ed2dbf19';

/// See also [eventLogRepository].
@ProviderFor(eventLogRepository)
final eventLogRepositoryProvider = Provider<EventLogRepository>.internal(
  eventLogRepository,
  name: r'eventLogRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$eventLogRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EventLogRepositoryRef = ProviderRef<EventLogRepository>;
String _$todayEventsHash() => r'5a3a9bec25cba705db30c751bd985dc4418c19b0';

/// See also [todayEvents].
@ProviderFor(todayEvents)
final todayEventsProvider =
    AutoDisposeStreamProvider<List<EventLogModel>>.internal(
  todayEvents,
  name: r'todayEventsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodayEventsRef = AutoDisposeStreamProviderRef<List<EventLogModel>>;
String _$recentEventsHash() => r'fdd555f4e7658a40ab94ea13535b30eadbb77d83';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [recentEvents].
@ProviderFor(recentEvents)
const recentEventsProvider = RecentEventsFamily();

/// See also [recentEvents].
class RecentEventsFamily extends Family<AsyncValue<List<EventLogModel>>> {
  /// See also [recentEvents].
  const RecentEventsFamily();

  /// See also [recentEvents].
  RecentEventsProvider call({
    int limit = 8,
  }) {
    return RecentEventsProvider(
      limit: limit,
    );
  }

  @override
  RecentEventsProvider getProviderOverride(
    covariant RecentEventsProvider provider,
  ) {
    return call(
      limit: provider.limit,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentEventsProvider';
}

/// See also [recentEvents].
class RecentEventsProvider
    extends AutoDisposeStreamProvider<List<EventLogModel>> {
  /// See also [recentEvents].
  RecentEventsProvider({
    int limit = 8,
  }) : this._internal(
          (ref) => recentEvents(
            ref as RecentEventsRef,
            limit: limit,
          ),
          from: recentEventsProvider,
          name: r'recentEventsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recentEventsHash,
          dependencies: RecentEventsFamily._dependencies,
          allTransitiveDependencies:
              RecentEventsFamily._allTransitiveDependencies,
          limit: limit,
        );

  RecentEventsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    Stream<List<EventLogModel>> Function(RecentEventsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentEventsProvider._internal(
        (ref) => create(ref as RecentEventsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<EventLogModel>> createElement() {
    return _RecentEventsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentEventsProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentEventsRef on AutoDisposeStreamProviderRef<List<EventLogModel>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _RecentEventsProviderElement
    extends AutoDisposeStreamProviderElement<List<EventLogModel>>
    with RecentEventsRef {
  _RecentEventsProviderElement(super.provider);

  @override
  int get limit => (origin as RecentEventsProvider).limit;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
