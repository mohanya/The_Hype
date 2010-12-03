class AddInvitesToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invites, :integer, :default => 3
  end

  def self.down
    remove_column :users, :invites
  end
end
