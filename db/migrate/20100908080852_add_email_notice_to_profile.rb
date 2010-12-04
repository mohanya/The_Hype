class AddEmailNoticeToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :email_notice, :boolean, :default => true
  end

  def self.down
    remove_column :profiles, :email_notice
  end
end
