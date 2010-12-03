class CleanupProfile < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :married
    remove_column :profiles, :income
    remove_column :profiles, :movie
    remove_column :profiles, :book
    remove_column :profiles, :band
    remove_column :profiles, :mobile_phone
    remove_column :profiles, :automobile
    remove_column :profiles, :computer
    remove_column :profiles, :trusted_brands
    remove_column :profiles, :consumer_type
    remove_column :profiles, :destination
    remove_column :profiles, :hyper_type
    
    add_column :profiles, :about_me, :text
    add_column :profiles, :is_male, :boolean, :default => true
    add_column :profiles, :hide_date_of_birth, :boolean
    add_column :profiles, :city, :string
    add_column :profiles, :country, :string 
  end

  def self.down
    remove_column :profiles, :country
    remove_column :profiles, :city
    remove_column :profiles, :hide_date_of_birth
    remove_column :profiles, :is_male
    remove_column :profiles, :about_me
    
    add_column :profiles, :hyper_type, :string
    add_column :profiles, :destination, :string
    add_column :profiles, :income, :integer
    add_column :profiles, :married, :boolean
    add_column :profiles, :consumer_type, :string
    add_column :profiles, :trusted_brands, :string
    add_column :profiles, :computer, :string
    add_column :profiles, :automobile, :string
    add_column :profiles, :mobile_phone, :string
    add_column :profiles, :band, :string
    add_column :profiles, :book, :string
    add_column :profiles, :movie, :string
    
  end
end
