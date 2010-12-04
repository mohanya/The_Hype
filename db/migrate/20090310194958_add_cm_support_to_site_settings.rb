class AddCmSupportToSiteSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings, :cm_api_key, :string
    add_column :site_settings, :cm_subscribers_list, :string
  end

  def self.down
    remove_column :site_settings, :cm_subscribers_list
    remove_column :site_settings, :cm_api_key
  end
end
