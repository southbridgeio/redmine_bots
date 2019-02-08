class CreateTelegramProxies < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[5.2]
  def change
    create_table :telegram_proxies do |t|
      t.string :host, null: false
      t.integer :port, null: false
      t.integer :protocol, null: false
      t.string :user
      t.string :password
      t.boolean :alive, default: false, null: false
    end
  end
end
