class AddSubjectToEmail < ActiveRecord::Migration
  def self.up
    add_column :emails, :subject, :string
  end

  def self.down
    remove_column :emails, :subject
  end
end
