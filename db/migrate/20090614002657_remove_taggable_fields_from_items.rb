class RemoveTaggableFieldsFromItems < ActiveRecord::Migration
  def self.up
    remove_column :reviews, :pros
    remove_column :reviews, :cons
    remove_column :reviews, :first_words
    remove_column :reviews, :tags
  end

  def self.down
    add_column :reviews, :tags, :string
    add_column :reviews, :first_words, :string
    add_column :reviews, :cons, :string
    add_column :reviews, :pros, :string
  end
end
