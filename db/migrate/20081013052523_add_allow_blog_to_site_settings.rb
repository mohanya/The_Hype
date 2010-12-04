class AddAllowBlogToSiteSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings, :allow_blog, :boolean
  end

  def self.down
    remove_column :site_settings, :allow_blog
  end
end
