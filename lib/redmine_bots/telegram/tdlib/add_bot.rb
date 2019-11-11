module RedmineBots::Telegram::Tdlib
  class AddBot < Command
    def call(bot_name)
      client.search_public_chat(bot_name).then do |chat|
        message = TD::Types::InputMessageContent::Text.new(text: TD::Types::FormattedText.new(text: '/start', entities: []),
                                                           disable_web_page_preview: true,
                                                           clear_draft: false)
        client.send_message(chat.id, message)
      end.flat
    end
  end
end
