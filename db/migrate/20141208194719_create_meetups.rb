class CreateMeetups < ActiveRecord::Migration
  def change
    create_table :meetups do |t|
      t.string :name, null: false
      t.text :description
      t.string :location
      t.timestamps
    end
  end
end
