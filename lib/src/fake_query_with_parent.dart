import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import 'query_snapshot_stream_manager.dart';

// ignore: subtype_of_sealed_class
/// This is a FakeQuery that remembers its parent. It is used to fire snapshots
/// whenever a document or collection changes.
abstract class FakeQueryWithParent<T extends Object?> implements Query<T> {
  /// The parent is not typed, because one query could be converted, while the
  /// parent is raw.
  FakeQueryWithParent? get parentQuery;

  @override
  Stream<QuerySnapshot<T>> snapshots({bool includeMetadataChanges = false}) {
    QuerySnapshotStreamManager().register<T>(this);
    final controller =
        QuerySnapshotStreamManager().getStreamController<T>(this);
    controller.addStream(Stream.fromFuture(get()));
    return controller.stream.distinct(_snapshotEquals);
  }
}

final _unorderedDeepEquality = const DeepCollectionEquality.unordered();

bool _snapshotEquals(snapshot1, snapshot2) {
  if (snapshot1.docs.length != snapshot2.docs.length) {
    return false;
  }

  for (var i = 0; i < snapshot1.docs.length; i++) {
    if (snapshot1.docs[i].id != snapshot2.docs[i].id) {
      return false;
    }

    if (!_unorderedDeepEquality.equals(
        snapshot1.docs[i].data(), snapshot2.docs[i].data())) {
      return false;
    }
  }
  return true;
}
