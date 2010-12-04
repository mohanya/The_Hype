class AddApprovedToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :approved, :boolean
  end

  def self.down
    remove_column :invites, :approved
  end
end
