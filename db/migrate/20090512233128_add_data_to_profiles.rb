class AddDataToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :job, :string
    add_column :profiles, :birth_date, :date
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
    add_column :profiles, :destination, :string
  end

  def self.down
    remove_column :profiles, :destination
    remove_column :profiles, :movie
    remove_column :profiles, :book
    remove_column :profiles, :band
    remove_column :profiles, :mobile_phone
    remove_column :profiles, :automobile
    remove_column :profiles, :computer
    remove_column :profiles, :trusted_brands
    remove_column :profiles, :consumer_type
    remove_column :profiles, :married
    remove_column :profiles, :income
    remove_column :profiles, :birth_date
    remove_column :profiles, :job
  end
end
