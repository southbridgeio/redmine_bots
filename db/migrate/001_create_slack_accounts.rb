class CreateSlackAccounts < ActiveRecord::Migration
  def change
    create_table :slack_accounts do |t|
      t.string :slack_id, index: true
      t.string :name
      t.string :team_id, index: true
      t.string :token, index: true
      t.belongs_to :user, foreign_key: true, index: true
    end
  end
end