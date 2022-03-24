class CreateResults < ActiveRecord::Migration[6.0]
  def change
    create_table :results do |t|
      t.string :fish_name, null: false
      t.references :trip, null: false, foreign_key: true
      t.timestamps
    end
  end
end
