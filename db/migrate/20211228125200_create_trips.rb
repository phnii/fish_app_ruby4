class CreateTrips < ActiveRecord::Migration[6.0]
  def change
    create_table :trips do |t|
      t.string :title, null: false
      t.integer :prefecture_id, null: false
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
