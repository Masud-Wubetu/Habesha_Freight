import db from '../config/db';

export interface Message {
  id: string;
  sender_id: string;
  receiver_id: string;
  thread_id: string;
  content: string;
  is_read: boolean;
  read_at: Date | null;
  created_at: Date;
}

export class MessageService {
  static async sendMessage(
    senderId: string,
    receiverId: string,
    content: string,
    threadId?: string
  ): Promise<Message> {
    const thread = threadId || `${[senderId, receiverId].sort().join('-')}`;

    const [message] = await db('messages')
      .insert({
        sender_id: senderId,
        receiver_id: receiverId,
        thread_id: thread,
        content,
        is_read: false,
      })
      .returning('*');

    return message;
  }

  static async getConversations(userId: string) {
    const threads = await db('messages')
      .select('thread_id')
      .where('sender_id', userId)
      .orWhere('receiver_id', userId)
      .groupBy('thread_id');

    if (threads.length === 0) return [];

    const conversations = await Promise.all(
      threads.map(async (t) => {
        const latestMessage = await db('messages')
          .where('thread_id', t.thread_id)
          .orderBy('created_at', 'desc')
          .first();

        const otherParticipantId = latestMessage.sender_id === userId 
          ? latestMessage.receiver_id 
          : latestMessage.sender_id;

        const otherUser = await db('users')
          .select('id', 'full_name', 'phone_number', 'profile_photo_url')
          .where('id', otherParticipantId)
          .first();

        const unreadCount = await db('messages')
          .where('thread_id', t.thread_id)
          .where('receiver_id', userId)
          .where('is_read', false)
          .count('* as count')
          .first();

        return {
          thread_id: t.thread_id,
          other_user: otherUser,
          latest_message: latestMessage,
          unread_count: Number(unreadCount?.count || 0),
          updated_at: latestMessage.created_at,
        };
      })
    );

    return conversations.sort((a, b) => 
      new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()
    );
  }

  static async getThreadMessages(threadId: string, userId: string, limit = 50, offset = 0) {
    const threadExists = await db('messages')
      .where('thread_id', threadId)
      .where((builder) => {
        builder.where('sender_id', userId).orWhere('receiver_id', userId);
      })
      .first();

    if (!threadExists) {
      throw new Error('THREAD_NOT_FOUND');
    }

    await db('messages')
      .where('thread_id', threadId)
      .where('receiver_id', userId)
      .where('is_read', false)
      .update({
        is_read: true,
        read_at: db.fn.now(),
      });

    const messages = await db('messages')
      .where('thread_id', threadId)
      .orderBy('created_at', 'asc')
      .limit(limit)
      .offset(offset)
      .select('*');

    return messages;
  }

  static async getUnreadCount(userId: string): Promise<number> {
    const result = await db('messages')
      .where('receiver_id', userId)
      .where('is_read', false)
      .count('* as count')
      .first();

    return Number(result?.count || 0);
  }
}
