class AddHypeWrothToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :hype_worth, :integer
  end

  def self.down
    remove_column :items, :hype_worth
  end
end
