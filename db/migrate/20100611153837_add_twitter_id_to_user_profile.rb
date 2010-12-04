class AddTwitterIdToUserProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :twitter_id, :string
  end

  def self.down
    remove_column :profiles, :twitter_id
  end
end
