class AddCriteriaToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :criteria_1, :float
    add_column :items, :criteria_2, :float
    add_column :items, :criteria_3, :float
  end

  def self.down
    remove_column :items, :criteria_3
    remove_column :items, :criteria_2
    remove_column :items, :criteria_1
  end
end
