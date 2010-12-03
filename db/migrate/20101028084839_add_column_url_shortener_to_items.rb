class AddColumnUrlShortenerToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :item_url, :string
    add_column :items, :custom_url, :string
    add_column :items, :custom_item, :string
  end

  def self.down
    remove_column :items, :item_url
    remove_column :items, :custom_url
    remove_column :items, :custom_item
  end
end
