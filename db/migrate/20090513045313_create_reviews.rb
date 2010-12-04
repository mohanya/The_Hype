class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.integer :user_id
      t.integer :item_id
      t.integer :criteria_1
      t.integer :criteria_2
      t.integer :criteria_3
      t.text :comments
      t.boolean :recommended
      t.boolean :shared

      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
