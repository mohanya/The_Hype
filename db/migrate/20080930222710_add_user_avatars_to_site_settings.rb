class AddUserAvatarsToSiteSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings, :user_avatar_upload, :boolean
  end

  def self.down
    remove_column :site_settings, :user_avatar_upload
  end
end
