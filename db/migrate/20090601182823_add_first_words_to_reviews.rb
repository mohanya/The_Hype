class AddFirstWordsToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :first_words, :string
  end

  def self.down
    remove_column :reviews, :first_words
  end
end
