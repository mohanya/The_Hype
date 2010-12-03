class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :sender_id,   :null => false
      t.integer :receiver_id, :null => false
      t.string  :subject,     :null => false
      t.string  :body,        :null => false
      t.boolean :read,        :null => false, :default => false

      t.timestamps
    end
    
    change_table :messages do |t|
      t.index :sender_id
      t.index :receiver_id
      
    end
  end

  def self.down
    drop_table :messages
  end
end
