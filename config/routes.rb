scope :slack do
  scope :sign_in do
    get '/' => 'slack_sign_in#index', as: 'slack_sign_in'
    get 'check' => 'slack_sign_in#check', as: 'check_slack_sign_in'
  end
end

scope :telegram do
  scope :setup do
    get 'step_1' => 'redmine_telegram_setup#step_1', as: :telegram_setup_1
    post 'step_2' => 'redmine_telegram_setup#step_2', as: :telegram_setup_2
    post 'step_3' => 'redmine_telegram_setup#step_3', as: :telegram_setup_3
    post 'authorize' => 'redmine_telegram_setup#authorize', as: :telegram_setup_authorize
    delete 'reset' => 'redmine_telegram_setup#reset', as: :telegram_setup_reset
  end

  scope :api do
    post 'web_hook/:secret', to: TelegramWebhookController.action(:update), as: 'telegram_common_webhook'
    post 'bot_init' => 'redmine_telegram_setup#bot_init', as: 'telegram_bot_init'
    delete 'bot_deinit' => 'redmine_telegram_setup#bot_deinit', as: 'telegram_bot_deinit'
  end

  get 'login' => 'telegram_login#index', as: 'telegram_login'
  get 'check_auth' => 'telegram_login#check_auth'
end

scope :telegram_proxies do
  get '/' => 'telegram_proxies#index', as: :telegram_proxies
  get '/new' => 'telegram_proxies#new', as: :telegram_proxy_new
  post '/' => 'telegram_proxies#update', as: :telegram_proxies_update
  delete '/:id' => 'telegram_proxies#destroy', as: :telegram_proxy_destroy
end
