class AddEmailNotificationsToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :follower_notice, :boolean, :default => true
    add_column :profiles, :comment_notice, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :follower_notice
    remove_column :profiles, :comment_notice
  end
end
