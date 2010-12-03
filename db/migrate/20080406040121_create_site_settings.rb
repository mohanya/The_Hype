class CreateSiteSettings < ActiveRecord::Migration
  def self.up
    create_table :site_settings do |t|
      t.string :url
      t.string :description
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :site_settings
  end
end
