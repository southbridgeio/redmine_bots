require 'telegram/bot'

token = 'token'

bot = Telegram::Bot::Client.new(token)

puts bot

bot.listen do |message|
  puts message.to_compact_hash
  case message.text
  when '/start'
    bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
  when '/stop'
    bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
  end
end
