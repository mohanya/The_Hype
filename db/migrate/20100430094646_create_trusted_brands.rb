class CreateTrustedBrands < ActiveRecord::Migration
  def self.up
    create_table :trusted_brands do |t|
      t.integer :profile_id
      t.integer :pos
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :trusted_brands
  end
end
