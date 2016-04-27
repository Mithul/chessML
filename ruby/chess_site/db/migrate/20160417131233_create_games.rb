class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :winner, index: true
      t.references :loser, index: true
      t.datetime :start_time
      t.datetime :end_time
      t.text :board

      t.timestamps null: false
    end
    add_foreign_key :games, :winners
    add_foreign_key :games, :losers
  end
end
