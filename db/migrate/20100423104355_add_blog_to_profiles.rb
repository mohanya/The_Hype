class AddBlogToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :blog, :string
  end

  def self.down
    remove_column :profiles, :blog
  end
end
