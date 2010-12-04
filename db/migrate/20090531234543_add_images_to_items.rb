class AddImagesToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :image_url, :string
    add_column :items, :image_height, :integer
    add_column :items, :image_width, :integer
  end

  def self.down
    remove_column :items, :image_width
    remove_column :items, :image_height
    remove_column :items, :image_url
  end
end
