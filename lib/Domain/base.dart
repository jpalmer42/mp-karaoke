abstract class BaseInfo {
  RecordStatus status = .unchanged;
}

enum RecordStatus { unchanged, updated, deleted }
