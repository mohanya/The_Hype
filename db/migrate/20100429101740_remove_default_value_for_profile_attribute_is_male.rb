class RemoveDefaultValueForProfileAttributeIsMale < ActiveRecord::Migration
  def self.up
    change_table :profiles do |t|
      t.change :is_male, :boolean, :default => nil
    end
  end

  def self.down
    change_table :profiles do |t|
      t.change :is_male, :boolean, :default => true
    end
  end
end
