class AddConsumerTypeToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :consumer_type_id, :integer
  end

  def self.down
    remove_column :profiles, :consumer_type_id
  end
end
