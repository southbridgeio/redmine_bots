class ChangeTelegramIdToDecimal < Rails.version < '5.0' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    change_column :telegram_accounts, :telegram_id, :decimal
  end
end
