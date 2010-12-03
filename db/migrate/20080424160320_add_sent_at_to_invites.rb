class AddSentAtToInvites < ActiveRecord::Migration
  def self.up
    add_column :invites, :sent_at, :datetime
  end

  def self.down
    remove_column :invites, :sent_at
  end
end
