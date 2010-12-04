class CreateInterests < ActiveRecord::Migration
  def self.up
    create_table :interests do |t|
      t.integer :profile_id
      t.integer :pos
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :interests
  end
end
