class AddDeletedToNotices < ActiveRecord::Migration
  def self.up
    add_column :notices, :deleted_at, :datetime
  end

  def self.down
    #remove_column :notices, :deleted_at
  end
end
