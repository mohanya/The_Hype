class CreateItemDetails < ActiveRecord::Migration
  def self.up
    create_table :item_details do |t|
      t.integer :item_id
      t.string :name
      t.string :value

      t.timestamps
    end
  end

  def self.down
    drop_table :item_details
  end
end
