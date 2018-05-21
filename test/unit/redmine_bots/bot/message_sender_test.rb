require File.expand_path('../../../../test_helper', __FILE__)

class RedmineBots::Telegram::Bot::MessageSenderTest < ActiveSupport::TestCase
  let(:chat_id) { 123 }
  let(:text) { 'text' }
  let(:bot_token) { 'token' }

  subject do
    RedmineBots::Telegram::Bot::MessageSender.new(
      chat_id: chat_id,
      message: text,
      bot_token: bot_token
    )
  end

  before do
    Telegram::Bot::Api.any_instance.stubs(:get_me)
  end

  it 'inits telegram bot with passed token' do
    expect(subject.bot_token).must_equal bot_token
  end

  it 'sends message via telegram_bot_ruby' do
    Telegram::Bot::Api.any_instance
      .expects(:send_message)
      .with(
        chat_id: chat_id,
        text: text,
        parse_mode: 'HTML',
        disable_web_page_preview: true,
      )

    subject.call
  end
end
