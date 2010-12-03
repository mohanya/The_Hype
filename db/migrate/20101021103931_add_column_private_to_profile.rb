class AddColumnPrivateToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :private, :boolean, :default=>false
  end

  def self.down
    remove_column :profiles, :private
  end
end
