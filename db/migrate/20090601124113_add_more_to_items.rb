class AddMoreToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :comments_count, :integer
    add_column :items, :score, :float
    add_column :items, :last_hyped_at, :datetime
  end

  def self.down
    remove_column :items, :last_hyped_at
    remove_column :items, :score
    remove_column :items, :comments_count
  end
end
