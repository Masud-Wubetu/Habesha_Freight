import 'api_client.dart';
import '../config/api_config.dart';

/// Messaging API helpers wrapping [ApiConfig.messages] (`/messages/*`).
class MessageService {
  MessageService({ApiClient? client}) : _api = client ?? ApiClient();

  final ApiClient _api;

  Future<List<Map<String, dynamic>>> listConversations() async {
    final res = await _api.get(ApiConfig.messagesConversations);
    return _asList(res['data']);
  }

  Future<List<Map<String, dynamic>>> getThread(String threadId) async {
    final res = await _api.get(ApiConfig.messagesThread(threadId));
    return _asList(res['data']);
  }

  Future<Map<String, dynamic>> send({
    required String receiverId,
    required String content,
    String? threadId,
  }) async {
    final res = await _api.post(
      ApiConfig.messagesSend,
      body: {
        'receiver_id': receiverId,
        'content': content,
        if (threadId != null) 'thread_id': threadId,
      },
    );
    return (res['data'] as Map?)?.cast<String, dynamic>() ?? res;
  }
}

List<Map<String, dynamic>> _asList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();
  }
  if (raw is Map && raw['items'] is List) return _asList(raw['items']);
  return const [];
}
