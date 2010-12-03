class AddMoreToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :pros, :string
    add_column :reviews, :cons, :string
    add_column :reviews, :tags, :string
  end

  def self.down
    remove_column :reviews, :tags
    remove_column :reviews, :cons
    remove_column :reviews, :pros
  end
end
