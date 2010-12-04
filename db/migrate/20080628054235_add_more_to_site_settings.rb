class AddMoreToSiteSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings, :referrals, :boolean, :default => false
    add_column :site_settings, :blog, :boolean, :default => false
    add_column :site_settings, :newsletter, :boolean, :default => false
  end

  def self.down
    remove_column :site_settings, :newsletter
    remove_column :site_settings, :blog
    remove_column :site_settings, :referrals
  end
end
