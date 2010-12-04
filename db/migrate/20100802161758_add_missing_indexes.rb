class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :friendships, :user_id
    add_index :friendships, :friend_id
    add_index(:notices, :user_id)
    add_index(:infos, :visible) 
    add_index(:interests, :profile_id)
    add_index(:trusted_brands, :profile_id)
  end

  def self.down
    remove_index :friendships, :user_id
    remove_index :friendships, :friend_id
    remove_index(:notices, :user_id)
    remove_index(:infos, :visible) 
    remove_index(:interests, :profile_id)
    remove_index(:trusted_brands, :profile_id)
  end
end
