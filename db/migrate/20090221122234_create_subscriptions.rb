class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.integer :profile_id
      t.datetime :subscribed_at
      t.string :signup_ip_address

      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
