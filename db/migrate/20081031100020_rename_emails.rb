class RenameEmails < ActiveRecord::Migration
  def self.up
    rename_table :emails, :email_templates
  end

  def self.down
    
    rename_table :email_templates, :emails
  end
end
