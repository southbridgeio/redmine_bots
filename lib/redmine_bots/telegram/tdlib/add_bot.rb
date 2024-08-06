module RedmineBots::Telegram::Tdlib
  class AddBot < Command
    def call(bot_name)
      client.search_public_chat(username: bot_name).then do |chat|
        message = TD::Types::InputMessageContent::Text.new(text: TD::Types::FormattedText.new(text: '/start', entities: []),
                                                           link_preview_options: nil,
                                                           clear_draft: false)
        client.send_message(chat_id: chat.id,
                            message_thread_id: nil,
                            reply_to: nil,
                            options: nil,
                            reply_markup: nil,
                            input_message_content: message)
      end.flat
    end
  end
end
