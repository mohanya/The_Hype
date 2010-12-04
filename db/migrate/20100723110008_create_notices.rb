class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
     t.integer :user_id, :sender_id
     t.string :item_id, :about
     t.timestamps
    end
  end

  def self.down
    drop_table :notices
  end
end
