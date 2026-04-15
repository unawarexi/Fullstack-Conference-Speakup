import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Manages document intelligence — listing, analyzing, and categorizing docs.
class DocumentsUseCase {
  final Ref _ref;
  DocumentsUseCase(this._ref);

  /// Fetch all documents via the AI tools interface.
  Future<Map<String, dynamic>> getDocuments() async {
    return _ref.read(aiRepositoryProvider).executeTool('list_documents', {});
  }

  Future<Map<String, dynamic>> analyzeDocument(String documentId) async {
    return _ref.read(aiRepositoryProvider).executeTool('analyze_document', {'document_id': documentId});
  }

  /// Group documents by type (pdf, doc, image, etc).
  Map<String, List<Map<String, dynamic>>> groupByType(List<Map<String, dynamic>> docs) {
    final result = <String, List<Map<String, dynamic>>>{};
    for (final doc in docs) {
      final type = doc['type'] as String? ?? 'other';
      result.putIfAbsent(type, () => []).add(doc);
    }
    return result;
  }
}

final documentsUseCaseProvider = Provider<DocumentsUseCase>((ref) {
  return DocumentsUseCase(ref);
});
