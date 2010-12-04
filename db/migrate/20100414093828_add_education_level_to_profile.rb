class AddEducationLevelToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :education_level_id, :integer
  end

  def self.down
    remove_column :profiles, :education_level_id
  end
end
