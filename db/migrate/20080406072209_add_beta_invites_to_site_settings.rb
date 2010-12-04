class AddBetaInvitesToSiteSettings < ActiveRecord::Migration
  def self.up
    add_column :site_settings, :beta_invites, :boolean, :default => false
  end

  def self.down
    remove_column :site_settings, :beta_invites
  end
end
