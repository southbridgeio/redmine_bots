class CreateYandexAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :yandex_accounts do |t|
      t.references :user, foreign_key: true, index: { unique: true }
      t.string :login, null: false
      t.string :guid
      t.string :display_name
      t.datetime :verified_at
      t.timestamps
    end

    add_index :yandex_accounts, 'LOWER(login)', unique: true, name: 'index_yandex_accounts_on_lower_login'
    add_index :yandex_accounts, :guid, unique: true, where: 'guid IS NOT NULL'
  end
end
