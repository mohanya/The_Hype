class CreateConsumerTypes < ActiveRecord::Migration
  def self.up
    create_table :consumer_types do |t|
      t.string :name, :null => false
      t.string :description, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :consumer_types
  end
end
