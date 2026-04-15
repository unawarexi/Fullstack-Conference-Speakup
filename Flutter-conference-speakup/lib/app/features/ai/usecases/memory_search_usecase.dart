import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Use case for semantic memory search across meetings.
class MemorySearchUseCase {
  final Ref _ref;
  MemorySearchUseCase(this._ref);

  Future<List<Map<String, dynamic>>> search(String query) {
    return _ref.read(aiRepositoryProvider).queryMemory(query);
  }

  Future<Map<String, dynamic>> getReplay(String meetingId) {
    return _ref.read(aiRepositoryProvider).getMemoryReplay(meetingId);
  }

  Future<Map<String, dynamic>> getRelationship(String userId, String targetId) {
    return _ref.read(aiRepositoryProvider).getRelationship(userId, targetId);
  }
}

final memorySearchUseCaseProvider = Provider<MemorySearchUseCase>((ref) {
  return MemorySearchUseCase(ref);
});
