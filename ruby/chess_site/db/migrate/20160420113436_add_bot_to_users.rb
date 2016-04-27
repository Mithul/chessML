class AddBotToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bot, :boolean
  end
end
