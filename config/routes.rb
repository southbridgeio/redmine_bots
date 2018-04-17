scope :slack do
  scope :sign_in do
    get '/' => 'slack_sign_in#index', as: 'slack_sign_in'
    get 'check' => 'slack_sign_in#check', as: 'check_slack_sign_in'
  end
end
