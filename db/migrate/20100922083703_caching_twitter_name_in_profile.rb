class CachingTwitterNameInProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :twitter_name, :string
    add_column :profiles, :twitter_updated_at, :datetime
  end

  def self.down
    remove_column :profiles, :twitter_name
    remove_column :profiles, :twitter_updated_at
  end
end
