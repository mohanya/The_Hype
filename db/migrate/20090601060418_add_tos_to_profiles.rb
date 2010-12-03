class AddTosToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :tos, :boolean
  end

  def self.down
    remove_column :profiles, :tos
  end
end
