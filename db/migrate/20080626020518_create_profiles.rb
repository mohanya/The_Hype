class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.integer :referral_id
      t.integer :user_id
      t.boolean :subscribed, :default => false

      t.timestamps
    end
    add_index :profiles, :email
    add_index :profiles, :user_id
  end

  def self.down
    drop_table :profiles
  end
end
