class AddAdminEmailToSiteSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings, :admin_email, :string
  end

  def self.down
    remove_column :site_settings, :admin_email
  end
end
