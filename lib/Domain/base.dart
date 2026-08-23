abstract class BaseInfo {
  RecordStatus status = .unchanged;
  int? id;

  BaseInfo({this.id});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BaseInfo && other.id == id;
  }

  // Override hashCode to match == (only use id)
  // @override
  // int get hashCode => id.hashCode;
}

enum RecordStatus { unchanged, updated, deleted }
