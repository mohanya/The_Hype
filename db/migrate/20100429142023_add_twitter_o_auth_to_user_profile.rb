class AddTwitterOAuthToUserProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :twitter_token, :string
    add_column :profiles, :twitter_secret, :string
  end

  def self.down
    remove_column :profiles, :twitter_token
    remove_column :profiles, :twitter_secret
  end
end
