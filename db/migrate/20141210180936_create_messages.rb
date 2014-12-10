class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |table|
      table.text :message, null: false
      table.integer :user_id, null: false
      table.integer :meetup_id, null: false
      table.timestamps
    end
  end
end
