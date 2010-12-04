class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title, :null => false
      t.string :permalink
      t.datetime :posted_at
      t.text :body
      t.integer :author_id
      t.integer :comments_count
      t.string :state, :default => "draft"
      t.string :page_title
      t.string :description, :limit => 155
      t.string :keywords

      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
