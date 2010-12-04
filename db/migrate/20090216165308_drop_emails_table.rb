class DropEmailsTable < ActiveRecord::Migration
  def self.up
    drop_table :emails
  end

  def self.down
    create_table :emails do |t|
      t.column :from, :string
      t.column :to, :string
      t.column :last_send_attempt, :integer, :default => 0
      t.column :mail, :text
      t.column :created_on, :datetime
    end
  end
end

class Email < ActiveRecord::Base
end

