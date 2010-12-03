class AddSentActivationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sent_activation, :boolean
    User.reset_column_information
    User.find(:all).each do |user|
      if user.state == "active"
        user.sent_activation = true
        user.save
      end
    end
  end

  def self.down
    remove_column :users, :sent_activation
  end
end
