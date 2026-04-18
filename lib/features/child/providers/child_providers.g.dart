// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$childRepositoryHash() => r'9a5fb1735da02d26a90e69b550132f7c9cdd6bb2';

/// See also [childRepository].
@ProviderFor(childRepository)
final childRepositoryProvider = Provider<ChildRepository>.internal(
  childRepository,
  name: r'childRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$childRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChildRepositoryRef = ProviderRef<ChildRepository>;
String _$childrenHash() => r'488cc8dda32ae3c085846fa662a04d11aba903b1';

/// Realm'daki tüm çocukları reaktif stream olarak yayınlar.
///
/// Realm'ın [RealmResults] nesnesi değişim bildirimi destekler.
/// Her ekleme/silme/güncelleme sonrası bu stream otomatik emit eder.
///
/// Copied from [children].
@ProviderFor(children)
final childrenProvider = AutoDisposeStreamProvider<List<ChildModel>>.internal(
  children,
  name: r'childrenProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$childrenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChildrenRef = AutoDisposeStreamProviderRef<List<ChildModel>>;
String _$hasAnyChildHash() => r'a8549c5af0e371bb77e90b4bc4d9470c5b1ec8ee';

/// Veri tabanında hiç çocuk var mı? (Routing kararı için)
///
/// Ayrı stream: [children]'den bağımsız — sadece boş/dolu bilgisi.
///
/// Copied from [hasAnyChild].
@ProviderFor(hasAnyChild)
final hasAnyChildProvider = AutoDisposeStreamProvider<bool>.internal(
  hasAnyChild,
  name: r'hasAnyChildProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$hasAnyChildHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasAnyChildRef = AutoDisposeStreamProviderRef<bool>;
String _$selectedChildHash() => r'7e00aeeb605ca1aaaecdc0f2107e9457758f3218';

/// Seçili [ChildModel] nesnesini döner.
///
/// [SelectedChildId] değişince otomatik güncellenir.
///
/// Copied from [selectedChild].
@ProviderFor(selectedChild)
final selectedChildProvider = AutoDisposeProvider<ChildModel?>.internal(
  selectedChild,
  name: r'selectedChildProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedChildHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedChildRef = AutoDisposeProviderRef<ChildModel?>;
String _$selectedChildIdHash() => r'dd63477e9048ca29ed370e336e98cfa1f165abbf';

/// Şu an aktif olan çocuğun [ObjectId]'si.
///
/// [null] → Hiç çocuk yok (OnboardingScreen'de olunması gerekir).
///
/// İlk açılışta otomatik olarak ilk çocuğu seçer.
/// Kullanıcı yatay kaydırarak farklı çocuk seçebilir.
///
/// Copied from [SelectedChildId].
@ProviderFor(SelectedChildId)
final selectedChildIdProvider =
    NotifierProvider<SelectedChildId, ObjectId?>.internal(
  SelectedChildId.new,
  name: r'selectedChildIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedChildIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedChildId = Notifier<ObjectId?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
